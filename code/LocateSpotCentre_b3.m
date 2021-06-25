    % Return linear index of centroid  
% | Version | Author | Date     | Commit
% | 0.1     | ZhouXY | 18.07.19 | The init version
% | 0.2     | ZhouXY | 20.02.12 | Add 2d Gaussian fitting
% | 0.3     | ZhouXY | 20.02.12 | idx in centroid and 2DGaussian are different
% Calculate cell centre
%'Centroid' or '2DGaussian'
% img is a n*m mtricx

function [x,y] = LocateSpotCentre_b3(idx, s, CenterType, img_source)
%img_source = gpuArray(img_source);
format long;
%     DetermineCenter = 'Centeroid';
    switch CenterType
        case 'Centroid'
%             n = s(1);
%             [x,y] = ind2sub(s,idx);
%             leng = length(idx);
%             location = round(sum(x))/leng + n*round(sum(y)/leng-1);
%             % pay attention to round(), it's critical

%             n = s(1);
            [x,y] = ind2sub(s,idx);
            leng = length(idx);
            location = [sum(x)/leng, sum(y)/leng];
            x = sum(x)/leng;
            y = sum(y)/leng;
            
        case '2DGaussian'
            [x,y] = ind2sub(s,idx);
            x = idx(:,1);
            y = idx(:,2);
            x = (min(x):max(x));
            y = (min(y):max(y));
            Intensities = img_source(x,y);
            [X, Y] = meshgrid(x,y);
            XYdata = zeros(size(X,1),size(Y,2),2);
            XYdata(:,:,1) = X;
            XYdata(:,:,2) = Y;
            location = Gaussian2DFit(XYdata,Intensities);
            x = location(1);
            y = location(2);
%             1/((2*pi)^(D/2)*sqrt(det(Sigma)))*exp(-1/2*(x-Mu)*Sigma^-1*(x-Mu)');
    end
end


function location = Gaussian2DFit(XYdata, Intensities)
    X = XYdata(:,:,1);
    Y = XYdata(:,:,2);
    %change X(1) Y(1) to centorid next time, more close to real location
    StartPoint = [(X(1)+X(end))/2, (Y(1)+Y(end))/2, 5, 5, 0, 1];% follow orders in Gaussian2DFunction, start points 
%     StartPoint = [X(1), Y(1), 5, 5, 0, 1]
%     class(Intensities)
    Z = double(Intensities)'; % image intensities in real image
%     class(Z)
    options = optimset('MaxIter', 400,'Display','off');
%     options = optimset(options, 'MaxIter',100000,'Display','iter');
    [x,resnorm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(@Gaussian2DFunction, StartPoint, XYdata, Z, [], [], options);

%     CI = nlparci(x,residual,'jacobian',jacobian);% confidence intervals for all arguments
%     Confidence_Interval_x = CI(1,1:2);
%     Confidence_Interval_y = CI(2,1:2);
    
%     location = [x(1:2), Confidence_Interval_x, Confidence_Interval_y];
    location = x(1:2);
end

function fun_2D = Gaussian2DFunction(paras, xy)
    %  https://en.wikipedia.org/wiki/Gaussian_function
    % add theta(rotation) argument
    center_x = paras(1);
    center_y = paras(2);
    sigma_x = paras(3);
    sigma_y = paras(4);
    theta = paras(5);
    factor = paras(6);

    x = xy(:,:,1) - center_x;
    y = xy(:,:,2) - center_y;

    x_rot = x*cos(theta) - y*sin(theta);
    y_rot = x*sin(theta) + y*cos(theta);
    
    pre_fun = (x_rot/sigma_x).^2 + (y_rot/sigma_y).^2;
    fun_2D = factor*exp(-pre_fun/2);
    %  location = round(sum(x))/leng + n*round(sum(y)/leng-1);

end











