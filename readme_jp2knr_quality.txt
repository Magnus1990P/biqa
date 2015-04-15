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

This software release consists of an implementation of the algorithm described in the paper:

H. R. Sheikh,  A. C. Bovik and L. Cormack, "No-Reference Quality
Assessment using Natural Scene Statistics: JPEG2000"., IEEE Transactions on Image Processing, (to appear).

It consists of the following files:

readme.txt: this file
jp2knr_quality.m: main function, call this to evaluate image quality
jointhist.m, image_wtransform.m, train_all.mat, hist2d.dll: support files used by the algorithm.
hist2d.c: source MEX file for hist2d.dll
hist2d.m_rename: a Matlab replacement for the hist2d.dll. rename it to hist2d.m if the dll file
does not work on your platform. The M file is quite slower than the dll, and also gives slightly
different results (possibly due to different bin-edge calculation) than the dll. The results 
reported in the paper are using the dll file. Results may be different (better or worse) with the 
M file.

Usage: jp2knr_qualiy(greyscale_image) will return a number. The higher the number, the higher the quality.
Please read the paper for more details on interpretation of the results.

Note on training: The file train_all.mat was generated using all JPEG2000 compressed images in the LIVE 
image quality database (http://live.ece.utexas.edu/research/quality)