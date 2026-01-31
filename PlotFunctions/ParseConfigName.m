function params = ParseConfigName(config_name)
    parts = strsplit(config_name, '_');
    params = struct();
    for i = 1:2:length(parts)-1
        key = parts{i};
        value = parts{i+1};
        params.(key) = value;
    end
end