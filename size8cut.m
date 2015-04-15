function Y=size8cut(X) % cut the rim of the image, to make it more fit to be cut into 256*256 patches
  [m,n] = size(X);
  if mod(m,8)~=0
      X=X(1:m-mod(m,8),:);
  end
  if mod(n,8)~=0
      X=X(:,1:n-mod(n,8));
  end
  Y=X;
end