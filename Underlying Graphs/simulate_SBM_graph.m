function [A, L, V, clusterNodes, boundaryNodes] = simulate_SBM_graph(k, n, p_in, p_out, boundaryMatrix)
    % Simulate a stochastic block model (SBM) graph and its Laplacian and eigenvectors
    %
    % Inputs:
    % k              - Number of clusters
    % n              - Number of nodes per cluster
    % p_in           - Edge probability within clusters
    % p_out          - Edge probability between boundary nodes of different clusters
    % boundaryMatrix - k x k matrix specifying number of boundary nodes between clusters
    %
    % Outputs:
    % A              - Symmetric weighted adjacency matrix of the SBM graph
    % L              - Graph Laplacian
    % V              - Eigenvector matrix of the Laplacian
    % clusterNodes   - Cell array of nodes in each cluster
    % boundaryNodes  - Cell array of boundary nodes in each cluster

    isConnected = false; % Initialize connection status
    maxAttempts = 10;    % Set a limit on the number of attempts to ensure connectivity
    attempt = 0;

    while ~isConnected && attempt < maxAttempts
        attempt = attempt + 1;

        % Generate the SBM graph
        [A, clusterNodes, boundaryNodes] = generateSBM(k, n, p_in, p_out, boundaryMatrix);

        % Check if the graph is connected
        G = graph(A);
        numComponents = numel(unique(conncomp(G)));
        isConnected = (numComponents == 1);

        if ~isConnected
            fprintf('Graph is not connected. Retrying... (Attempt %d/%d)\n', attempt, maxAttempts);
        end
    end

    if ~isConnected
        error('Failed to generate a connected graph after %d attempts.', maxAttempts);
    end

    % Define random weights for the upper triangle
    random_weights = rand(size(A)); % Random weights for the upper triangle (U[0,1])

    % Replace the 1s in the adjacency matrix with random weights
    A = A .* random_weights; % Apply random weights to edges

    % Mirror the upper triangle to the lower triangle to ensure symmetry
    A = A + A';

    % Compute Laplacian and eigenvectors
    L = diag(sum(A, 2)) - A; % Graph Laplacian
    [V, ~] = eig(L); % Eigenvectors of the Laplacian
end