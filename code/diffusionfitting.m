%bin = 0:1:20;
%bin=
%figure(11)
siz=size(Raws);
siz1=siz(1)/10;

for i1=1:siz1 
    Raw(:,1)=Raws(((i1-1)*100+1):(i1*100),1);
    Raw(:,2)=Raws(((i1-1)*100+1):(i1*100),2);
    Raw(:,3)=Raws(((i1-1)*100+1):(i1*100),3);
    Raw(:,4)=Raws(((i1-1)*100+1):(i1*100),4);

Raw(:,1)=Raw(:,1)-mean(Raw(:,1));
Raw(:,2)=Raw(:,2)-mean(Raw(:,2));
Raw(:,3)=Raw(:,3)-mean(Raw(:,3));
Raw(:,4)=Raw(:,4)-mean(Raw(:,4));

for i=1:99 a=(Raw(i+1,1)-Raw(i,1))^2+(Raw(i+1,2)-Raw(i,2))^2;A(i)=sqrt(a);end
for i=1:99 b=(Raw(i+1,3)-Raw(i,3))^2+(Raw(i+1,4)-Raw(i,4))^2;B(i)=sqrt(b);end

hHdata = histogram(A,15);
y = hHdata.Values;
x = hHdata.BinEdges;
for i=1:15 x1(i)=(x(i)+x(i+1))/2;end
x2=x1';
y=y';

%figure(11)
hHdata1 = histogram(B,15);
ya = hHdata1.Values;
xa = hHdata1.BinEdges;
for i=1:15 x1a(i)=(xa(i)+xa(i+1))/2;end
x2a=x1a';
ya=ya';

ft = fittype( '99*(2*x/d)*exp(-x*x/d)');
[fitresult, gof1] = fit( x2, y, ft, 'startPoint',50 );
d(i1)=fitresult.d;

ft = fittype( '99*(2*x/d)*exp(-x*x/d)');
[fitresult, gof2] = fit( x2a, ya, ft, 'startPoint',50 );
d1(i1)=fitresult.d;

end
d=d';
d1=d1';
dt(:,1)=d;dt(:,2)=d1;