function run_simulations()
% run_simulations
% Runs the configured simulation sweeps serially.

mainFolder = fileparts(mfilename('fullpath'));  % Get the full path of the current script's folder
allFolders = genpath(mainFolder); % Generate a path string including all subfolders
addpath(allFolders);  % Add all folders to the MATLAB path
graphs = {'erdus-reyni','squared','brain','sensor'}; % options: 'erdus-reyni','squared','brain','sensor'
supports = {'rand','rand-pairs'}; % options: 'rand','rand-pairs'
xaxes = {'filter-degree','maxeigenvalue','graph-size','noise-snr','sparsity'};

% Public experiment matrix:
% - filter-degree and maxeigenvalue are run for all graph/support settings.
% - graph-size, noise-snr, and sparsity are run for the sensor graph only.


clear config
i = 0;
for g = 1:length(graphs)
    for s = 1:length(supports)
        for x = 1:length(xaxes)
            str = struct('graph',graphs{g}, ...
                         'support',supports{s}, ...
                         'Xaxis',xaxes{x});
            if ismember(str.Xaxis, {'graph-size','noise-snr','sparsity'}) && ...
                    ~strcmp(str.graph,'sensor')
                continue;
            end
            i = i + 1;
            config{i} = call_config(str); %#ok<AGROW>
        end
    end
end

t_run = tic;
for j = 1:numel(config)
    fprintf('\n=== Running config %d/%d: %s ===\n', j, numel(config), config{j}.name);
    t_master = tic;
    run_master(config{j});
    fprintf('  run_master (config %d): %.4f s\n', j, toc(t_master));
end
fprintf('Total run_simulations loop: %.4f s\n', toc(t_run));
end
