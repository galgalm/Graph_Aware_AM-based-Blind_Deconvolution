function PlotAveragedRs(file_pattern, selected_graphs, selected_supports, output_dir,target_param_name)
%uses PlotR!!

% Load all matching files
files = dir(file_pattern);
all_R = arrayfun(@(f) load(fullfile(f.folder, f.name)), files);

% Extract and filter configurations
valid_configs = [];
for i = 1:length(all_R)
    R = all_R(i).R;
    params = ParseConfigName(R.config_name);
    if ismember(params.graph, selected_graphs) && ...
            ismember(params.support, selected_supports)
        valid_configs = [valid_configs; struct('R', R, 'params', params)];
    end
end

% Group by parameter type (noise_snr vs filter_deg)
param_groups = containers.Map;
for config = valid_configs'
    key = config.R.param_name;
    if ~isKey(param_groups, key)
        param_groups(key) = [];
    end
    param_groups(key) = [param_groups(key); config];
end

% Process each group
keys = param_groups.keys();
% If a specific param_name is requested, filter the keys
if exist('target_param_name', 'var') && ~isempty(target_param_name)
    keys = keys(strcmp(keys, target_param_name));
end

for k = 1:length(keys)
    group = param_groups(keys{k});

    % Verify compatibility
    base_R = group(1).R;
    all_same = all(arrayfun(@(g) isequal(g.R.param_values, base_R.param_values) && ...
        isequal(g.R.metrics, base_R.metrics) && ...
        isequal(g.R.solver_names, base_R.solver_names), group));

    if ~all_same
        warning('Skipping incompatible group: %s', keys{k});
        continue;
    end

    % Collect all results arrays into a cell array
    results_cells = arrayfun(@(g) g.R.results, group, 'UniformOutput', false);

    % Concatenate along the 4th dimension
    results_4d = cat(4, results_cells{:});

    % Compute the mean along the 4th dimension
    avg_results = mean(results_4d, 4);

    % Create averaged R structure
    R_avg = base_R;
    R_avg.config_name = sprintf('avg_%s_graphs-%s_supports-%s', ...
        keys{k}, strjoin(selected_graphs, '+'), strjoin(selected_supports, '+'));
    R_avg.results = avg_results;

    % Plot averaged results
    PlotR(R_avg, output_dir);
   
end
end
