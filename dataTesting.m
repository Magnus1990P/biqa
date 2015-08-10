%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dat = dataTesting( )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%		Variables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dat       = [];			%The returned information
    dataHQ 		= [];			%All HQ periocular data entries
    dataLQ  	= [];			%All LQ periocular data entries
    N					= 0;

    'Loading data'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%	Load the HQ data set
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		load 'hq_ns.mat';											%HQ non-segmented images
    for i=1:1:size( entry, 2 )
			dataHQ(i,1)  = entry(i).niqe;
      dataHQ(i,2)  = entry(i).brisque;
      dataHQ(i,3)  = entry(i).jp2knr;
      dataHQ(i,4)  = entry(i).biqi_jqs;
      dataHQ(i,5)  = entry(i).biqi_alg;
      dataHQ(i,6)  = entry(i).gsuFull;		%greyscale util. of entire image
      dataHQ(i,7)  = entry(i).gsuIris;		%greyscale util. of iris area
      dataHQ(i,8)  = entry(i).isc;       	%iris sclera contrast
      dataHQ(i,9)  = entry(i).pir;       	%Pupil iris ratio
      dataHQ(i,10) = entry(i).ipo;       	%iris pupil offset
      dataHQ(i,11) = entry(i).ipc;       	%iris pupil contrast
      dataHQ(i,12) = entry(i).ipcw;				%iris pupil contrast weber
      dataHQ(i,13) = entry(i).uia;      	%usable iris area
      dataHQ(i,14) = entry(i).pupilR;			%pupil radius
      dataHQ(i,15) = entry(i).irisR;			%iris radius
    end
    clear entry;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% Concatenate LQ data sets to one large dataset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for h=1:1:8
        if h==1
            load 'im_ns_ip_po_in_f.mat';
        elseif h==2
            load 'im_ns_ip_po_in_r.mat';
        elseif h==3
            load 'im_ns_ip_po_ou_f.mat';
        elseif h==4
            load 'im_ns_ip_po_ou_r.mat';
        elseif h==5
            load 'im_ns_sa_po_in_f.mat';
        elseif h==6
            load 'im_ns_sa_po_in_r.mat';
        elseif h==7
            load 'im_ns_sa_po_ou_f.mat';
        elseif h==8
            load 'im_ns_sa_po_ou_r.mat';
        end
        
        tmp = [];														%Initialise the variable
        for i=1:1:size( entry, 2 )
            tmp(i,1)  = entry(i).niqe;			%NIQE
            tmp(i,2)  = entry(i).brisque;		%BRISQUE
            tmp(i,3)  = entry(i).jp2knr;		%JP2KNR
            tmp(i,4)  = entry(i).biqi_jqs;	%BIQI
            tmp(i,5)  = entry(i).biqi_alg;	%BIQI
            tmp(i,6)  = entry(i).gsuFull;		%Greyscale util. of entire image
            tmp(i,7)  = entry(i).gsuIris;		%Greyscale util. of iris area
            tmp(i,8)  = entry(i).isc;				%Iris sclera contrast
            tmp(i,9)  = entry(i).pir;				%Pupil iris ratio
            tmp(i,10) = entry(i).ipo;				%Iris pupil offset
            tmp(i,11) = entry(i).ipc;				%Iris pupil contrast
            tmp(i,12) = entry(i).ipcw;			%Iris pupil contrast weber
            tmp(i,13) = entry(i).uia;				%Usable iris area
            tmp(i,14) = entry(i).pupilR;		%Pupil radius
            tmp(i,15) = entry(i).irisR;			%Iris radius
        end
        dataLQ = [dataLQ; tmp];						%Concat data sets
    end
    clear tmp, entry;										%Reset variables

    'Loading of data: Successfull'
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%	Initialisation of classification information
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'Initialising classification procedure'
		lenHQ = size( dataHQ, 1 );						%Length of HQ dataset
		lenLQ = size( dataLQ, 1 );						%Length of LQ dataset
		lenDT	= lenHQ + lenLQ;								%Length of HQ and LQ combined

    data 		= [ dataHQ; dataLQ ];					%Combine HQ and LQ datasets
    label( 1 : lenHQ, 1) = 'G';           %Label HQ images
    label( lenHQ+1 : lenDT, 1)		= 'B';	%Label LQ images
    species = cellstr( label );         	%Create species2
    groups 	= ismember( species,	  'G'); %Set HQ images to 1 and LQ to 0
    cp 			= classperf( groups );				%
    
		N   		= lenLQ;											%Number of LQ entries
    'initialisation done'
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%	Training classifier
		%%		Vary proportion of HQ and LQ entries
		%%			10%-90% LQ and 90%-10%HQ
		%%		Fixed amount of 52 HQ data entries, LQ set size is varied
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for prop=10:10:90													%Proportion of LQ entries to HQ
      strcat('Starting trianing for: ', int2str(prop), '%')
      ret = [];																%Ret variable holding X results
      k   = floor((lenHQ/(100-prop))*prop);		%Calc num LQ images for training
    
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%	Generate statistics for classifier
    	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i=1:1:1:1000													%Get res from x runs
        set = reshape( randperm(N, k), k, 1) + lenHQ; 		%Create matrix

																													%Create training set
        train = logical( zeros( lenDT, 1 ) );							%Create matrix of 0's
        train( 1:lenHQ, 1 ) 			= logical( 1 );					%Set HQ entries and 
        train( set, 1 ) 					= logical( 1 );					%set entries to 1

																													%Create test set
        test  = logical( zeros( lenDT, 1 ) );							%Set test to 0
        test( lenHQ+1:lenDT, 1 )	= logical( 1 );					%Set LQs to 1 and
        test(  set, 1 ) 					= logical( 0 );					%train set to 0

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%	Create and train SVM classifier
				%%		Use the test set of X% LQ entries
    		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        svmStruct = svmtrain(   data(train,:) ,             ...
                                groups(train) ,             ...
                                'showplot', false,          ...
                                'kernel_function', 'rbf');

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%	Test the classifier on test set
    		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        classes = svmclassify(  svmStruct,                  ...
                                data(test, :) ,             ...
                                'showplot', false);

        ret(1, i) = sum(classes);										%Sum el classified as good
      end
      'Training ended'
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%	Aggregate return data
    	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			testPerc = 100 / sum(test);
			
			tmp = [														...	
							min(ret),   							...
							max(ret),									...
							median(ret),							...
							mean( ret ),							...
							mode( ret ),							...
							min(ret)    * testPerc,   ...
							max(ret)    * testPerc,		...
							median(ret) * testPerc,		...
							mean( ret ) * testPerc,		...
							mode( ret ) * testPerc,		...
							sum( train ), 						...
							sum( test  ),  						...
							prop,											...
							100-prop									...
						];
			
			dat = [dat; tmp];
      'Data calculated'
		end

end                    
