CurveletQA Software release.

=======================================================================

This is a demonstration of No-reference image quality assessment in curvelet domain. The algorithm is described in:

L. Liu, H. Dong, H. Huang, and A. C. Bovik, "No-reference image quality assessment in curvelet domain". Signal Processing: Image Communication, 2014. 

=======================================================================
Running on Matlab 

Input : A test image loaded in an array

Output: the feature of test image.
  
Usage:

1. Load the image, for example

   image     = imread('testimage1.bmp'); 

2. tranform the colour image into gray image

   image     = rgb2gray(image); 

3. Call this function to calculate the feature:

   image_feature = feature_extract(image);

Sample execution is also shown through example.m


=======================================================================

MATLAB files: example.m, feature_extract.m, gaufit_n1.m, kurtosis2.m, ori_info3.m, size8cut.m, preprocess5.m and fdct_usfft_matlab folder which is original curvelet transformation from "Fast Discrete Curvelet Transforms"(available at : http://www.curvelet.org).

=======================================================================
 