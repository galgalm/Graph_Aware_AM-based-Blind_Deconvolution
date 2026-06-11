function PlotIndividualRs(file_pattern, selected_graphs, selected_supports, output_dir, target_param_name, metric_filter)
% PlotIndividualRs — same discovery/filter as PlotAveragedRs, but plots each
%   loaded R separately (no averaging across .mat files).
% Uses PlotR.
%
% PlotIndividualRs(file_pattern, selected_graphs, selected_supports, output_dir)
% PlotIndividualRs(..., target_param_name)   % only R.param_name matching (e.g. 'filter_degree')
% PlotIndividualRs(..., target_param_name, metric_filter)  % cellstr substrings, e.g. {'f-score'}
%
% metric_filter: optional cell array of substrings matched case-insensitively
%   against R.metrics; empty {} plots all metrics (default).

if nargin < 6
    metric_filter = {};
end
if nargin < 5
    target_param_name = '';
end

files = dir(file_pattern);
all_R = arrayfun(@(f) load(fullfile(f.folder, f.name)), files);

valid_configs = [];
for i = 1:length(all_R)
    R = all_R(i).R;
    params = ParseConfigName(R.config_name);
    if ismember(params.graph, selected_graphs) && ...
            ismember(params.support, selected_supports)
        valid_configs = [valid_configs; struct('R', R, 'params', params)]; %#ok<AGROW>
    end
end

for config = valid_configs'
    R = config.R;
    if ~isempty(target_param_name) && ~strcmp(R.param_name, target_param_name)
        continue;
    end
    PlotR(R, output_dir, metric_filter);
end

end
