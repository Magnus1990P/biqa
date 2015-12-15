%  IRIS SCLERA CONTRAST
%outbound -> radius from center to bound between iris and sclera
%inbound  -> radius from center to bound between iris and pupil
%IRIS_SCLERA_CONTRAST -> The proportion of the irisa that is visible (in %)
function IRIS_SCLERA_CONTRAST = iso_isc( IMG, PUPIL, IRIS )
  delRad = floor(IRIS(1,3) - PUPIL(1,3));  %Radius, total radius is delRad+inbound
 
  %Size of rectangle for contrast sample
  RECT = 16;
  if delRad < 80
    RECT = 12;
  elseif delRad < 50
    RECT = 10;
  end
  
  %Retrieve iris-samples 4 LRTB
  DELTA = floor( PUPIL(1,3)*1.1 + RECT );
  IND   = floor( RECT*2+5 );
  iHLL = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)],       RECT );
  iHRR = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)],       RECT );
  iHFL = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA-IND , PUPIL(1,2)],       RECT );
  iHFR = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA+IND , PUPIL(1,2)],       RECT );
  iVTT = get_rect( 'b', IMG, [PUPIL(1,1) ,           PUPIL(1,2)-DELTA], RECT );
  iVBB = get_rect( 'b', IMG, [PUPIL(1,1) ,           PUPIL(1,2)+DELTA], RECT );
  iDLT = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)-DELTA], RECT );
  iDLB = get_rect( 'b', IMG, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)+DELTA], RECT );
  iDRT = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)-DELTA], RECT );
  iDRB = get_rect( 'b', IMG, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)+DELTA], RECT );
  
  %Gather sample sets and resize to 1D array
  iris = [iHLL; iHFL; iHRR; iHFR; iVTT; iVBB; ...
          iDLT; iDLB; iDRT; iDRB; ];
  %Median of iris
  irCon = median( median( iris ) );
    
  DELTA = floor( IRIS(1,3) * 1.1 + RECT );
  sHNL = get_rect( 'g', IMG, [IRIS(1,1)-DELTA ,     IRIS(1,2)],     RECT );
  sHFL = get_rect( 'g', IMG, [IRIS(1,1)-DELTA-IND,  IRIS(1,2)],     RECT );
  sHTL = get_rect( 'g', IMG, [IRIS(1,1)-DELTA,      IRIS(1,2)-IND], RECT );
  sHBL = get_rect( 'g', IMG, [IRIS(1,1)-DELTA,      IRIS(1,2)+IND], RECT );
  
  sHNR = get_rect( 'g', IMG, [IRIS(1,1)+DELTA ,     IRIS(1,2)],     RECT );
  sHFR = get_rect( 'g', IMG, [IRIS(1,1)+DELTA+IND , IRIS(1,2)],     RECT );
  sHTR = get_rect( 'g', IMG, [IRIS(1,1)+DELTA ,     IRIS(1,2)-IND], RECT );
  sHBR = get_rect( 'g', IMG, [IRIS(1,1)+DELTA ,     IRIS(1,2)+IND], RECT );
  sHRR = get_rect( 'g', IMG, [IRIS(1,1)+DELTA+IND,  IRIS(1,2)+IND], RECT );
  
  %Gather sample sets and resize to 1D array
  sclera = [sHNL; sHFL; sHTL; sHBL; ...
            sHNR; sHFR; sHTR; sHBR; sHRR;];
  %Median of sclera
  scCon = median( median( sclera ) );
  
  IRIS_SCLERA_CONTRAST = (double( abs(scCon-irCon) ) ) / ...
                         (double( (scCon+irCon) ) ) * 100;
  
  clear delRad iris sclera scCon irCon;
end
