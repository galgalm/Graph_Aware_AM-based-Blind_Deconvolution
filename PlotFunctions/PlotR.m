function PlotR(R, outdir)
% PlotR(R, outdir)
% Plots each metric in R and saves each figure as an image in 'outdir'.
% The legend is omitted from each figure.
% The config_name is included in the filename.

colors=DefineColors;
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x'};
if nargin < 2
    outdir = 'figures'; % Default output directory
end
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% Clean up config_name for use in a filename
config_name = regexprep(R.config_name, '[^a-zA-Z0-9]', '_');

% Define figure dimensions at 80% of the original size
figure_width = 0.7 * 800;
figure_height = 0.7 * 500;

% Define spacing between figures
horizontal_spacing = 50;
vertical_spacing = 120;

% Define offsets to shift figures
x_offset = 100;
y_offset = 100;

% Number of rows and columns for layout
num_columns = 2;
num_rows = ceil(length(R.metrics) / num_columns);

% Generate figure for each metric
for metric_idx = 1:length(R.metrics)
    % Determine row and column position for this figure
    row_idx = ceil(metric_idx / num_columns);
    col_idx = mod(metric_idx - 1, num_columns) + 1;

    % Calculate position for each figure with offsets
    figure_x = x_offset + (col_idx - 1) * (figure_width + horizontal_spacing);
    figure_y = y_offset + (num_rows - row_idx) * (figure_height + vertical_spacing);

    % Create figure with adjusted size and position
    fig = figure('Position', [figure_x, figure_y, figure_width, figure_height]);
    hold on;

    % Plot each solver's performance

    for solver_idx = 1:length(R.solver_names)
        plot(R.param_values, ...
            squeeze(R.results(metric_idx, solver_idx, :)), ...
            'LineWidth', 2, ...
            'Marker', markers{mod(solver_idx-1,length(markers))+1}, ... % Cycle through markers
            'MarkerSize', 8, ...
            'Color', colors(mod(solver_idx-1,size(colors,1))+1,:), ... % Cycle through colors
            'DisplayName', strrep(R.solver_names{solver_idx}, '_', ' '));
    end


    % Formatting
    
    grid on;
    %legend('Location', 'bestoutside'); % <-- Legend REMOVED
    set(gca, 'FontSize', 15);
    xlabel(strrep(R.param_name, '_', ' '),'FontSize', 18);
    ylabel(strrep(R.metrics{metric_idx}, '_', ' '),'FontSize', 18);

    % Set log scale for 'mse' or 'runtime' metrics
    metric_name_lower = lower(R.metrics{metric_idx});
    if contains(metric_name_lower, 'runtime') || contains(metric_name_lower, 'mse')
        set(gca, 'YScale', 'log');
    end


    % Save figure as EPS in output directory
    metric_name = regexprep(R.metrics{metric_idx}, '[^a-zA-Z0-9]', '_'); % Clean metric name
    filename = fullfile(outdir, [config_name, '_', metric_name, '.eps']);
    exportgraphics(fig, filename, 'ContentType', 'vector'); % EPS is always vector

    %    close(fig); % Close the figure after saving
end
end

function colors=DefineColors()
colors = [
    0.6784, 0.8471, 0.9020;   % pastel blue
    1.0000, 0.7059, 0.6667;   % pastel coral
    1.0000, 0.9490, 0.6824;   % pastel cream
    0.8196, 0.7686, 0.9412;   % pastel lavender
    0.6902, 0.9176, 0.7647;   % pastel mint
    1.0000, 0.8549, 0.7255;   % pastel peach
    0.9686, 0.7216, 0.8196;   % pastel pink
    0.6000, 0.8784, 0.8667;   % pastel teal
    0.8667, 0.7451, 0.8941;   % pastel purple
    0.7765, 0.8588, 0.7373;   % pastel sage
    0.9490, 0.7647, 0.8000;   % pastel rose
    0.7529, 0.8941, 0.9333;   % pastel sky
    ];
end

