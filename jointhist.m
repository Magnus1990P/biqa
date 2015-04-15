function hh=jointhist(wavetree)
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


L=4;
Nbins=128;
hh=zeros(3*(L-1),Nbins,Nbins);

for level=L:-1:2
    for orientation=1:3
        numparents=level-1;
        C = wavetree{1+(level-1)*3+orientation};
        % extend C symmetrically by one pixel for windowing 
        C=[C(1,:); C; C(end,:)];, C=[C(:,1) C C(:,end)];
        
        rows=size(C,1);
        cols=size(C,2);
        
        qs=[]; % coefficients to form prediction
        cs=[]; % these will be predicted from qs
        
        
        % assemble coefficients that will make the prediction
        rowindices=1:size(C,1)-2;
        colindices=1:size(C,2)-2;
        
        % indices of prediction coeffs in the same level.
        % 1 4 7
        % 2 X 8
        % 3 6 9
        ind=[2 4 6 8];
        for i=1:length(ind)
            rowoff=mod(ind(i)-1,3);
            coloff=floor((ind(i)-1)./3);
            temp=C(rowindices+rowoff, colindices+coloff);
            qs=cat(1,qs,temp(:)');
        end
        
        
        for i=1:numparents % assemble from parents!
            temp = imresize(wavetree{1+(level-i-1)*3+orientation}, 2^i, 'nearest');
            qs=cat(1,qs,temp(:)');
        end
        
        
        temp=C(2:end-1,2:end-1);
        cs=temp(:)';
        
        w=qs'\cs'; % prediction weights
        lq=(qs'*w)'; % do predictions
        
        
        %         % clip to strictly positive values, else log will screw up! the predictor could go negative!
        lq(lq <= 0) = min(lq(lq>0));
        
        % calculate and save the error in prediction
        lcs=log2(cs); % log of coef
        llq=log2(lq); % log of prediction
        
        
        % construct 2d conditional histogram
        xmin=-25;, xmax=5;, ymin=-25;,  ymax=5;
        
        % plot 2d pdf
        h=hist2d(llq,lcs,Nbins,xmin,xmax,ymin,ymax);
        
        % convert to 2d pdf
        h=h./sum(h(:));
        hh((level-2)*3+orientation,:,:)=h;
    end
end