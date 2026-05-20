function spect_cur = calculate_parabolic_spectra(img, roi)
    % Function to calculate the parabolic spectra from a given image or a specified region of interest (ROI).
    % img - the input image (whole image is considered if ROI is not provided)
    % roi - a 4-element vector [ylower, yupper, xlower, xupper] specifying the region of interest (ROI)

    % Parabola parameters
    load parabola_parameters.mat
    % Determine the region of interest (ROI)
    if nargin < 2  % If ROI is not provided, use the entire image
        [ylower, yupper] = deal(1, size(img, 1));  % Full image in Y dimension
        [xlower, xupper] = deal(1, size(img, 2));  % Full image in X dimension
    else
        ylower = roi(1);
        yupper = roi(2);
        xlower = roi(3);
        xupper = roi(4);
    end

    % Get the size of the region of interest
    ul_row = yupper - ylower + 1;
    ul_col = xupper - xlower + 1;

    % Initialize the array for the parabolic spectrum
    spect_cur = zeros(1, ul_col);  % Parabolic spectrum

    % Loop through each column (channel) within the ROI
    for channel = xlower:xupper
        sum_cur = 0;

        % Calculate the vertex y-coordinate for the current channel
        yv = m * channel + c;

        % Loop through each row within the ROI
        for row = ylower:yupper
            % Compute x-coordinate based on the parabola model
            x = channel - a * (row - yv)^2;

            % Only calculate the curved spectrum if x >= 1
            if x >= 1
                if x > ul_col
                    sum_cur = sum_cur + double(img(row, ul_col));  % Use the last column if x exceeds image bounds
                else
                    col = floor(x);  % Integer part of x
                    frac = x - col;  % Fractional part of x
                    sum_cur = sum_cur + double(img(row, col)) * (1 - frac) + double(img(row, col + 1)) * frac;
                end
            end
        end

        % Store the average value for the current channel in the spectrum
        spect_cur(channel - xlower + 1) = sum_cur / ul_row;
    end
end
