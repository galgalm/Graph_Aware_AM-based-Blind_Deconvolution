function [H_hat,X_hat] = Blind_Invertible(config,Y,V,max_iter,tol)

%   Detailed explanation goes here


[N,P]=size(Y);

A=(khatri_rao(Y.'*V,V));
%Initialize
t=0;
w=ones(N,P);
X_prev=zeros(N,P);
s=config.signal_sparsity;
%while loop somehow

for k=1:max_iter
    
    w_vec = w(:);  % Vectorize weights

    cvx_begin quiet
        variable g_tilde(size(A,2))
        minimize( sum(abs(w_vec .*(A * g_tilde))) )
        subject to
            sum(g_tilde) == N  % Constraint from Algorithm 1: 1_N^T g = N
    cvx_end

    X_hat=reshape(A*g_tilde,N,P);
    w=1./(X_hat+(1e-8));
    
    % Check for convergence
    if k>1
        if norm(X_hat - prev_X, 'fro')/norm(X_hat,'fro') < tol
            break;
        end
        end

    prev_X = X_hat;
   

end
X_hat = hard_column_threshold(X_hat, s);
[X_hat,factor] = normalize_X(X_hat);
g_tilde=g_tilde./(factor); 
H_hat=V*diag(g_tilde.^(-1))*V.';
alpha = 0.3; % keep values above mean/10
H_hat = symmetric_thresholding(H_hat, alpha);



end


function [X_normalized,average_norm] = normalize_X(X)
   
    % Compute column norms of X
    column_norms = vecnorm(X, 2, 1); % Vector of column norms (1 x M)
    % Avoid division by zero
    column_norms(column_norms == 0) = 1;
    % Normalize each column of X
    X_normalized = X./ column_norms; % Broadcasting to normalize each column
    % Adjust H_hat using the average column norm
    average_norm = mean(column_norms); % Average norm across all columns
   
end


function X_thresh = hard_column_threshold(X, s)
X_thresh = zeros(size(X));
[N, M] = size(X);

for j = 1:M
    col = X(:,j);
    [~, idx] = sort(abs(col), 'descend');
    keep = idx(1:min(s, N)); % In case s > N
    X_thresh(keep, j) = col(keep);
end
end


function H_thresh = symmetric_thresholding(H_hat, alpha)
    N = size(H_hat, 1);
    H_thresh = H_hat;

    for i = 1:N
        % Mean magnitude for row and column i
        row_mean = mean(abs(H_hat(i, :)));
        col_mean = mean(abs(H_hat(:, i)));

        % Threshold value (e.g., mean/10)
        row_thresh = alpha * row_mean;
        col_thresh = alpha * col_mean;

        % Find small entries in row and column
        row_mask = abs(H_thresh(i, :)) < row_thresh;
        col_mask = abs(H_thresh(:, i)) < col_thresh;

        % Zero them out symmetrically
        H_thresh(i, row_mask) = 0;
        H_thresh(row_mask, i) = 0;
        H_thresh(col_mask, i) = 0;
        H_thresh(i, col_mask') = 0;
    end

    % Re-symmetrize to fix any asymmetries due to numerical noise
    H_thresh = (H_thresh + H_thresh') / 2;
end
