function run_serial_until_stopped(max_cycles)
% run_serial_until_stopped([max_cycles])
% Repeats run_simulations serially until Ctrl-C.
% Omit max_cycles to keep looping; pass a number for a bounded test run.

if nargin < 1 || isempty(max_cycles)
    max_cycles = Inf;
end

mainFolder = fileparts(mfilename('fullpath'));
addpath(genpath(mainFolder));

oldFolder = pwd;
cleanupObj = onCleanup(@() cd(oldFolder));
cd(mainFolder);

fprintf('\nStarting serial repeat loop. Press Ctrl-C to stop.\n');
fprintf('Results are saved/merged after each completed config.\n');

cycle = 0;
while cycle < max_cycles
    cycle = cycle + 1;
    cycleStart = tic;
    fprintf('\n========== Cycle %d started: %s ==========\n', ...
        cycle, char(datetime('now')));
    
    runTimedScript('run_simulations', @() run_simulations());
   
    fprintf('========== Cycle %d complete: %.4f s ==========\n', ...
        cycle, toc(cycleStart));
end

clear cleanupObj
end

function runTimedScript(name, runner)
fprintf('\n--- Starting %s: %s ---\n', name, char(datetime('now')));
scriptStart = tic;
runner();
fprintf('--- Finished %s: %.4f s ---\n', name, toc(scriptStart));
end
