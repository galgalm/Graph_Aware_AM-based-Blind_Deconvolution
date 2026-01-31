function [adjMatrix, clusterNodes, boundaryNodes] = generateSBM(k, n, p_in, p_out, boundaryMatrix)
% k: number of clusters
% n: number of nodes per cluster
% p_in: edge probability within clusters
% p_out: edge probability between boundary nodes of different clusters
% boundaryMatrix: k x k matrix specifying number of boundary nodes between clusters

% Number of total nodes
totalNodes = k * n;

% Initialize adjacency matrix
adjMatrix = zeros(totalNodes);

% Randomly assign nodes to clusters
clusterNodes = cell(k, 1);
boundaryNodes = cell(k, 1);
boundaryNodeCells = cell(k, k); % Cell array to store boundary nodes

for i = 1:k
    clusterNodes{i} = (1 + (i-1) * n):(i * n);
end

% Populate the adjacency matrix
for i = 1:k
    % Nodes within the same cluster
    clusterAdjMatrix = rand(n) < p_in;
    clusterAdjMatrix = triu(clusterAdjMatrix, 1);
    clusterAdjMatrix = clusterAdjMatrix + clusterAdjMatrix';
    adjMatrix(clusterNodes{i}, clusterNodes{i}) = clusterAdjMatrix;
    
    % Define boundary nodes for cluster i
    numBoundary_i = sum(boundaryMatrix(i, :)); % Total boundary nodes needed
    boundaryNodes_i = randperm(n, numBoundary_i);
    boundaryNodes{i} = clusterNodes{i}(boundaryNodes_i);
    
    % Store boundary nodes in the cell matrix
    tempNodes=boundaryNodes{i};
    for j = 1:k
        if i ~= j && boundaryMatrix(i, j) > 0
            % Number of boundary nodes to connect from cluster i to cluster j
            numBoundaryToJ = boundaryMatrix(i, j);
            
            % Select a subset of boundary nodes for cluster i
            boundaryNodes_i_subset = tempNodes(1:numBoundaryToJ);
            tempNodes=setdiff(tempNodes,boundaryNodes_i_subset);
            
            % Store boundary nodes for connections in the cell matrix
            boundaryNodeCells{i, j} = boundaryNodes_i_subset;
        else
            boundaryNodeCells{i, j} = [];
        end
    end
end

% Generate connections between boundary nodes based on the cell matrix
for i = 1:k
    for j = (i+1):k
        if ~isempty(boundaryNodeCells{i, j})
            % Select boundary nodes for cluster i and j
            boundaryNodes_i_subset = boundaryNodeCells{i, j};
            numBoundaryToJ = length(boundaryNodes_i_subset);
            
            % Select boundary nodes for cluster j
            boundaryNodes_j = boundaryNodeCells{j, i};
           
            
            % Generate connections between boundary nodes
            betweenBoundaryEdges = rand(length(boundaryNodes_i_subset), length(boundaryNodes_j)) < p_out;
            adjMatrix(boundaryNodes_i_subset, boundaryNodes_j) = betweenBoundaryEdges;
            adjMatrix(boundaryNodes_j, boundaryNodes_i_subset) = betweenBoundaryEdges.'; % Ensure symmetry
        end
    end
end

% Convert adjacency matrix to graph object
G = graph(adjMatrix);

end
