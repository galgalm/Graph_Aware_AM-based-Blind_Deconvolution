function run_master(config)

% === Run the simulation ===
results=cell(config.trials,1);

for i=1:config.trials  %parfor does not work with cvx 
    results{i} = run_slave(config);
end

stacked_array = cat(4, results{:}); % Concatenate along the 4th dimension
mean_array = mean(stacked_array, 4);  % Compute the mean across the 4th dimension

% === Output struct ===
R = struct();
R.results=mean_array;
R.metrics={'F-score,','MSE_X','MSE_H','Runtime'};
R.solver_names=config.solver_names;
R.param_name=config.vary.name;
R.param_values = config.vary.values;
R.trials=config.trials;
R.config_name=config.name;
save_results(R);

% === Display summary ===
fprintf('\n--- Simulation Complete ---\n');

end


% Due to heavy simulation times results are averaged with previous
% simulation runs
function save_results(R)
results_folder = 'Results'; % Folder where results are stored
if ~exist(results_folder, 'dir')
    mkdir(results_folder); % Create folder if it doesn't exist
end

% === Check for Existing Files ===
existing_files = dir(fullfile(results_folder, '*.mat'));
config_found = false;

for i = 1:length(existing_files)
    % Load each existing file
    file_path = fullfile(results_folder, existing_files(i).name);
    loaded_data = load(file_path);

    % Check if the config matches (excluding R.results)
    if isfield(loaded_data, 'R') && ...
            isequal(loaded_data.R.metrics, R.metrics) && ...
            isequal(loaded_data.R.param_name, R.param_name) && ...
            isequal(loaded_data.R.param_values, R.param_values) && ...
            isequal(loaded_data.R.config_name, R.config_name)

        % Merge results by uniting trials and averaging results
        config_found = true;
        disp(['Matching configuration found in: ', existing_files(i).name]);

        % Combine trials
        total_trials = loaded_data.R.trials + R.trials;
        combined_results = (loaded_data.R.results * loaded_data.R.trials + ...
            R.results * R.trials) / total_trials;

        % Update R with merged data
        R.results = combined_results;
        R.trials = total_trials;

        % Save updated struct back to the same file
        save(file_path, 'R');
        disp(['Merged results saved to: ', file_path]);
        break;
    end
end

% === If No Matching Config Found ===
if ~config_found
    % Generate a unique filename for the new configuration
    new_filename = fullfile(results_folder, [R.config_name, '_A.mat']);
    counter = 1;

    % Ensure unique filename by appending a counter if needed
    while exist(new_filename, 'file')
        counter = counter + 1;
        new_filename = fullfile(results_folder, [R.config_name, '_', char(65 + counter - 1), '.mat']);
    end

    % Save the new configuration
    save(new_filename, 'R');
    disp(['New configuration saved as: ', new_filename]);
end
end