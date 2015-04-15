function q=jp2knr_quality(img)

% img is grayscale image compressed by jpeg2000 (or uncompressed)

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
% Assessment using Natural Scene Statistics: JPEG2000"., IEEE Transactions on Image Processing, (to appear).
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


wname='bior4.4';
L=4;  % tested only for L=4. Some parts of the code may be hard-coded for L=4
load train_all

if size(img, 3) == 3
	img = rgb2gray( img );
end

wavetree=image_wtransform(img,L, wname);
imh=jointhist(wavetree);
for j=1:13
    temp=wavetree{j};,temp=(abs(temp(:)));,temp(temp==0)=min(nonzeros(temp));,temp=log2(temp);
    u(j)=mean(temp);,s(j)=std(temp);, ss(j)=s(j).^2;
end

th_off_P=th_off(1);, th_off_C=th_off(2);
p=binarized_params_img(m_uu, th_off_P, th_off_C, u, imh);

p=p(:,3:4:end);

fitfun=inline('t(1).*(1-exp(-(x-t(2))./t(3)))','t','x');

q=zeros(size(p));
for i=1:6
q(i)=fitfun(t(:,i),p(i));
end

%combine subbands
q=[mean(q(1:2)) q(3) mean(q(4:5)) q(6)];

%weighted average
q=q*w;


function p=binarized_params_img(m_uu, th_off_P, th_off_C, u, imh)
% convert threhsolds into indices of histogram
temp=linspace(-25,5,126);


% compute image dependentthresholds
uc = (u(2:end))';
uc=([mean(uc(1:2)); uc(3); mean(uc(4:5)); uc(6); mean(uc(7:8)); uc(9); mean(uc(10:11)); uc(12)]); % combine h-v

% calculate prediction for subband means from upper subbands
% fit line from coarser levels
t=ones(4,1)\(uc(1:4)-m_uu*(1:4)'); %fit lines, only the y-intercept

u_pred=[(1:8)' ones(8,1)]*[m_uu;t];
th1=u_pred([5 5 6 7 7 8])+th_off_P; %rhresholds for P
th2=u_pred([5 5 6 7 7 8])+th_off_C;

thresh=zeros(1,length(th1)*2);

% see below as to how the code expects the thresholds
thresh(2:2:end)=th2;
thresh(1:2:end)=th1;


% change threshold to index
for j=1:length(thresh)
    thresh(j)=max(find(thresh(j) > temp));
end


imh=imh(4:9,:,:); % lowest two detail levels
% 2nd finest
Tv=thresh(1);, Th=thresh(2);% Tv is threshold on P, Th is threshold on C
pii=sum(sum(squeeze(imh(1,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(1,1:Th,Tv+1:end)))); % C is insig and P is sig
pss=sum(sum(squeeze(imh(1,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(1,Th+1:end,1:Tv)))); % P is insig and C is sig
ph2=[pii pis pss psi];

Tv=thresh(3);, Th=thresh(4);
pii=sum(sum(squeeze(imh(2,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(2,1:Th,Tv+1:end))));
pss=sum(sum(squeeze(imh(2,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(2,Th+1:end,1:Tv))));
pv2=[pii pis pss psi];

Tv=thresh(5);, Th=thresh(6);
pii=sum(sum(squeeze(imh(3,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(3,1:Th,Tv+1:end))));
pss=sum(sum(squeeze(imh(3,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(3,Th+1:end,1:Tv))));
pd2=[pii pis pss psi];

% finest
Tv=thresh(7);, Th=thresh(8);
pii=sum(sum(squeeze(imh(4,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(4,1:Th,Tv+1:end))));
pss=sum(sum(squeeze(imh(4,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(4,Th+1:end,1:Tv))));
ph1=[pii pis pss psi];

Tv=thresh(9);, Th=thresh(10);
pii=sum(sum(squeeze(imh(5,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(5,1:Th,Tv+1:end))));
pss=sum(sum(squeeze(imh(5,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(5,Th+1:end,1:Tv))));
pv1=[pii pis pss psi];

Tv=thresh(11);, Th=thresh(12);
pii=sum(sum(squeeze(imh(6,1:Th,1:Tv))));
psi=sum(sum(squeeze(imh(6,1:Th,Tv+1:end))));
pss=sum(sum(squeeze(imh(6,Th+1:end,Tv+1:end))));
pis=sum(sum(squeeze(imh(6,Th+1:end,1:Tv))));
pd1=[pii pis pss psi];

p=[ph2 pv2 pd2 ph1 pv1 pd1];

