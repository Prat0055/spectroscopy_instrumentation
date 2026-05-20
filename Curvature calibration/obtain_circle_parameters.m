function obtain_circle_parameters()
    % Function to obtain circular parameters from multiple selected images
    % User selects multiple images and provides a region of interest (ROI)
    % The function fits circular arcs to the maxima of the images and saves the parameters

    clc;

    % Allow user to select multiple images
    [image_files, image_path] = uigetfile('*.tif', 'Select .tiff Images', 'MultiSelect', 'on');
    if isequal(image_files, 0)
        disp('User canceled image selection.');
        return;
    end

    % Convert single selection to a cell array for consistency
    if ischar(image_files)
        image_files = {image_files};
    end

    % Get region of interest (ROI) from the user
    prompt = {'Enter lower Y limit (ylower):', 'Enter upper Y limit (yupper):'};
    dlgtitle = 'ROI Input';
    dims = [1 35];
    definput = {'41', '2000'}; % Default values, can be adjusted
    roi = inputdlg(prompt, dlgtitle, dims, definput);
    
    if isempty(roi)
        disp('User canceled ROI input.');
        return;
    end
    
    % Parse ROI values
    ylower = str2double(roi{1});
    yupper = str2double(roi{2});

    % Initialize arrays for storing results
    num_images = length(image_files);
    all_maxima = [];

    % Loop through all selected images
    for i = 1:num_images
        % Load image
        image = imread(fullfile(image_path, image_files{i}));
        [ul_row, ul_col] = size(image);  % Get the dimensions of the image

        % Ensure ROI is within image boundaries
        if yupper > ul_row
            yupper = ul_row;
        end
        
        % Find row maxima in the image
        maxima = find_row_maxima(image);
        all_maxima = [all_maxima; maxima]; % Append maxima from each image
    end

    % Plot the summed maxima overlaid on an empty image
    figure;
    imshow(zeros(ul_row, ul_col), []); hold on;
    plot(all_maxima(:,2), all_maxima(:,1), 'ro', 'MarkerSize', 2); % Observed maxima

    % Preallocate for theoretical maxima and fitted parameters
    rr = zeros(num_images, 1); % Radius of the circle
    xxv = zeros(num_images, 1); % X center of the circle
    yyv = zeros(num_images, 1); % Y center of the circle
    sigma=zeros(1,num_images);

    % Define anonymous function for circle fitting
    circleFit = @(params, x, y) sqrt((x - params(1)).^2 + (y - params(2)).^2) - params(3);

    % Fit each image's maxima to the circular model
    for ii = 1:num_images
        idx_start = (ii-1)*ul_row + 1;
        idx_end = ii*ul_row;

        % Ensure the indices don't exceed the available data
        if idx_end > size(all_maxima, 1)
            idx_end = size(all_maxima, 1); 
        end

        idx = idx_start:idx_end;
        x = all_maxima(idx, 2); % Maxima column indices
        y = all_maxima(idx, 1); % Row indices

        % Use the region of interest (ROI) for fitting
        if length(y) > yupper
            x = x(ylower:yupper);
            y = y(ylower:yupper);
        end

        % Initial guess for [x_center, y_center, radius]
        initial_guess = [mean(x), mean(y), range(x)/2];

        % Perform non-linear least squares fit
        options = optimset('Display', 'off');
        fit_params = lsqnonlin(@(params) circleFit(params, x, y), initial_guess, [], [], options);

        % Store fitted parameters
        xxv(ii) = fit_params(1);
        yyv(ii) = fit_params(2);
        rr(ii) = fit_params(3);

        % Generate theoretical maxima based on the fit, only for ROI
        theta = linspace(0, 2*pi, 100);
        theoretical_maxima_x = xxv(ii) + rr(ii) * cos(theta);
        theoretical_maxima_y = yyv(ii) + rr(ii) * sin(theta);

        % Plot fitted circular arc
        plot(theoretical_maxima_x, theoretical_maxima_y, 'b-', 'LineWidth', 1.5);

        % Calculate RMSE for the fit
        sigma(ii) = sqrt(mean((circleFit(fit_params, x, y)).^2));
    end

    legend('Observed Maxima', 'Fitted Circle', 'Location', 'Best', 'FontSize', 24);
    hold off;

    % Polynomial fit for xxv and yyv (X and Y center coordinates)
    figure;
    [xData, yData] = prepareCurveData(xxv, yyv);
    [fitresult, gof] = fit(xData, yData, 'poly1');

    % Plot polynomial fit result
    h = plot(fitresult, xData, yData);
    m=fitresult.p1;
    c=fitresult.p2;
    grid on;
    set(gca, 'FontSize', 14, 'LineWidth', 1.5, 'GridLineStyle', '--');
    xlabel('X Center (units)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Y Center (units)', 'FontSize', 16, 'FontWeight', 'bold');
    title('Fitted Linear Model for Circle Centers', 'FontSize', 18, 'FontWeight', 'bold');
    legend(h, {'Fitted Line', 'Data Points'}, 'Location', 'best', 'FontSize', 14);

    % Add R^2 value to the plot
    annotation('textbox', [0.15, 0.75, 0.2, 0.1], 'String', sprintf('R^2 = %.4f', gof.rsquare), ...
        'FitBoxToText', 'on', 'FontSize', 14, 'BackgroundColor', 'white', 'EdgeColor', 'black');

    % Save circle parameters to a .mat file
    rr=mean(rr);
    save('circle_parameters.mat', 'rr', 'm', 'c');
figure(3)
% hold on
plot(sigma)
legend('Parabolic','Circular')
end

% Helper function to find row maxima
function maxima = find_row_maxima(image)
    [~, max_idx] = max(image, [], 2); % Get column indices of max value in each row
    maxima = [(1:size(image, 1))', max_idx]; % [Row index, Max column index]
end
