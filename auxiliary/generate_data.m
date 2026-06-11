function [Y, H_true, X_true, L, Psi,V,Nei] =generate_data(config)


[W,L,Psi,V,config] = generate_graph(config);    
Nei=FindNeighbors(L);

switch config.filter_coefficients 
    case 'rand_close_to_1'
        filter_coeffs=[config.h_DC;1+sqrt(0.1)*randn(config.filter_degree,1)];
end
H_components = arrayfun(@(k) filter_coeffs(k) * (L^(k-1)), 1:(config.filter_degree+1), 'UniformOutput', false);
H_true = sum(cat(3, H_components{:}), 3);

switch config.signal_support
    case 'squared_fixed'
        X_spots=repmat(double(ismember(1:config.graph_size, config.signal_support_fixed)).',1,config.samples);
    case 'squared_change'
        node=config.signal_support_change; N=config.graph_size; n=sqrt(N);
        signal_support=[node+(node-1)*n,node*n-(node-1),N-node*n+node,N-(node-1)*n-(node-1)];
        X_spots=repmat(double(ismember(1:config.graph_size, signal_support)).',1,config.samples);
    case 'rand'
        X_spots = zeros(config.graph_size, config.samples);
        for t = 1:config.samples
        X_spots(randperm(config.graph_size, config.signal_sparsity), t) = 1;
        end
    case 'rand-pairs'
        X_spots = zeros(config.graph_size, config.samples);
        for t = 1:config.samples
        X_spots(SelectNeighbors(config.graph_size,config.signal_sparsity,2, Nei), t) = 1;
        end
    case 'rand-four'
        X_spots = zeros(config.graph_size, config.samples);
        for t = 1:config.samples
        X_spots(SelectNeighbors(config.graph_size,config.signal_sparsity,4, Nei), t) = 1;
        end
end
 
X_true=X_spots;

% Generate Data
switch config.signal_distribution
    case 'gaussian'
        X_true(X_true == 1) = randn(nnz(X_true), 1);
end
X_true = X_true ./ vecnorm(X_true);  % column-wise normalization
Y = H_true * X_true;
if isfinite(config.noise_snr)
    noise_std = sqrt(mean(Y(:).^2) / 10^(config.noise_snr/10));
    Y = Y + noise_std * randn(size(Y));
end

end

function [W,L,Psi, V,config]=generate_graph(config)

switch config.graph_type
    case 'squared'
        W=generate_squared_graph(config);
    case 'erdus-reyni'
        W= generate_erdus_renyi_graph(config);
    case 'sensor'
        [W,p]=generate_sensor_graph(config);     
    case 'brain'
        W=config.W_brain{randi(length(config.W_brain))};
        config.graph_size=size(W,1);
end

mask = triu(W, 1) > 0;
switch config.graph_weight
    case 'uniform'
        W(mask) =rand(nnz(mask), 1);
end
W = W + W';  % make symmetric
L=diag(sum(W, 2))-W;  %generate Laplacian

[V,Lambda]=eig(L);
Lambda=(config.graph_max_eigenvalue/max(diag(Lambda)))*Lambda;
L=V*Lambda*V.';
L(abs(L) < 1e-10) = 0;   
W=-L+diag(diag(L));
W=(1/2)*(W+W.');


% Construct Psi: Vandermonde matrix of eigenvalues (up to filter_order)
Lambda_vec=diag(Lambda);
Psi = zeros(length(Lambda_vec), config.filter_degree+1);
for t = 0:config.filter_degree
    Psi(:, t+1) = Lambda_vec .^ t;
end


end

%Auxiliary function for the Squared grid
function W =generate_squared_graph(config)
side = sqrt(config.graph_size);
assert(mod(side, 1) == 0, 'graph_size must be a perfect square.');
e = ones(side,1);
G1d = diag(e(1:end-1), 1) + diag(e(1:end-1), -1); % 1D chain graph
W = kron(speye(side), G1d) + kron(G1d, speye(side));
W = full(W); % optional
end

function plot_squared_graph(W)
%PLOT_GRAPH Plot graph W with nodes placed on a 2D grid (for squared graphs)
N = size(W, 1);
side = sqrt(N);
assert(mod(side, 1) == 0, 'Number of nodes must be a perfect square.');
G = graph(W);
[X, Y] = meshgrid(1:side, 1:side);  % Generate grid coordinates
x = X(:);
y = Y(:);
figure;
plot(G, 'XData', x, 'YData', y, 'NodeLabel', 1:N);
axis equal;
title('Structured Grid Graph');
end

function W = generate_erdus_renyi_graph(config)
   n=config.graph_size; 
   p=config.erdus_p;
    while 1
        W=triu(rand(n) < p, 1);
        W = W + W';
        W=W-diag(diag(W));
        if numel(unique(conncomp(graph(W)))) == 1, break; end
    end
end

function [W, p] = generate_sensor_graph(config)
    n = config.graph_size;
    d = config.sensor_degree;
    
    while true
        % Generate positions and distance-based graph
        p = rand(n,2) * sqrt(n);
        W = (squareform(pdist(p)) <= config.sensor_d) & ~eye(n);
        
        % Skip if initially disconnected
        if numel(unique(conncomp(graph(W)))) > 1
            continue;
        end
        
        % Apply degree constraint
        for i = 1:n
            nbrs = find(W(i,:));
            if length(nbrs) > d
                % Sort by neighbor degree (highest first)
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

function plot_sensor_graph(W, p)
    figure;
    plot(graph(W), 'XData', p(:,1), 'YData', p(:,2), ...
        'NodeColor', 'b', 'MarkerSize', 4, 'EdgeColor', 'k');
    axis equal;
    title('Sensor Network Graph');
    xlabel('X Position'); ylabel('Y Position');
    grid on;
end


function Nei=FindNeighbors(L)
L=L-diag(diag(L));
Nei=cell(size(L,2),1);
for i=1:1:size(L,2)
    Nei{i}=find(abs(L(:,i))>0);

end

end

function support = SelectNeighbors(N, s, k, Nei)

while true
    % Randomly select s/k elements without repetition
    selected_indices = randperm(N, s / k).';
    
    % Check if all selected nodes have enough neighbors
    if all(cellfun(@(x) numel(x) >= (k - 1), Nei(selected_indices)))
        % Initialize selected_pairs with selected indices and their neighbors
        support = [selected_indices; cell2mat(cellfun(@(x) x(randperm(numel(x), k - 1)), Nei(selected_indices), 'UniformOutput', false))];
        
        % Validate uniqueness
        if numel(unique(support)) == s
            break; % Exit loop if validation passes
        end
    end
end

end