function k=kurtosis2(x) %get the energy feature
l=length(x);
x=x./sum(x);
mu=0;
mu_2=0;
for i=1:l
    mu=mu+i*x(i);
    mu_2=mu_2+i^2*x(i);
end
sigma=mu_2-mu^2;
m4=0;
for i=1:l
    m4=m4+(i-mu)^4*x(i);
end
k=m4/sigma^2;

    
