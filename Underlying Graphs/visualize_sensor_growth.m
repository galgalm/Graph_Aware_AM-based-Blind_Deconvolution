function visualize_sensor_growth()
% Visualize how the sensor graph grows across the graph-size sweep.
% Reproduces EXACTLY the local generate_sensor_graph logic in generate_data.m
% (p = rand(n,2)*sqrt(n), radius sensor_d, degree cap sensor_degree).

sizes      = [64,100,144,196];   % the graph-size sweep in call_config.m
sensor_d   = 1.7;                % fixed connection radius
sensor_deg = 4;                  % fixed degree cap

rng(1);   % reproducible layout

fig = figure('Position',[100 100 1100 900],'Color','w');
for k = 1:numel(sizes)
    n = sizes(k);
    cfg = struct('graph_size',n,'sensor_d',sensor_d,'sensor_degree',sensor_deg);
    [W,p] = generate_sensor_graph(cfg);

    subplot(2,2,k);
    plot(graph(W),'XData',p(:,1),'YData',p(:,2), ...
        'NodeColor','b','MarkerSize',4,'EdgeColor',[.4 .4 .4]);
    axis equal;
    % same physical scale on every panel so the area-growth is visible
    xlim([0 sqrt(max(sizes))]); ylim([0 sqrt(max(sizes))]);
    degs = sum(W,2);
    title(sprintf('n=%d  |  side=%.1f  |  avg deg=%.2f  max=%d', ...
        n, sqrt(n), mean(degs), max(degs)));
    xlabel('x'); ylabel('y'); grid on;
end
sgtitle('Sensor graph across the graph-size sweep (constant density, fixed radius)');

outpng = fullfile(fileparts(mfilename('fullpath')),'sensor_growth.png');
exportgraphics(fig, outpng, 'Resolution',150);
fprintf('Saved: %s\n', outpng);
end

% ---- exact copy of the generator from generate_data.m ----
function [W, p] = generate_sensor_graph(config)
    n = config.graph_size;
    d = config.sensor_degree;
    while true
        p = rand(n,2) * sqrt(n);
        W = (squareform(pdist(p)) <= config.sensor_d) & ~eye(n);
        if numel(unique(conncomp(graph(W)))) > 1
            continue;
        end
        for i = 1:n
            nbrs = find(W(i,:));
            if length(nbrs) > d
                [~, idx] = sort(sum(W(nbrs,:),2), 'descend');
                for j = 1:length(nbrs)-d
                    v = nbrs(idx(j));
                    W_tmp = W;
                    W_tmp(i,v) = 0; W_tmp(v,i) = 0;
                    if numel(unique(conncomp(graph(W_tmp)))) == 1
                        W = W_tmp;
                        if sum(W(i,:)) <= d
                            break;
                        end
                    end
                end
            end
        end
        if max(sum(W)) <= d
            break;
        end
    end
end
