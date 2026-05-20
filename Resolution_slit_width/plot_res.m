

close all; clear; clc;

%% -------------------- USER SETTINGS --------------------
ff=dir('*.xlsx');
fileName   = ff.name;
sheetName  = 'Corrected Data';

colX       = 1;          % x column (channels)
colYStart  = 3;          % first y column
colYEnd    = 11;         % last y column

slitWidths = 10:5:50;    % must match number of traces (colYStart:colYEnd)

% Plot style (readable + publication-ish)
FS  = 25;                % font size
LW  = 1.8;               % line width for curves
GRID_ALPHA_MINOR = 0.5;  % as you prefer

%% -------------------- READ + PREP DATA --------------------
T  = readtable(fileName, 'Sheet', sheetName);

x  = table2array(T(:, colX));
x  = x(:);                          % ensure column vector
nTraces = colYEnd - colYStart + 1;

if numel(slitWidths) ~= nTraces
    error('slitWidths (%d) must match number of traces (%d).', numel(slitWidths), nTraces);
end

% Preallocate outputs
c1  = nan(1, nTraces);              % Gaussian width parameter
gof = repmat(struct('rsquare',nan,'rmse',nan), 1, nTraces);

%% -------------------- FIT SETTINGS --------------------
% Fit model: y = a1*exp(-((x-b1)/c1)^2)
ft   = fittype('gauss1');
opts = fitoptions('Method','NonlinearLeastSquares', ...
                  'Display','Off', ...
                  'Lower',[-Inf -Inf 0]);      % c1 must be positive

% Optional: a reasonable start point improves stability.
% If your peaks are always near ~714, keep it; otherwise we estimate per trace.
useFixedStartPoint = false;
fixedStartPoint = [297738.483980376 714 79.5950923416664];

%% -------------------- PLOT 1: DATA + FIT (TILED, FULLSCREEN) --------------------
fig1 = figure('Name','Laser traces + Gaussian fits', 'WindowState','maximized');

% Tiled layout keeps each trace readable (better than stacking 11 curves on one axes)
t = tiledlayout(fig1, 3, 4, 'TileSpacing','compact', 'Padding','compact');
title(t, 'Corrected Data: Gaussian fits for each slit width', 'FontWeight','bold');

for k = 1:nTraces
    colY = colYStart + (k-1);
    y    = table2array(T(:, colY));
    y    = y(:);

    % Remove NaNs/Infs (fit() will error otherwise)
    valid = isfinite(x) & isfinite(y);
    xv = x(valid);
    yv = y(valid);

    nexttile;
    plot(xv, yv, 'LineWidth', LW); hold on;

    % Estimate start point per trace (more robust than a single hard-coded guess)
    if ~useFixedStartPoint
        [ymax, imax] = max(yv);
        x0 = xv(imax);
        c0 = max(1, 0.05 * range(xv));      % crude width guess
        opts.StartPoint = [ymax, x0, c0];
    else
        opts.StartPoint = fixedStartPoint;
    end

    % Fit model (protect loop from crashing on a single bad trace)
    try
        [fitresult, gof_k] = fit(xv, yv, ft, opts);

        % Store fit outputs
        c1(k) = fitresult.c1;
        gof(k).rsquare = gof_k.rsquare;
        gof(k).rmse    = gof_k.rmse;

        % Plot fitted curve
        xf = linspace(min(xv), max(xv), 800).';
        yf = fitresult(xf);
        plot(xf, yf, 'LineWidth', LW);

        % Annotate each tile with key numbers
        txt = sprintf('Slit = %d µm\nc1 = %.3g\nR^2 = %.4f', slitWidths(k), c1(k), gof_k.rsquare);
        title(txt, 'FontWeight','bold');
    catch ME
        title(sprintf('Slit = %d µm\nFIT FAILED', slitWidths(k)), 'FontWeight','bold');
        text(0.05, 0.9, ME.message, 'Units','normalized', 'FontSize', 10);
    end

    % Make axes readable
    grid on; grid minor;
    ax = gca;
    ax.FontSize = 12;                 % per-tile smaller; overall is fullscreen anyway
    ax.LineWidth = 1.2;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    ax.MinorGridAlpha = GRID_ALPHA_MINOR;

    xlabel('Channel / Pixel');
    ylabel('Corrected Intensity (a.u.)');
    legend({'Data','Gaussian fit'}, 'Location','best');
end

%% -------------------- PLOT 2: WIDTH PARAMETER vs SLIT WIDTH (FULLSCREEN) --------------------
fig2 = figure('Name','Gaussian width parameter vs slit width', 'WindowState','maximized');

plot(slitWidths, c1, 'o-', 'LineWidth', LW); hold on;
grid on; grid minor;

ax = gca;
ax.FontSize = FS;
ax.FontWeight = 'bold';
ax.LineWidth = 1.5;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.MinorGridAlpha = GRID_ALPHA_MINOR;

xlabel('Slit width (µm)', 'FontWeight','bold');
ylabel('Gaussian width parameter c_1 (channels)', 'FontWeight','bold');
title('Laser line width vs slit width (gauss1 fits)', 'FontWeight','bold');

%% -------------------- OPTIONAL: PRINT A QUICK SUMMARY --------------------
disp('--- Fit summary (slit width, c1, R^2, RMSE) ---');
for k = 1:nTraces
    fprintf('%3d µm   c1=%9.4g   R^2=%7.4f   RMSE=%9.4g\n', ...
        slitWidths(k), c1(k), gof(k).rsquare, gof(k).rmse);
end

