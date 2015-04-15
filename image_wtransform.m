function wavetree=image_wtransform_multilev(yo, L, wname)

% -----------COPYRIGHT NOTICE STARTS WITH THIS LINE------------
% Copyright (c) 2003 The University of Texas at Austin
% All rights reserved.
% 
% Permission is hereby granted, without written agreement and without license or royalty fees, to use, copy, 
% modify, and distribute this code (the source files) and its documentation for
% any purpose, provided that the copyright notice in its entirety appear in all copies of this code, and the 
% original source of this code, Laboratory for Image and Video Engineering (LIVE, http://live.ece.utexas.edu)
% and Center for Perceptual Systems (CPS, http://www.cps.utexas.edu) at the University of Texas at Austin (UT Austin, 
% http://www.utexas.edu), is acknowledged in any publication that reports research using this code. The research
% is to be cited in the bibliography as:
% 
% H. R. Sheikh,  A. C. Bovik and L. Cormack, "No-Reference Quality
% Assessment using Natural Scene Statistics: JPEG2000"., IEEE Transactions on Image Processing, accepted April. 2004.
% 
% IN NO EVENT SHALL THE UNIVERSITY OF TEXAS AT AUSTIN BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, 
% OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS DATABASE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF TEXAS
% AT AUSTIN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% THE UNIVERSITY OF TEXAS AT AUSTIN SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE DATABASE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
% AND THE UNIVERSITY OF TEXAS AT AUSTIN HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
% 
% -----------COPYRIGHT NOTICE ENDS WITH THIS LINE------------


yo=yo./sqrt(mean(yo(:).^2)); % all images will now have rms pixel values = 1.0

% compute wlevs level wavelet transform
[lod,hid,lor,hir]=wfilters(wname);

[C,S]=wavedec2(yo,L,lod,hid);

% do abs 
C=abs(C);

wavetree=cell(4+(L-1)*3,1);

wavetree{1}=reshape(C(1:prod(S(1,:))), S(1,1), S(1,2));
offset=prod(S(1,:));
for i=1:L
    sizedetail=S(i+1,:);
    wavetree{(i-1)*3+2}=reshape(C(offset+1:offset+prod(sizedetail)), sizedetail(1),sizedetail(2)); %Horizontal details
    offset=offset+prod(sizedetail);
    
    wavetree{(i-1)*3+3}=reshape(C(offset+1:offset+prod(sizedetail)), sizedetail(1),sizedetail(2)); %Detail details
    offset=offset+prod(sizedetail);
    
    wavetree{(i-1)*3+4}=reshape(C(offset+1:offset+prod(sizedetail)), sizedetail(1),sizedetail(2)); %Diagonal details
    offset=offset+prod(sizedetail);
end

% select the center of each subband such that the sizes of subbands are simple powers of two multiples of the coarsest level
sznew=floor(S(end,:)./2^L);
temp=wavetree{1};
sz=size(temp);
offset=floor((sz-sznew)./2);
wavetree{1}=temp(offset(1)+1:offset(1)+sznew(1), offset(2)+1:offset(2)+sznew(2));
for i=1:L
    temp=wavetree{(i-1)*3+2};
    sz=size(temp);
    offset=floor((sz-sznew)./2);
    wavetree{(i-1)*3+2}=temp(offset(1)+1:offset(1)+sznew(1), offset(2)+1:offset(2)+sznew(2));
    
    temp=wavetree{(i-1)*3+3};
    wavetree{(i-1)*3+3}=temp(offset(1)+1:offset(1)+sznew(1), offset(2)+1:offset(2)+sznew(2));
    
    temp=wavetree{(i-1)*3+4};
    wavetree{(i-1)*3+4}=temp(offset(1)+1:offset(1)+sznew(1), offset(2)+1:offset(2)+sznew(2));
    sznew=sznew*2;
end

