function [A, L, V, locations] = simulate_sensor_graph(num_nodes, gamma, theta)
    % Simulate a connected graph and its Laplacian and eigenvectors
    %
    % Inputs:
    % num_nodes - Number of nodes in the graph
    % gamma     - Connectivity threshold for adjacency matrix
    % theta     - Weight decay parameter for adjacency matrix
    %
    % Outputs:
    % A         - Symmetric weighted adjacency matrix of the graph
    % L         - Graph Laplacian
    % V         - Eigenvector matrix of the Laplacian
    % locations - Node locations in 2D space

    % Generate the sensor graph (binary adjacency matrix with weights of 1)
    [A, locations] = generate_sensor_graph_connected(num_nodes, gamma, theta);

    % Remove weights from the lower triangle to avoid interference
    A = triu(A, 1); % Keep only the upper triangle

    % Define random weights for the upper triangle
    random_weights = rand(size(A)); % Random weights for the upper triangle (U[0,1])

    % Replace the 1s in the upper triangle of A with random weights
    A = A .* random_weights; % Apply random weights to edges

    % Mirror the upper triangle to the lower triangle to ensure symmetry
    A = A + A';

    % Compute Laplacian and eigenvectors
    L = diag(sum(A, 2)) - A; % Graph Laplacian
    [V, ~] = eig(L); % Eigenvectors of the Laplacian
end