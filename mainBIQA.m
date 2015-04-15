%%%%
%%	
%%	
%%	
%%%%

%Maximum image width
maxImgWidth=500;

%Load NIQE IQA requirements
load modelparameters.mat
blk_size_r = 32;
blk_size_c = 32;
blk_row_ol = 0;
blk_col_ol = 0;

%Add library to path
addpath('./fdct_usfft_matlab/');

%Iterate through all databases
for fCount=1:1:18
	imgdb = [];
	%%%%Segmented images
	if fCount == 1
		im_sn_ip_po_in_f;
	elseif fCount == 2
		im_sn_ip_po_in_r;
	elseif fCount == 3
		im_sn_ip_po_ou_f;
	elseif fCount == 4
		im_sn_ip_po_ou_r;
	elseif fCount == 5
		im_sn_sa_po_in_f;
	elseif fCount == 6
		im_sn_sa_po_in_r;
	elseif fCount == 7
		im_sn_sa_po_ou_f;
	elseif fCount == 8
		im_sn_sa_po_ou_r;
		
	elseif fCount == 9	%Good quality
		hq_sn;
		
	%%%%Non-segmented images
	elseif fCount == 10
		im_ns_ip_po_in_f;
	elseif fCount == 11
		im_ns_ip_po_in_r;
	elseif fCount == 12
		im_ns_ip_po_ou_f;
	elseif fCount == 13
		im_ns_ip_po_ou_r;
	elseif fCount == 14
		im_ns_sa_po_in_f;
	elseif fCount == 15
		im_ns_sa_po_in_r;
	elseif fCount == 16
		im_ns_sa_po_ou_f;
	elseif fCount == 17
		im_ns_sa_po_ou_r;
	
	elseif fCount == 18	%Good Quality
		hq_ns;
	end
	
	%Create structure to hold data for the database
	entry = struct();
	%Calculate height of image database
	MH  = size( imgdb, 1 );

	%Loop through images in image database
	for IC = 1:1:MH
		%LOAD CURRENT IMAGE and save filename
		im = imread( imgdb( IC, : ) );
		if size(im,2) > maxImgWidth
			scale = double(maxImgWidth) / double(size (im,2));
			im = imresize( im, scale );
		end
		entry(IC).fname = imgdb( IC, : );
		
		
		if fCount >= 10
	    %find_iris locates iris and pupil if not found it returns an empty array
		  scan = find_iris( im );
		  %If iris and pupil located
		  if isempty(scan)==0
			  entry(IC).irisX  = scan(1,1);		entry(IC).irisY  = scan(1,2);
	  		entry(IC).irisR  = scan(1,3);  	entry(IC).pupilX = scan(1,4);
			  entry(IC).pupilY = scan(1,5);		entry(IC).pupilR = scan(1,6);

	  		%Calculate ISO-metrics
		  	entry(IC).uia			= iso_uia(		scan(1,3)   , scan(1,6)   );
			  
				entry(IC).gsuIris = iso_gsu(im,	scan(1,4:6) , scan(1,1:3) );
  			
				[entry(IC).ipcw, entry(IC).ipc]	...
	  											= iso_ipc(im,	scan(1,4:6) , scan(1,1:3) );
		  	
			  entry(IC).isc			= iso_isc(im,	scan(1,4:6) , scan(1,1:3) );
				
				%Pupil to Iris Ratio
				entry(IC).pir     = (scan(1,6) / scan(1,3)) * 100;
				
				%Iris_Pupil Concentricity ( the centric offset between iris and pupil)
				entry(IC).ipo     = sqrt( (scan(1,1)-scan(1,4))^2   +							...
					                        (scan(1,2)-scan(1,5))^2   ) / scan(1,3);
				
			  entry(IC).lma = (scan(1,1)  - scan(1,3) ) / scan(1,3);
			  entry(IC).rma = (size(im,2) - ( scan(1,1) + scan(1,3) ) ) / scan(1,3);
			  entry(IC).dma = (size(im,1) - ( scan(1,2) + scan(1,3) ) ) / scan(1,3);
			  entry(IC).uma = (scan(1,2)  - scan(1,3) ) / scan(1,3);
				
				
		  %if iris is not located
			else
  			entry(IC).irisX  = -1;	entry(IC).irisY   = -1;	entry(IC).irisR  = -1;
			  entry(IC).pupilX = -1;	entry(IC).pupilY  = -1;	entry(IC).pupilR = -1;
		  	entry(IC).uia    = -1;	entry(IC).gsuIris = -1;	entry(IC).ipc    = -1;
	  		entry(IC).ipcw   = -1;	entry(IC).isc     = -1;	entry(IC).pir    = -1;
				entry(IC).ipo    = -1;  entry(IC).lma		  = -1;	entry(IC).rma		 = -1;
				entry(IC).dma		 = -1;  entry(IC).uma		  = -1;
			end
		end
		
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
			
		if fCount < 10	%calc gsu for segmented image (just iris)
			entry(IC).gsuIris = GREY_SCALE_UTILISATION;
		else						%calc gsu for entire image (periocular)
			entry(IC).gsuFull = GREY_SCALE_UTILISATION;
		end
		
		%RUN IQA FUNCTIONS AND STORE IN QUALITY ASSESSMENT MATRIX
		%NIQE - Low is good
		entry(IC).niqe = computequality(	im,							...
																			blk_size_r,			...
																			blk_size_c,			...
																			blk_row_ol,			...
																			blk_col_ol,			...
																			mu_prisparam,		...
																			cov_prisparam			);

		%BRISQUE - Low is good
		entry(IC).brisque		=	brisquescore( im );

		%jp2knr_quality - High is good
		entry(IC).jp2knr		=	jp2knr_quality( im );

		%BIQI - jpeg_quality_score
		entry(IC).biqi_jqs	= jpeg_quality_score( double(im) );
		delete output;
		%BIQI - biqi algorithm
		entry(IC).biqi_alg	= biqi( im );
		delete  output_89;
		
		clear im scan;	%free up memory
		clc							%Clear command window
		imgdb( IC, : )	%Print name of image currently checked
		[ IC, MH ]			%Print index of image and last index
	end
	
	%CLEAN UP ENVIRONMENT
	delete( 'dump', 'output', 'test_ind_scaled', 'test_ind' );
	clear imgdb;			%free up memory
	
	%Save structure to file
	if fCount == 1
		save 'im_sn_ip_po_in_f.mat' entry;
	elseif fCount == 2
		save 'im_sn_ip_po_in_r.mat' entry;
	elseif fCount == 3
		save 'im_sn_ip_po_ou_f.mat' entry;
	elseif fCount == 4
		save 'im_sn_ip_po_ou_r.mat' entry;
	elseif fCount == 5
		save 'im_sn_sa_po_in_f.mat' entry;
	elseif fCount == 6
		save 'im_sn_sa_po_in_r.mat' entry;
	elseif fCount == 7
		save 'im_sn_sa_po_ou_f.mat' entry;
	elseif fCount == 8
		save 'im_sn_sa_po_ou_r.mat' entry;
	elseif fCount == 9
		save 'hq_sn.mat' entry;							%HQ segmented images
		
	elseif fCount == 10
		save 'im_ns_ip_po_in_f.mat' entry;
	elseif fCount == 11
		save 'im_ns_ip_po_in_r.mat' entry;
	elseif fCount == 12
		save 'im_ns_ip_po_ou_f.mat' entry;
	elseif fCount == 13
		save 'im_ns_ip_po_ou_r.mat' entry;
	elseif fCount == 14
		save 'im_ns_sa_po_in_f.mat' entry;
	elseif fCount == 15
		save 'im_ns_sa_po_in_r.mat' entry;
	elseif fCount == 16
		save 'im_ns_sa_po_ou_f.mat' entry;
	elseif fCount == 17
		save 'im_ns_sa_po_ou_r.mat' entry;
	elseif fCount == 18
		save 'hq_ns.mat' entry;							%HQ non-segmented images
	end
	
	clear entry;		%Free up memory
end
