function ans = pokemon( type, num )
    %DATA SETS
    ans = [];
    good_data=[];
    bad_data =[];
    
    good_seg = [];
    good_per = [];
    bad_seg  = [];
    bad_per  = [];
    
    %good seg
    load 'hq_sn.mat';							%HQ segmented images
    tmp = zeros(size(entry,2), 6);
    for i=1:1:size(entry,2)
      tmp(i,1)  = entry(i).niqe;
      tmp(i,2)  = entry(i).brisque;
      tmp(i,3)  = entry(i).jp2knr;
      tmp(i,4)  = entry(i).biqi_jqs;
      tmp(i,5)  = entry(i).biqi_alg;
      tmp(i,6)  = entry(i).gsuIris;		%greyscale utilisation in iris area
    end
    good_seg = tmp;
    clear tmp;

    %bad seg
    for h=1:1:8
        if h==1
            load 'im_sn_ip_po_in_f.mat';
        elseif h==2
            load 'im_sn_ip_po_in_r.mat';
        elseif h==3
            load 'im_sn_ip_po_ou_f.mat';
        elseif h==4
            load 'im_sn_ip_po_ou_r.mat';
        elseif h==5
            load 'im_sn_sa_po_in_f.mat';
        elseif h==6
            load 'im_sn_sa_po_in_r.mat';
        elseif h==7
            load 'im_sn_sa_po_ou_f.mat';
        elseif h==8
            load 'im_sn_sa_po_ou_r.mat';
        end
        tmp = zeros(size(entry,2), 6);
        for i=1:1:size(entry,2)
            tmp(i,1)  = entry(i).niqe;
            tmp(i,2)  = entry(i).brisque;
            tmp(i,3)  = entry(i).jp2knr;
            tmp(i,4)  = entry(i).biqi_jqs;
            tmp(i,5)  = entry(i).biqi_alg;
            tmp(i,6)  = entry(i).gsuIris;		%greyscale utilisation in iris area
        end
        bad_seg = [bad_seg; tmp];
        clear tmp;
    end
    
    %good peri
    load 'hq_ns.mat';							%HQ non-segmented images
    tmp = zeros(size(entry,2), num);
    for i=1:1:size(entry,2)
        tmp(i,1)  = entry(i).niqe;
        tmp(i,2)  = entry(i).brisque;
        tmp(i,3)  = entry(i).jp2knr;
        tmp(i,4)  = entry(i).biqi_jqs;
        tmp(i,5)  = entry(i).biqi_alg;
        tmp(i,6)  = entry(i).gsuFull;		%greyscale utilisation in entire image
        
        if num == 15
            tmp(i,7)  = entry(i).gsuIris;		%greyscale utilisation in iris area
            tmp(i,8)  = entry(i).isc;			%iris sclera contrast
            tmp(i,9)  = entry(i).pir;			%Pupil iris ratio
            tmp(i,10) = entry(i).ipo;			%iris pupil offset
            tmp(i,11) = entry(i).ipc;			%iris pupil contrast
            tmp(i,12) = entry(i).ipcw;			%iris pupil contrast weber
            tmp(i,13) = entry(i).uia;			%usable iris area
            tmp(i,14) = entry(i).pupilR;		%pupil radius
            tmp(i,15) = entry(i).irisR;			%iris radius
        end
    end
    good_per = tmp;
    clear tmp;


    %bad periocular
    for h=1:1:8
        if i==1
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

        tmp = zeros(size(entry,2), num);

        for i=1:1:size(entry,2)
            tmp(i,1)  = entry(i).niqe;
            tmp(i,2)  = entry(i).brisque;
            tmp(i,3)  = entry(i).jp2knr;
            tmp(i,4)  = entry(i).biqi_jqs;
            tmp(i,5)  = entry(i).biqi_alg;
            tmp(i,6)  = entry(i).gsuFull;	%greyscale utilisation in entire image
            
            if num == 15
                tmp(i,7)  = entry(i).gsuIris;	%greyscale utilisation in iris area
                tmp(i,8)  = entry(i).isc;		%iris sclera contrast
                tmp(i,9)  = entry(i).pir;		%Pupil iris ratio
                tmp(i,10) = entry(i).ipo;		%iris pupil offset
                tmp(i,11) = entry(i).ipc;		%iris pupil contrast
                tmp(i,12) = entry(i).ipcw;		%iris pupil contrast weber
                tmp(i,13) = entry(i).uia;		%usable iris area
                tmp(i,14) = entry(i).pupilR;	%pupil radius
                tmp(i,15) = entry(i).irisR;		%iris radius
            end
        end
        bad_per = [bad_per; tmp];
        clear tmp;
    end
    clear entry h i;
    
    %Load data based on input parameter
    if strcmp(type, 'per')
      good_data = good_per; 
      bad_data  = bad_per;
    else
      good_data = good_seg; 
      bad_data  = bad_seg;
    end
    
    data = [ good_data; bad_data];
    label( 1 : size(good_data,1), 1) = 'G';              %Label good images
    label(size(good_data,1)+1 : size(data,1), 1)	= 'B';  %Label bad images

    species = cellstr( label );         %create species
    groups = ismember( species,	  'G'); %Set good images to 1 and bad to 0

    cp = classperf( groups );

        %max number to use
    N   = size(data,1) - size(good_data, 1);
    
    for prop=0.2:0.1:0.9
        %Holder for values
      ret = zeros(1, 100);
      %k number of images relative to the proportion for training
      k   = floor( N * prop );
      
      for i=1:1:100
          %create x height by 1 width matrix
        set = reshape( randperm(N, k), k, 1) + size(good_data, 1);

          %zero out training set
        train = logical( zeros( size( data, 1 ), 1 ) );
          %mark HQ images for training - set to 1
        train( 1:size( good_data, 1 ), 1 ) = logical( 1 );
          %Mark LQ images for training - set to 1
        train( set, 1 ) = logical( 1 );

          %Fill testing set with 0's
        test  = logical( zeros( size( data, 1 ), 1 ) );
          %set all LQ images for testing - fill with 1's
        test(size(good_data,1)+1:size(data,1), 1 ) = logical( 1 );
          %remove training images for test set - set to 0
        test(  set, 1 ) = logical( 0 );

        %Train the classifier on the training set
        svmStruct = svmtrain(   data(train,:) ,             ...
                                groups(train) ,             ...
                                'showplot', false,          ...
                                'kernel_function', 'rbf');

        %Run the classifier on the testing set
        classes = svmclassify(  svmStruct,                  ...
                                data(test, :) ,             ...
                                'showplot', false);
        ret(1, i) = sum(classes);
      end
      ans = [ans;                               ...
            [floor(prop*100),                   ...
            min(ret)*100/sum(test),             ...
            median(ret)*100/sum(test),          ...
            round(mean(ret),1)*100/sum(test),   ...
            mode(ret)*100/sum(test),            ...
            max(ret)*100/sum(test),             ...
            sum(train),                         ...
            sum(test)]                          ...
          ];
    end
end                    