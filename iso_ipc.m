%  IRIS PUPIL CONTRAST - Above 30
%IMG   -> RGB image
%PUPIL -> Center and radius of pupil
%IRIS  -> Center and radius of iris
%IRIS_PUPIL_CONTRAST -> The proportion of the irisa that is viewable (in %)
function [IRIS_PUPIL_CONTRAST, CONTRAST]  = iso_ipc( IMG, PUPIL, IRIS )
  delRad = floor(double(IRIS(1,3)) - double(PUPIL(1,3)));
  
  %Size of rectangle for contrast sample
  RECT = 16;
  if delRad < 80
    RECT = 12;
  elseif delRad < 50
    RECT = 10;
  end
  
  %Retrieve iris-samples 4 LRTB
  DELTA = floor( PUPIL(1,3)*1.1 + RECT );
  iHLL = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA , PUPIL(1,2)],       RECT );
  iHRR = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA , PUPIL(1,2)],       RECT );
  iVTT = get_rect( 'b', IMG, [PUPIL(1,1)       , PUPIL(1,2)-DELTA], RECT );
  iVBB = get_rect( 'b', IMG, [PUPIL(1,1)       , PUPIL(1,2)+DELTA], RECT );
  iDLT = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA , PUPIL(1,2)-DELTA], RECT );
  iDLB = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA , PUPIL(1,2)+DELTA], RECT );
  iDRT = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA , PUPIL(1,2)-DELTA], RECT );
  iDRB = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA , PUPIL(1,2)+DELTA], RECT );
  
  %Gather sample sets and resize to 1D array
  iris = [iHLL; iHRR; iVTT; iVBB; iDLT; iDLB; iDRT; iDRB; ];
  irCon = median( median( iris ) );
  
  %Gather sample sets and resize to 1D array
  pupil = get_rect( 'g', IMG, [PUPIL(1,1), PUPIL(1,2)], RECT );
  puCon = median( median( pupil ) );
  
  %Calculate contrast normally
  CONTRAST = abs( double(irCon)-double(puCon) ) / ...
                  double( (irCon + puCon) ) * 100;
              
  %Calculate WEBER Contrast
  WEBER =  abs( double(irCon) - double(puCon) ) / double(1 + puCon);
  IRIS_PUPIL_CONTRAST = ( double(WEBER) / double(0.75+WEBER) ) * 100;
  
  clear delRad iris pupil;
end