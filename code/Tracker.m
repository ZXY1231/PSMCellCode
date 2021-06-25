classdef Tracker < handle
    
    
    
    properties
        track_id 
        position_xyz
        quality
        frames
        my_patterns
        my_test
    end
    
    
    
    methods
       
        function particle = Tracker(track_id,position_xyz,quality,frames)
            particle.track_id = track_id;
            particle.quality = quality;
            particle.position_xyz = position_xyz;
            particle.frames = frames;
            particle.my_patterns = {};
            particle.my_test = {};
        end
        
        function particle = BlinlingDetector(particle)
            particle = addprop(particle,'Blinking');
        end
      
        function near = FindNext(particle,all_next_spots,dis_error)
            if nargin <3
                dis_error = 5^2;
            end
            find_spot = [false -1];
            post_leng = size(all_next_spots,1);
            x = particle.position_xyz(end,1);
            y = particle.position_xyz(end,2);
            
            near = 9999999;
            for i = linspace(1, post_leng, post_leng)
                dis = (x-all_next_spots(i,1))^2 + (y-all_next_spots(i,2))^2;
                if dis < near
                    near = dis;
                    next_x = all_next_spots(i,1);
                    next_y = all_next_spots(i,2);
                    find_spot(2) = i;
                end
            end
            if near < dis_error
                particle.position_xyz(end+1,[1,2]) = [next_x,next_y];
%                 particle.position_xyz(end,[1,2]) = [next_x,next_y];% rewrite peakx, peaky
                find_spot(1) = true;
            else
                find_spot(1) = false;
            end
        end
        
        %Here, all_next_xy should be particles xy with low threshold, we
        %use fun ParticleVelocity here.
        function find_spot = FindNextDim(particle,all_next_spots)
            find_spot = [false -1];
            post_leng = size(all_next_spots,1);
            
            %velocity = ParticleVelocity(particle);
%             velocity = PolynomialPredict(particle);
            velocity = [0,0];
            x = particle.position_xyz(end,1) + velocity(1);
            y = particle.position_xyz(end,2) + velocity(2);
            near = 9999999;
            for i = linspace(1, post_leng, post_leng)
                dis = (x-all_next_spots(i,1))^2 + (y-all_next_spots(i,2))^2;
                if dis < near
                    near = dis;
                    next_x = all_next_spots(i,1);
                    next_y = all_next_spots(i,2);
                    find_spot(2) = i;
                end
            end
            if near < 25
                particle.position_xyz(end+1,[1,2]) = [next_x,next_y];
                find_spot(1) = true;
            else
                find_spot(1) = false;
                %predicated xy results
                particle.position_xyz(end+1,[1,2]) = [x,y];
            end
        end
        
        % particles velocities estimation
        function velocity = ParticleVelocity(particle)
            if size(particle.position_xyz,1) <2
%                 particle.track_id
%                 error('Velocity calculation should be started with at least the 2nd frame.');
                velocity = [0,0];
            else
                velocity = particle.position_xyz(end,:) - particle.position_xyz(end-1,:);
                %If copy values directly form matlab variables, the
                %difference will be slightly different for some reason.
            end
        end
        
        % particles velocities estimation, 
        function velocity = PolynomialPredict(particle)
            if size(particle.position_xyz,1) <2
%                 particle.track_id
%                 error('Velocity calculation should be started with at least the 2nd frame.');
                velocity = [0,0];
            else
                previous_xy = particle.position_xyz(:,1:2);
                velocity = [0,0];
                leng = length(previous_xy);
                for i = 1:leng-2
                    velocity = velocity + 0.5^i*(previous_xy(end-i+1,:)-previous_xy(end-i,:));
                end
                velocity = velocity + 0.5^(leng-2)*(previous_xy(2,:)-previous_xy(1,:));
                %velocity = velocity + previous_xy(end,:);             
            end
        end
        
        %retrieve particle's pattern
        function pattern = MyPattern(particle, all_full_images, n, region)
        %MyPattern: return pattern of the particle, (averaged over the last n patterns)
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xyz,quality,frames)
        %          
        %         all_full_images         : array, size (#frames,h,w), 
        %         n                       : int, the parttern is average over the last n frame from the current time
        %         region                  : w*h array, pattern range = x-h/2+1:x+h/2, y-w/2+1:y+w/2, x, y is position in particle.position_xyz
        %Output:  pattern                 : has the same size with region
            %
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xyz(:,2));%pay attention to here xy
            yys = ceil(particle.position_xyz(:,1));
            t = 0;
            
            while t < n && t < size(particle.position_xyz,1)
                t_frame = particle.frames(end-t);
                if t_frame<0
                    t = t+1;
                    n = n+1; 
                    continue
                end

                x = xxs(end-t,1);
                y = yys(end-t,1);%pay attention to here xy

                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)

                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                t = t + 1;
                
            end
            pattern = pattern.*region/n;
            
        end
        
        %retrieve particle's pattern
        function pattern = MyPattern2(particle, all_full_images, n, region)
        %MyPattern: return pattern of the particle, (averaged over the first n patterns) 
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xyz,quality,frames)         
        %         all_full_images         : array, size (#frames,h,w), 
        %         n                       : int, the parttern is average over the first n frames from start
        %         region                  : w*h array, pattern range = x-h/2+1:x+h/2, y-w/2+1:y+w/2, x, y is position in particle.position_xyz
        %Output:  pattern                 : has the same size with region
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xyz(:,2));%pay attention to here xy
            yys = ceil(particle.position_xyz(:,1));
            t = 1;
            
            while t < n && t < size(particle.position_xyz,1)
                t_frame = particle.frames(t);
                if t_frame<0
                    t = t+1;
                    n = n+1; 
                    continue
                end

                x = xxs(t,1);
                y = yys(t,1);%pay attention to here xy

                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)

                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                t = t + 1;
                
            end
            pattern = pattern.*region/n;
            
        end
        

        function pattern = MyFastPattern(particle, one_image, region)
        %MyPattern: return pattern of the particle, (averaged over the first n patterns) 
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(one_image);
            xxs = floor(particle.position_xyz(:,2));%pay attention to here xy
            yys = floor(particle.position_xyz(:,1));
            x = xxs(end,1);
            y = yys(end,1);%pay attention to here xy
            if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)
%                pass
            else
                image = one_image;
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
            end
            
        end
        
        function pattern = MyFastPattern2(particle, one_image, region)
        %MyPattern: return pattern of the particle, (averaged over the first n patterns)
        % for odd side
            pattern = zeros(size(region));
            h = size(region,1)-1;
            w = size(region,2)-1;
            image_size = size(one_image);
            xxs = round(particle.position_xyz(:,2));%pay attention to here xy
            yys = round(particle.position_xyz(:,1));
            x = xxs(end,1);
            y = yys(end,1);%pay attention to here xy
            if x-h/2 <= 0 || x+h/2 > image_size(1) || y-w/2 <= 0 || y+w/2 > image_size(2)
%                pass
            else
                image = one_image;
                pattern = image(x-h/2:x+h/2, y-w/2:y+w/2);
            end
            
            pattern = pattern.*region;
        end
        
        function pattern = MyFastPattern3(particle, one_image, f,region)
        % for odd side
            pattern = zeros(size(region));
            h = size(region,1)-1;
            w = size(region,2)-1;
            image_size = size(one_image);
            xxs = round(particle.position_xyz(f,2));%pay attention to here xy
            yys = round(particle.position_xyz(f,1));
            x = xxs(end,1);
            y = yys(end,1);%pay attention to here xy
            if x-h/2 <= 0 || x+h/2 > image_size(1) || y-w/2 <= 0 || y+w/2 > image_size(2)
%                pass
            else
                image = one_image;
                pattern = image(x-h/2:x+h/2, y-w/2:y+w/2);
            end
            
            pattern = pattern.*region;
        end
        
        function pattern = MyPatternVideo(particle, all_full_images, t1, t2, region)
   
            %
            pattern = zeros([size(region),t2-t1+1]);
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xyz(:,2));%pay attention to here xy
            yys = ceil(particle.position_xyz(:,1));
            for i = t1:t2
                t_frame = abs(particle.frames(i));
                x = xxs(i,1);
                y = yys(i,1);%pay attention to here xy
                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)
                    break;
                end

                image = squeeze(all_full_images(t_frame,:,:));
                pattern(:,:,i-t1+1) = image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);

            end
            
        end
        

        function position_z = EstimateZ(particle,particle_pattern,a,b) 
        %EstimateZ: return z estimation of the particle
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xyz,quality,frames)         
        %         particle_pattern        : parttern of the pattern,
        %         a                       : experimental parameter
        %         b                       : experimental parameter
        %Output:  position_z              : double, z position
        %         |     yunlei            | 20200824
        %         paper reference: Three-dimensional localization microscopy in live flowing cells
            if nargin<3
                a = 2343.4;
                b = 820.7;
            end

            H = size(particle_pattern,1);
            W = size(particle_pattern,2);
            [X, Y] = meshgrid(1:H, 1:W);
            X_fit = X-(H-1)/2;
            Y_fit = Y-(W-1)/2;
            XY(:,:,1)=X_fit;
            XY(:,:,2)=Y_fit;

            func = @(var,x) (var(1)*exp(-(x(:,:,1)-var(2)).^2/(2*var(4)^2)-(x(:,:,2)-var(3)).^2/(2*var(5)^2)));  
            try
                options = optimset('MaxFunEvals',100000,'MaxIter',100000);
                result = lsqcurvefit(func,[1,0,0,1,1],XY,particle_pattern,[],[],options);
                position_z = a*log(result(4)/result(5)) + b;

            catch

            end
            particle.position_xyz(end,4) = position_z;
        end
        
        function SavePatterns(particle, all_full_images, region, filename)
            if nargin < 4
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            patterns = zeros([size(particle.position_xyz,1) size(region)]);
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xyz(:,2));%pay attention to here xy
            yys = ceil(particle.position_xyz(:,1));
            
            for t = 1:size(particle.position_xyz,1)
                t_frame = abs(particle.frames(t));
                x = xxs(t,1);
                y = yys(t,1);%pay attention to here xy
                if x-h/2+1 < 0 || x+h/2 > image_size(1) || y-w/2+1 < 0 || y+w/2 > image_size(2)
                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                patterns(t,:,:) = image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                
            end
            
            for i = 1:size(patterns, 1)
                if max(patterns(i,:,:))==0
                    patterns(i,:,:) = [];
                end
            end
            
            for i = 1:size(patterns,1)
                i 
                pattern = squeeze(patterns(i,:,:));
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end 
        end
        
        function SavePatterns2(particle, filename)
            %save 
            if nargin < 2
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            for i = 1:size(particle.my_patterns,1)
                i 
                pattern = squeeze(particle.my_patterns(i,:,:));
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end
            
        end
        
        function SavePatterns3(particle, filename)
            %save 
            if nargin < 2
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            for i = 1:size(particle.my_patterns,2)
                i 
                pattern = squeeze(particle.my_patterns{i});
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end
            
        end
        
        function SavePatterns4(particle, filename)
            %save 
            if nargin < 2
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            for i = 1:size(particle.my_patterns,2)
                i 
                pattern = squeeze(particle.my_patterns{i});
                pattern = pattern - min(pattern, [], 'all');
%                 v = pattern~=0;
%             %     my_psf_norm = (my_psf/abs(sum(my_psf(v),'all'))-mean(my_psf(v)/abs(sum(my_psf(v),'all')),'all')).*v;
%                 pattern_norm = pattern - mean(pattern(v),'all').*v;
%                 pattern_norm = (pattern_norm/sum(abs(pattern_norm(v)),'all'));
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end
            
        end

        function average_radial_profile = PSF2LineProfile(particle, pattern)
        %PSF2LineProfile: return line profile of the particle
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xyz,quality,frames)
        %         pattern                 : particle pattern in the previous frame
        %Output:  average_radial_profile    : has the same size with region
        %%source https://www.mathworks.com/matlabcentral/answers/266546-radial-averaging-of-2-d-tif-image
%             x = particle.position_xyz(end,1);
%             y = particle.position_xyz(end,2);
            
            [rows, columns] = size(pattern);
            x = columns/2+0.5;
            y = rows/2+0.5;
            %%
            % Find out what the max distance will be by computing the distance to each corner.
            distanceToUL = sqrt((1-y)^2 + (1-x)^2);
            distanceToUR = sqrt((1-y)^2 + (columns-x)^2);
            distanceToLL = sqrt((rows-y)^2 + (1-x)^2);
            distanceToLR= sqrt((rows-y)^2 + (columns-x)^2);
            maxDistance = ceil(max([distanceToUL, distanceToUR, distanceToLL, distanceToLR]))-1; % avoid zero counts
            %%
            % Allocate an array for the profile
            profileSums = zeros(1, maxDistance);
            profileCounts = zeros(1, maxDistance);
            % Scan the original image getting gray level, and scan edtImage getting distance.
            % Then add those values to the profile.
            for column = 1 : columns
                for row = 1 : rows
                    thisDistance = round(sqrt((row-y)^2 + (column-x)^2));
                    if thisDistance <= 0|| thisDistance > maxDistance
                        continue;
                    end
                    profileSums(thisDistance) = profileSums(thisDistance) + double(pattern(row, column));
                    profileCounts(thisDistance) = profileCounts(thisDistance) + 1;
                end
            end
            %%
            % Divide the sums by the counts at each distance to get the average profile
            average_radial_profile = profileSums ./ profileCounts;
        end
        
        function psf2d = LineProfile2PSF(particle, psf1d)
            side = 2*length(psf1d);
            c1 = side/2+0.5;
            c2 = side/2+0.5;
            [xx, yy] = meshgrid(1:side,1:side);
            dis = round(sqrt((xx-c1).^2+(yy-c2).^2));
            psf1d = cat(2, psf1d, zeros(size(psf1d)),zeros(size(psf1d)));
        %     psf1d = cat(2, psf1d, psf1d, psf1d);
            psf2d = psf1d(dis);
        end
           
    end
    
    
    
end
