% clear all;
% warning off;
% Main function
% Matlab is pass-by-value.
% | Version | Author  | Date     | Commit
% | 1.0     | ZhangPF | 21.06.08 | Cell Gibbs free energy calculation
% | 1.1     | ZhouXY  | 21.06.10 | Running efficiency Improvement
tic
achieve=('D:\20210508\150us_files12_files_bindata\');
atarget=('D:\GibbsFreeEnergy\150us_files12_files fitted - 7000fps 0.5s-period_lsqcurvefit_calculatebeforerawdatabin\');
apic=dir(achieve);
S=size(apic);
pictotal=S(1)-2;
period=3500;
round=pictotal/period;
barn=30;

% ft = fittype('A+0.5*B*x*x');
func = @(var,x)(var(1)+0.5*var(2)*x.^2);
options = optimset('Display','off');

%%
for i = 1:round
    apic=dir(achieve);
    bsize=apic(3).name;
    Isize=imread(strcat(achieve,bsize));
    Isizedim=size(Isize);
    x_pixeln=Isizedim(2);
    y_pixeln=Isizedim(1);
    
    for q=1:period
        b1=period*(i-1);
        b=apic(b1+q+2).name;
        I(:,:,q)=imread(strcat(achieve,b));
    end
    
%     b = toc
    for k=1:y_pixeln
        for l = 1:x_pixeln
            for m=1:period
                A(m)=double(I(k,l,m));
            end

            size1=period-1;
            for i1=1:size1
                A1(i1)=1000*log(A(i1)/A(i1+1));
            end
%             c = toc
            A1(A1>0.2)=[];A1(A1<-0.2)=[];
            abc=size(A1);abc1=abc(2)-1;    

%             hHdata1 = histogram(A1,barn);
%             title(append(num2str(k),'-',num2str(l)))
%             ya = hHdata1.Values;
%             xa = hHdata1.BinEdges;
            
            [ya,xa] = histcounts(A1,barn);
%             d = toc
%             if k == 11 &&l==1
%                 toc;
%             end
%             if k == 15 &&l==1
%                 toc;
%             end

            for i1=1:barn x1a(i1)=(xa(i1)+xa(i1+1))/2;end
            afterx=x1a';
            aftery=ya';

            for i2=1:barn aftery1(i2)=log(abc1/aftery(i2));end
            aftery2=aftery1';

            test=aftery2;test(test==Inf)=[];test1=size(test);test2=test1(1);
%             e = toc
            if test2>1
                indx = find(~isinf(aftery2));
%                 [fitresult, gof1] = fit( afterx(indx), aftery2(indx), ft);
%                 A2(k,l)=fitresult.B;
                result = lsqcurvefit(func,[1,1],afterx(indx),aftery2(indx),[],[],options);
                A2(k,l)=result(2);
                  
            elseif test2==1
                A2(k,l)=0;
            end
%             f = toc
        end
    end
 %%   
    l_str=sprintf('%07d',i);
%     path=strcat('D:\shot noise 08152020 hamamatsu 5ms 200fps\10-fold\PBS_25ms_',int2str(l_str),'.tif');
    path=strcat(atarget,strcat(l_str),'_lsqcurvefit.tif');
    saveastifffast(single(A2),path);
%     toc
end
toc
