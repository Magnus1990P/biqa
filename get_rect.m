function rect = get_rect( col, IMG, CENTER, DELTA )
  [Y,X,Z] = size( IMG );
  
  %L, R, T, B
  COORD = [ floor(CENTER(1,1)-DELTA) , ...
            floor(CENTER(1,1)+DELTA) , ...
            floor(CENTER(1,2)-DELTA) , ...
            floor(CENTER(1,2)+DELTA) , ...
          ];
    
  %LEFT
  if COORD(1,1) >= 1 && COORD(1,2) <= X && ...
     COORD(1,3) >= 1 && COORD(1,4) <= Y
    rect = IMG( COORD(1,3):COORD(1,4) , COORD(1,1):COORD(1,2) );
  else
    rect = [];
  end
end
