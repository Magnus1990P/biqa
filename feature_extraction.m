function f = feature_extraction( imdist, scale )
    f=[];
    %imdist=rgb2gray(imdist);
    weight=[0.2 0.8];
    for i=1:scale
        im=imdist;
        fun0=@(x)secal(x);
        emat=blockproc(im, fun0, [8 8]); 

        sort_t = sort(emat(:),'ascend');
        len = length(sort_t);
        t=sort_t(ceil(len*weight(1)):ceil(len*weight(2)));
        mu= mean(t);
        ske=skewness(sort_t);
        
        f1=[ mu  ske];

        im=imdist;
        fun1=@(x)fecal(x);
        im=double(im);
        femat=blockproc(im, fun1, [8 8]);

        sort_t = sort(femat(:),'ascend');
        len = length(sort_t);
        t=sort_t(ceil(len*weight(1)):ceil(len*weight(2)));
        mu= mean(t);
        ske=skewness(sort_t);
   
        f2=[ mu  ske];

        f=[f f1 f2] ;
        
        imdist = imresize(imdist,0.5);
    end
end

