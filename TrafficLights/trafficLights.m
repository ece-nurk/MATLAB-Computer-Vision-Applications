clear; clc; close all;

bias = 0.01; % dead zone
% color boundaries
red = 20/255; yellow = 44/255; green = 85/255;

% find pixels meeting condition (h,s>0.5,v>0.5)
im_test = imread('all cases.jpg');
im_test_h = rgb2hsv(im_test); 
im_test_s = im_test_h;
[w,k,d] = size(im_test);
im_bw(1:w,1:k) = 0;

min_S = 0.5; 
min_V = 0.5;

for i = 1:round(w)
    for j = 1:k
        if ((im_test_s(i,j,2) > min_S) && (im_test_s(i,j,3) > min_V)) 
            im_bw(i,j) = 1; 
        end
    end
end
[im_bw] = logical(im_bw);

subplot(2,2,1), imagesc(im_test), title('RGB','Fontsize', 10); axis off;
subplot(2,2,3), imagesc(im_test_h), title('HSV','Fontsize', 10); axis off;

im_test_s(:,:,1) = abs(mod((im_test_s(:,:,1)+red), 1)-red)+eps;
im_test_s(:,:,1) = im_test_s(:,:,1) .* im_bw;
im_test_s(:,:,2) = im_test_s(:,:,2) .* im_bw;
im_test_s(:,:,3) = im_test_s(:,:,3) .* im_bw;
subplot(2,2,2), imagesc(im_test_s), title('Segmented', 'Fontsize', 10); axis off;

% find circles
min_r = 5;

for iter = 1:2
    min_r = min_r + 10; 
    max_r = 3 * min_r;
    [centers, radii, metric] = imfindcircles(im_bw, [min_r max_r]); % CHT
    centers = round(centers);
    radii = round(radii); 
    n = size(radii, 1);
    
    % check the colors
    r = 0; % red detected or not
    g = 0; % green detected or not
    subplot(2,2,4), imagesc(im_test), title('RGB+classified', 'Fontsize', 10); axis off;
    
    % roundness test
    min_metric = 0.25;
    for p = 1:n
        if metric(p) < min_metric 
            continue; 
        end
        
        mean_accu = 0;
        pix = 0;
        %finds mean color of circle
        for i = centers(p,2)-radii(p) : centers(p,2)+radii(p) %y
            for j = centers(p,1)-radii(p) : centers(p,1)+radii(p) %x
                if (im_test_s(i,j,1) ~= 0) 
                    mean_accu = mean_accu + im_test_s(i,j,1); 
                    pix = pix + 1; 
                end
            end
        end
        
        m = mean_accu/pix;
        
        if (m < red-bias) 
            disp('red'); 
            r = 1; 
            viscircles(centers(p,:), 2*radii(p), 'Color','r', 'LineWidth', 3);
        elseif ((m > red+bias) && (m < yellow+red-bias)) 
            disp('yellow'); 
            y = 1;
            viscircles(centers(p,:), 2*radii(p), 'Color','y', 'LineWidth', 3);
        elseif ((m > yellow+red+bias) && (m < 1.5*green-bias)) 
            disp('green'); 
            g = 1;
            viscircles(centers(p,:), 2*radii(p), 'Color','g', 'LineWidth', 3);
        end
    end
    
    if (r && g) 
        disp('combination not allowed'); 
        break; 
    end
end
