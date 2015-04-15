function blkim=preprocess5(im)

% cut the image into image patch with 256*256 size

[m n]=size(im);
i=ceil(m/256);
j=ceil(n/256);
blkim=cell(i,j);
overlap_m=(i*256-m)/(i-1);%compute the overlap between the patches
overlap_n=(j*256-n)/(j-1);
if mod(overlap_m,8)~=0
    for count=1:32
        m=m-8;
        i=ceil(m/256);
        overlap_m=(i*256-m)/(i-1);
        if mod(overlap_m,8)==0
            break;
        end
    end
end
if mod(overlap_n,8)~=0
    for count=1:32
        n=n-8;
        j=ceil(n/256);
        overlap_n=(j*256-n)/(j-1);
        if mod(overlap_n,8)==0
            break;
        end
    end
end
im=im(1:m,1:n);
for ii=1:i
    for jj=1:j
        blkim{ii,jj}=im((256-overlap_m)*(ii-1)+1:(256-overlap_m)*(ii-1)+256,(256-overlap_n)*(jj-1)+1:(256-overlap_n)*(jj-1)+256);
    end
end
return;
end

        