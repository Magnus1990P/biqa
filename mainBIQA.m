%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Testing file for testing correct iteration of databases
%%		Takse the parameter of number of databses to be run
%%
%%	Author:				Magnus Øverbø
%%	Copyright:		Magnus Øverbø
%%	Supervisor:		Kiran Bylappa Raja NISlab
%%	Last rev:			
%%	Comment:			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mainBIQA( num_dbs )
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%	FILENAME VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	NUMDB				= num_dbs;															%number of databases
	count				= 0; 																		%counter
	maxImgWidth	=	600;																	%Maximum image width
	pathSkip		= [42,44,45];														%Const pathskip for paths
	endSkip			= [4,4,5];															%Extension skip
	dbBasePath  = '/development/dbIris/db_periocular/';	
	dbSavePath  = '/development/dbIris/img_processed/';
	extension   = [ '_segm.bmp'; 		...
	                '_mask.bmp'; 		...
	                '_para.txt';];
	load modelparameters.mat;													%Load NIQE IQA requirements
	blk_size_r = 32;
	blk_size_c = 32;
	blk_row_ol = 0;
	blk_col_ol = 0;
	addpath('./fdct_usfft_matlab/');									%Add library to path

	imgDB;																						%Load imgDB.m
	result		= zeros(0,25);													%Result matrix

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Load databases of images
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for j=1:1:NUMDB																%Go through databases
  	if j==1       												      %Set and select HQ database
  	  db = imgList_1;    												%High Quality Image Set
	    disp('GUC database');
		elseif j==2																	%Set and select LQ database
  	  db = imgList_2;      											%Low Quality Image Set
	    disp('Miche databse');										%
		elseif j==3
  	  db = imgList_3;      											%Low Quality Image Set
	    disp('UBIRIS databse');										%
		end																					%end database load
		SKIP	= pathSkip(j);												%Set std var to req skip
		EXT		= endSkip(j);
  
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  	%% Retrieve assessment data for images
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  	for fileIndex=1:1:size(db,1)                    	%For all in current set
    	count = count + 1;															%Counter
			fname = db(fileIndex, :);
			disp( fname );

			%LOAD CURRENT IMAGE and save filename
			im = imread( fname );
			if size(im,2) > maxImgWidth
				scale = double(maxImgWidth) / double(size (im,2));
				im = imresize( im, scale );
			end
			
		  %find_iris locates iris and pupil if not found it returns an empty array
		  scan = find_iris( im );
	  	if isempty(scan) == 0							%If iris and pupil located
			  result(count,1)	= scan(1,1);		result(count,2) = scan(1,2);
	  		result(count,3)	= scan(1,3);  	result(count,4) = scan(1,4);
			  result(count,5) = scan(1,5);		result(count,6)	= scan(1,6);

  			%Calculate ISO-metrics
	  		result(count,7)	= iso_uia(		scan(1,3)   , scan(1,6)   );
				result(count,8)	= iso_gsu(im,	scan(1,4:6) , scan(1,1:3) );
				[result(count,9), result(count,10)]	...
  											= iso_ipc(im,	scan(1,4:6) , scan(1,1:3) );
			  result(count,11)= iso_isc(im,	scan(1,4:6) , scan(1,1:3) );

				%Pupil to Iris Ratio
				result(count,12)= (scan(1,6) / scan(1,3)) * 100;
			
				%Iris_Pupil Concentricity ( the centric offset between iris and pupil)
				result(count,13)= sqrt( (scan(1,1)-scan(1,4))^2   +							...
				                        (scan(1,2)-scan(1,5))^2   ) / scan(1,3);
					
			  result(count,14)= (scan(1,1)  - scan(1,3) ) / scan(1,3);
			  result(count,15)= (size(im,2) - ( scan(1,1) + scan(1,3) ) ) / scan(1,3);
			  result(count,16)= (size(im,1) - ( scan(1,2) + scan(1,3) ) ) / scan(1,3);
		  	result(count,17)= (scan(1,2)  - scan(1,3) ) / scan(1,3);
				
			else													%if iris is not located
				result(count, 1:17) = -1;
			end 						%end find_iris
	

			%Calculate Gray Scale Utilisation of segmented iris image
			iris = im;
			pixel = zeros(1,257);
			if size(im, 3) == 3
				iris = rgb2gray( iris );
			end
			
			iris = reshape( iris, 1, (size(iris,1)*size(iris,2)) );
			for i=1:1:length(iris)
				x = iris(1, i) + 1;					%Calc array index is value of cell plus 1
			   pixel( 1, x ) = pixel( 1, x ) + 1;  %Increment value at index x
			end
			pixTot = size(iris,1)*size(iris,2);
			pixel = pixel / pixTot;
		
			GREY_SCALE_UTILISATION = 0;
			for i=1:1:length(pixel)
				if pixel( 1, i ) > 0
					GREY_SCALE_UTILISATION = GREY_SCALE_UTILISATION   -   ...
						                       ( pixel(1,i) * log2( pixel(1,i) ) );
				end
			end
			clear iris pixel;

			result(count,18) = GREY_SCALE_UTILISATION;
		
			%RUN IQA FUNCTIONS AND STORE IN QUALITY ASSESSMENT MATRIX
			%NIQE - Low is good
			result(count,19) = computequality(	im,							...
																					blk_size_r,			...
																					blk_size_c,			...
																					blk_row_ol,			...
																					blk_col_ol,			...
																					mu_prisparam,		...
																					cov_prisparam			);

			%BRISQUE - Low is good
			result(count,20)	=	brisquescore( im );

			%jp2knr_quality - High is good
			result(count,21)	=	jp2knr_quality( im );

			%BIQI - jpeg_quality_score
			result(count,22)	= jpeg_quality_score( double(im) );
			delete output;
			%BIQI - biqi algorithm
			result(count,23)	= biqi( im );
			delete  output_89;
		
			clear im scan;															%free up memory
			clc;																				%Clear command window
		end																						%End image loop
	end																							%End database loop
	%CLEAN UP ENVIRONMENT
	delete( 'dump', 'output', 'test_ind_scaled', 'test_ind' );
	save 'biqa_results.mat' result;									%HQ non-segmented images
	clear result db imgList_1 imgList_2 imgList_3;	%free up memory
end 																							%End function
		
			
