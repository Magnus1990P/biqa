%  GREY SCALE UTILISATION - Above 30
%IMG0   ->  image in RGB format
%IRIS   ->  Iris information, center and radius
%PUPIL  ->  Pupil information, center and radius
%GREY_SCALE_UTILISATION -> The proportion of the iris that is viewable (in %)
function GREY_SCALE_UTILISATION  =  iso_gsu( IMG, PUPIL, IRIS )
  
  IMG1 = rgb2gray( IMG );
  pixel = zeros( 1, 257 );
  delRad = floor(IRIS(1,3) - PUPIL(1,3));  %Radius, total radius is delRad+inbound
  GREY_SCALE_UTILISATION = 0;
  
  %Size of rectangle for contrast sample
  RECT = 16;
  if delRad < 80
    RECT = 12;
  elseif delRad < 50
    RECT = 10;
  end
  
  %Retrieve iris-samples
  DELTA = floor( PUPIL(1,3) * 1.1 + RECT );
  iHLL = get_rect( 'b', IMG1, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)],       RECT );
  iHRR = get_rect( 'b', IMG1, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)],       RECT );
  iHFL = get_rect( 'b', IMG1, [PUPIL(1,1)-DELTA*1.5 , PUPIL(1,2)],       RECT );
  iHFR = get_rect( 'b', IMG1, [PUPIL(1,1)+DELTA*1.5 , PUPIL(1,2)],       RECT );
  iVTT = get_rect( 'b', IMG1, [PUPIL(1,1)       ,     PUPIL(1,2)-DELTA], RECT );
  iVBB = get_rect( 'b', IMG1, [PUPIL(1,1)       ,     PUPIL(1,2)+DELTA], RECT );
  iDLT = get_rect( 'b', IMG1, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)-DELTA], RECT );
  iDLB = get_rect( 'b', IMG1, [PUPIL(1,1)-DELTA ,     PUPIL(1,2)+DELTA], RECT );
  iDRT = get_rect( 'b', IMG1, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)-DELTA], RECT );
  iDRB = get_rect( 'b', IMG1, [PUPIL(1,1)+DELTA ,     PUPIL(1,2)+DELTA], RECT );
  
  %Correlate and reshape to 1D array
  iris = [ iHLL; iHRR; iHFL; iHFR; iVTT; iVBB; iDLT; iDLB; iDRT; iDRB; ];
  iris = reshape( iris, 1, (size(iris,1)*size(iris,2)) );
  
  for i=1:1:length(iris)
    x = iris(1, i) + 1; %Calc array index is value of cell plus 1
    pixel( 1, x ) = pixel( 1, x ) + 1;  %Increment value at index x
	end
  
	pixTot = size(iris,1)*size(iris,2);
	pixel = pixel / pixTot;
	
  for i=1:1:length(pixel)
    if pixel( 1, i ) > 0
			GREY_SCALE_UTILISATION = GREY_SCALE_UTILISATION   -   ...
                               ( pixel(1,i) * log2( pixel(1,i) ) );
    end
  end
  clear pixel iris IMG1;
end