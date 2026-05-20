function obtain_parabola_parameters()
    % Function to obtain parabolic parameters from multiple selected images
    % User selects multiple images and provides a region of interest (ROI)
    % The function fits parabolic curves to the maxima of the images and saves the parameters

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
    aa = zeros(num_images, 1); % Parabolic parameter (a)
    xxv = zeros(num_images, 1); % X vertex
    yyv = zeros(num_images, 1); % Y vertex
    sigma=zeros(1,num_images);
    % Define fit type and options for fitting parabolic curves
    ft = fittype('xv - a*(x - yv).^2', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares', 'Display', 'Off', 'Lower', [0, -Inf, -Inf]);

    % Fit each image's maxima to the parabola model
    for ii = 1:num_images
        idx_start = (ii-1)*ul_row + 1;
        idx_end = ii*ul_row;

        % Ensure the indices don't exceed the available data
        if idx_end > size(all_maxima, 1)
            idx_end = size(all_maxima, 1); 
        end

        idx = idx_start:idx_end;
        y = all_maxima(idx, 2); % Maxima column indices
        xx = all_maxima(idx, 1); % Row indices

        % Use the region of interest (ROI) for fitting
        if length(xx) > yupper
            y = y(ylower:yupper);
            xx = xx(ylower:yupper);
        end

        [xData, yData] = prepareCurveData(xx, y);

        % Fit the parabola model
        [fitresult, gof] = fit(xData, yData, ft, opts);

        % Store fitted parameters
        aa(ii) = fitresult.a;
        xxv(ii) = fitresult.xv;
        yyv(ii) = fitresult.yv;

        % Generate theoretical maxima based on the fit, only for ROI
        theoretical_maxima = fitresult.xv - fitresult.a * (xx - fitresult.yv).^2;

        % Plot fitted curve
        plot(real(theoretical_maxima), xx, 'b-', 'LineWidth', 1.5);
        sigma(ii)=gof.rmse;
    end

    legend('Observed Maxima', 'Fitted Curve', 'Location', 'Best');
    hold off;

    % Polynomial fit for xxv and yyv (X and Y vertices)
    figure;
    [xData, yData] = prepareCurveData(xxv, yyv);
    [fitresult, gof] = fit(xData, yData, 'poly1');

    % Plot polynomial fit result
    h = plot(fitresult, xData, yData);
    grid on;
    set(gca, 'FontSize', 14, 'LineWidth', 1.5, 'GridLineStyle', '--');
    xlabel('X Vertex (units)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Y Vertex (units)', 'FontSize', 16, 'FontWeight', 'bold');
    title('Fitted Linear Model for Vertex Parameters', 'FontSize', 18, 'FontWeight', 'bold');
    legend(h, {'Fitted Line', 'Data Points'}, 'Location', 'best', 'FontSize', 14);

    % Add R^2 value to the plot
    annotation('textbox', [0.15, 0.75, 0.2, 0.1], 'String', sprintf('R^2 = %.4f', gof.rsquare), ...
        'FitBoxToText', 'on', 'FontSize', 14, 'BackgroundColor', 'white', 'EdgeColor', 'black');
%     set(gcf, 'Position', get(0, 'Screensize')); % Make the figure full screen

    % Calculate final parabola parameters
    m = fitresult.p1;
    c = fitresult.p2; % Adjust intercept by ylower
    a = mean(aa);

    % Save parameters to a .mat file
    save('parabola_parameters.mat', 'a', 'c', 'm');
figure
plot(sigma)
end

% Helper function to find row maxima
function maxima = find_row_maxima(image)
    [~, max_idx] = max(image, [], 2); % Get column indices of max value in each row
    maxima = [(1:size(image, 1))', max_idx]; % [Row index, Max column index]
end
