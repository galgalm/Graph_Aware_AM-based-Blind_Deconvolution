% Plot each matching Results/*.mat separately (no averaging). Mirrors Main_Plot.m.
%
% Optional last argument to PlotIndividualRs: metric_filter cellstr, e.g. {'f-score'}
% to only emit EPS for metrics whose names contain those substrings.

selected_graphs = {'sensor'};
selected_supports = {'rand','rand-pairs'};

xAxis = 'signal_sparsity';   % '' = all param_name; or 'graph_max_eigenvalue', etc.

output_dir = 'figures';

% Examples:
%   metric_filter = {};                      % all metrics
%   metric_filter = {'f-score'};             % only F-score (matches 'F_score', 'f-score', ...)
metric_filter = {};

PlotIndividualRs('Results/graph_*.mat', selected_graphs, selected_supports, ...
    output_dir, xAxis, metric_filter);

close all;
