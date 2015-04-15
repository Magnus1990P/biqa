function feature=gaufit_n1(c)
l=length(c);
%% CNSS features
aa=zeros(1,1);% amplitude
bb=zeros(1,1);% mean
cc1=zeros(1,1);% standard left
cc2=zeros(1,1);% standard right

mm=zeros(1,5);
dd=zeros(1,6); % feature SED
x=-50:0.1:50;
for n=0:0
    lv=l-n;
    ll=length(c{lv});
    f1=[];
    for i=1:ll
        f1=[f1;c{lv}{i}(:)];
    end
    f2=abs(f1);
    f=log10(f2);
    his=histc(f,x);
    nhis=his/sum(his);

    cfun=fit(x',nhis,'gauss1'); % gauss fit
    aa(n+1)=cfun.a1;
    bb(n+1)=cfun.b1;
    
    f = f-bb(n+1); % for asymmetric gauss fit, make it's 
    
    f_p = f(f>0);
    f_p = [f_p; f_p*(-1)]; %for fit of right
    f_n = f(f<0);
    f_n = [f_n; f_n*(-1)]; %for fit of left
    his=histc(f_p(:),x);
    nhis=his/(sum(his)+0.001);
    cfun=fit(x',nhis,'gauss1');
    cc1(n+1)=cfun.c1;
    his=histc(f_n(:),x);
    nhis=his/(sum(his)+0.001);
    cfun=fit(x',nhis,'gauss1');
    cc2(n+1)=cfun.c1;

end

for n=0:4  % for feature SED
    lv=l-n;
    ll=length(c{lv});
    f1=[];
    for i=1:ll
        f1=[f1;c{lv}{i}(:)];
    end
    f2=abs(f1);
    
    f=log10(f2);
    mm(n+1)=mean(f);
end
dd(1)=mm(2)-mm(1);
dd(2)=mm(3)-mm(2);
dd(3)=mm(4)-mm(3);
dd(4)=mm(5)-mm(4);
dd(5)=mm(3)-mm(1);
dd(6)=mm(4)-mm(2);



feature=[aa,bb,cc1,cc2,dd];
