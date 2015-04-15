function ans = find_iris( im )
  R = size( im, 1 );
  C = size( im, 2 );
 
	Rmax      = floor( C * 0.4 );
  Rmin      = floor( C * 0.1 );
  i         = Rmin;
  irisstep  = 10;
  pupilstep = 10;
  
  CIY=0; CIX=0; CIR=0; CPY=0; CPX=0; CPR=C; DPY=C;

  while i<=Rmax
    radiusIris = [i, i+irisstep];
    
       %FIND IRIS (LARGE DARK DIFFUSE CIRCLE)
    [irisCent, irisRad] = imfindcircles(im, radiusIris,            ...
                                        'ObjectPolarity', 'dark',  ...
                                        'Sensitivity',    0.98);
    
       %IF irisCent is empty, skip ahead to next size scan
    if isempty( irisCent ) == 0
      
      for j=1:1:size(irisCent, 1)
        iy = irisCent( j, 2 );
        ix = irisCent( j, 1 );
        ir = irisRad(  j, 1 );
        
        if ((iy-ir) <= ir) || ((ix-ir) <= 0+ir) || ...
           ((iy+ir) >  R-ir) || ((ix+ir) >  C-ir)
          continue;
        end
        
            %Define min/max radius of pupil
        prmax = floor( ir*0.35 );
        prmin = floor( ir*0.05 );
        if prmin < 10
          prmin = 10;
        end
        k=prmax;
        
            %Iterate through the pupil radius' to find the smallest
        while k>prmin
          if k-pupilstep > prmin
            k=k-pupilstep;
          else
            k=prmin;
          end
          radiusPup = [k, k+pupilstep];
          [pupCent, pupRad] = imfindcircles(im, radiusPup,            ...
                                           'ObjectPolarity', 'dark',  ...
                                           'Sensitivity',    0.99 );
          
          for l=1:1:size(pupRad,1)
            py = pupCent(l,2 );
            px = pupCent(l,1 );
            pr = pupRad( l,1 );
            
            dpy = sqrt(abs(iy-py)^2 + abs(ix-px)^2);
            if dpy < ir*0.7		&& ir > pr		&& ...
							 px-pr < ix			&& ix < px+pr	&& ...
							 py-pr < iy			&& iy < py+pr
						 
              DPY=dpy;
              CIY=iy; CIX=ix; CIR=ir;
              CPY=py; CPX=px; CPR=pr;
            end
          end
        end
      end
    end
    
    i = i+irisstep;
  end
  
  %{%
  if CPR < CIR
    hold off
    imshow( im );
    drawnow, hold on
    
    viscircles( [CPX,CPY], CPR, 'EdgeColor', 'y');
    plot(CPX, CPY, 'y+');
    drawnow
    
    plot(CIX+CIR, CIY+CIR, 'r+');
    plot(CIX+CIR, CIY-CIR, 'r+');
    plot(CIX-CIR, CIY+CIR, 'r+');
    plot(CIX-CIR, CIY-CIR, 'r+');
    plot(CIX,     CIY,    'r+');
    viscircles([CIX, CIY], CIR, 'EdgeColor', 'r');
    drawnow
  end
  %}
  
  ans = [];
  if CPR < CIR
    ans = [floor(CIX), floor(CIY), floor(CIR), ...
           floor(CPX), floor(CPY), floor(CPR) ];
  end
end