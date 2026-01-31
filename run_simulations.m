
clear


mainFolder = fileparts(mfilename('fullpath'));  % Get the full path of the current script's folder
allFolders = genpath(mainFolder); % Generate a path string including all subfolders
addpath(allFolders);  % Add all folders to the MATLAB path
graphs={'erdus-reyni','squared','brain','sensor'};
supports = {'rand','rand-pairs'};
xaxes = {'filter-degree','maxeigenvalue'};

clear config 
i=0;
for g=1:length(graphs)
    str.graph=graphs{g};
 for s = 1:length(supports)
        str.support = supports{s};
    if ismember(str.support,mem.sup_fixed) && ~ismember(str.graph,mem.graph_fixed)
        continue;
    end 
        for x = 1:length(xaxes)
            str.Xaxis = xaxes{x};
            i = i + 1;
            config{i} = call_config(str);            
        end
 end
end

for j=1:1:i
run_master(config{j});
end