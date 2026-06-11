function PlotR(R, outdir, metric_filter)
% PlotR(R, outdir)
% PlotR(R, outdir, metric_filter)
% Plots each metric in R and saves each figure as an image in 'outdir'.
% The legend is omitted from each figure.
% The config_name is included in the filename.
%
% metric_filter: optional cellstr; only metrics whose name contains any
%   pattern (case-insensitive) are plotted. Example: {'f-score','mse'}

if nargin < 2
    outdir = 'figures'; % Default output directory
end
if nargin < 3
    metric_filter = {};
end
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% Clean up config_name for use in a filename
config_name = regexprep(R.config_name, '[^a-zA-Z0-9]', '_');

% Indices to plot (all, or filter by substring match on R.metrics)
metric_indices = 1:length(R.metrics);
if ~isempty(metric_filter)
    metric_indices = [];
    for mi = 1:length(R.metrics)
        mname = lower(R.metrics{mi});
        for fi = 1:numel(metric_filter)
            pat = lower(strtrim(metric_filter{fi}));
            if contains(mname, pat)
                metric_indices(end + 1) = mi; %#ok<AGROW>
                break;
            end
        end
    end
    if isempty(metric_indices)
        warning('PlotR:NoMetricMatch', 'No metrics matched metric_filter for config "%s".', R.config_name);
        return;
    end
end

% Define figure dimensions at 80% of the original size
figure_width = 0.7 * 800;
figure_height = 0.9 * 500;

% Define spacing between figures
horizontal_spacing = 50;
vertical_spacing = 120;

% Define offsets to shift figures
x_offset = 100;
y_offset = 100;

% Number of rows and columns for layout
num_columns = 2;
n_metrics_plot = numel(metric_indices);
num_rows = ceil(n_metrics_plot / num_columns);

% Generate figure for each metric
for plot_k = 1:n_metrics_plot
    metric_idx = metric_indices(plot_k);
    % Determine row and column position for this figure
    row_idx = ceil(plot_k / num_columns);
    col_idx = mod(plot_k - 1, num_columns) + 1;

    % Calculate position for each figure with offsets
    figure_x = x_offset + (col_idx - 1) * (figure_width + horizontal_spacing);
    figure_y = y_offset + (num_rows - row_idx) * (figure_height + vertical_spacing);

    % Create figure with adjusted size and position
    fig = figure('Position', [figure_x, figure_y, figure_width, figure_height], ...
        'Color', 'w', 'InvertHardcopy', 'off');
    ax = axes('Parent', fig, 'Color', 'w', ...
        'XColor', 'k', 'YColor', 'k', 'ZColor', 'k', 'Box', 'on');
    hold(ax, 'on');

    % Plot each solver's performance

    for solver_idx = 1:length(R.solver_names)
        [solver_color, solver_marker] = GetSolverStyle(R.solver_names{solver_idx}, solver_idx);
        plot(ax, R.param_values, ...
            squeeze(R.results(metric_idx, solver_idx, :)), ...
            'LineWidth', 2, ...
            'Marker', solver_marker, ...
            'MarkerSize', 8, ...
            'Color', solver_color, ...
            'DisplayName', strrep(R.solver_names{solver_idx}, '_', ' '));
    end


    % Formatting

    grid(ax, 'on');
    %legend('Location', 'bestoutside'); % <-- Legend REMOVED
    set(ax, 'FontSize', 15);
    xlabel(ax, FormatParamLabel(R.param_name),'FontSize', 18, 'Color', 'k');
    ylabel(ax, FormatMetricLabel(R.metrics{metric_idx}),'FontSize', 18, 'Color', 'k');

    % Set log scale for 'mse' or 'runtime' metrics
    metric_name_lower = lower(R.metrics{metric_idx});
    if contains(metric_name_lower, 'runtime') || contains(metric_name_lower, 'mse')
        set(ax, 'YScale', 'log');
    end
    if contains(metric_name_lower, 'f-score')
        ylim(ax, [0.1,1]);
    end
    if strcmp(R.param_name,'graph_max_eigenvalue')
        xlim(ax, [1,12])
    end


    % Save figure as EPS in output directory
    metric_name = regexprep(R.metrics{metric_idx}, '[^a-zA-Z0-9]', '_'); % Clean metric name
    filename = fullfile(outdir, [config_name, '_', metric_name, '.eps']);
    exportgraphics(fig, filename, 'ContentType', 'vector', 'BackgroundColor', 'white'); % EPS is always vector

    %    close(fig); % Close the figure after saving
end
end

function label = FormatParamLabel(param_name)
key = lower(strrep(param_name, '-', '_'));
switch key
    case 'filter_degree'
        label = 'Filter degree';
    case 'graph_max_eigenvalue'
        label = 'Graph max eigenvalue';
    case 'graph_size'
        label = 'Graph size';
    case 'noise_snr'
        label = 'SNR';
    case 'signal_sparsity'
        label = 'Signal sparsity';
    otherwise
        label = strrep(param_name, '_', ' ');
        if ~isempty(label)
            label(1) = upper(label(1));
        end
end
end

function label = FormatMetricLabel(metric_name)
key = lower(regexprep(metric_name, '[^a-zA-Z0-9]', ''));
switch key
    case 'fscore'
        label = 'F-score';
    case 'msex'
        label = 'MSE(X)';
    case 'mseh'
        label = 'MSE(H)';
    case 'runtime'
        label = 'Runtime';
    otherwise
        label = strrep(metric_name, '_', ' ');
end
end
