% USABLE IRIS AREA
%occluded         -> Radius of pupil, px
%iris             -> Radius of iris, px
%USABLE_IRIS_AREA -> The proportion of the irisa that is viewable (in %)
function USABLE_IRIS_AREA = iso_uia( iris, pupil)
    
  irisArea  = 3.14 * ( double(iris) ^ 2);
  pupilArea = 3.14 * ( double(pupil) ^ 2);
    
  USABLE_IRIS_AREA = ( 1 - ( pupilArea / irisArea ) ) * 100;
end