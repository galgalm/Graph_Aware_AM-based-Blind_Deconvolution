function [H_hat, X_hat] = Alternating_H_X(config,Y, L,Psi,V, H_init, max_iter, tol, solver_name, X_true, H_true)

    [N,P]=size(Y); 
    H_hat = H_init; % Initialize H matrix
 
    % Transform Y into eigenbasis
    Y_tilde = reshape(V' * Y,N*P,1);
  
    solver_function=str2func(sprintf('@%s_solver',solver_name)); 

    for k = 1:max_iter
     
        %update X
        X_hat = sparse_solver(config,Y, H_hat,solver_function);
        [X_hat, ~] = normalize_X_H(X_hat, H_hat);
        
        %update H
        X_temp = V' * X_hat;
        X_tilde=zeros(N*P,N);
        for p=1:P
            X_tilde((p-1)*N+1:N*p,1:N)=diag(X_temp(:,p));
        end 
        A=X_tilde*Psi; 
        h = (A' * A) \ (A' * Y_tilde);  % Least squares solution
        H_components = arrayfun(@(k) h(k) * L^(k-1), 1:(config.filter_degree+1), 'UniformOutput', false);
        H_hat = sum(cat(3, H_components{:}), 3);
        alpha = 0.3; % keep values above mean/10
        H_hat = symmetric_thresholding(H_hat, alpha);
        
        % Check for convergence
        if k>1
        if norm(X_hat - prev_X, 'fro')/norm(X_hat,'fro')+norm(H_hat - prev_H, 'fro')/norm(H_hat,'fro') < 2*tol  
            return;
        end
        end

        prev_X = X_hat;
        prev_H=H_hat;
    
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

function X = sparse_solver(config,Y, H, solver_function)
% Generalized sparse recovery solver for multiple columns
[~, M] = size(Y); % Number of samples
n = size(H, 2);   % Number of columns in H
X = zeros(n, M);  % Initialize sparse solution matrix
% Loop through each column of Y
for col = 1:M
    % Apply the specified sparse recovery method to each column
    X(:, col) = solver_function(Y(:, col), H, config);
end
end

function x_hat = OMP_solver(y, H, config)
[~, x_hat] = OMP(y, H, config); % Assume OMP is defined elsewhere
end

function x_hat = OMP_GFOC_solver(y, H, config)
[Omega, ~] = OMP(y, H, config); % Assume OMP is defined elsewhere
[~,x_hat]=GFOC(y,H,Omega,config.GIC_beta,config.Nei);

end

function x_hat = GBNB_solver(y, H, config)
[~, x_hat,~] = BNB_GB(y, H, config); % Assume OMP is defined elsewhere
end

function x_hat = GBNB_GFOC_solver(y, H, config)
[Omega, ~,~] = BNB_GB(y, H, config); % Assume OMP is defined elsewhere
[~,x_hat]=GFOC(y,H,Omega,config.GIC_beta,config.Nei);

end

function x_hat = L1_solver(y, H, config)
cvx_begin quiet
    variable x(size(H,1))  % Replace 'n' with the dimension of x
    minimize( norm(y - H*x) )
    subject to
        norm(x, 1) <= config.signal_sparsity  % L1-norm constraint
cvx_end

[val,ind]=sort(abs(x),'descend');
Omega=ind(1:config.signal_sparsity);

x_hat=zeros(size(x));
x_hat(Omega)=x(Omega); 


end

function x_hat = L1_GFOC_solver(y, H, config)
%[Omega, ~] = ell_1(y, H, trial); % Assume OMP is defined elsewhere
cvx_begin quiet
    variable x(size(H,1))  % Replace 'n' with the dimension of x
    minimize( norm(y - H*x) )
    subject to
        norm(x, 1) <= config.signal_sparsity  % L1-norm constraint
cvx_end
[val,ind]=sort(abs(x),'descend');
Omega=ind(1:config.signal_sparsity);

[~,x_hat]=GFOC(y,H,Omega,config.GIC_beta,config.Nei);

end


function x_hat = MGFOC_Delta_1_GBNB_OMP_solver(y, H, config)
% M-GFOC with delta=1 (high confidence in unified support)

[Omega_1, ~] = OMP(y, H, config);
[Omega_2, ~,~] = BNB_GB(y, H, config);
[~,x_hat]=M_GFOC_Delta(y,H,[Omega_1;Omega_2],config.GIC_beta,config.Nei,config.signal_sparsity,1);

end

function x_hat = MGFOC_Delta_s_GBNB_OMP_solver(y, H, config)
% M-GFOC with delta=s (low confidence, full neighborhood search)

[Omega_1, ~] = OMP(y, H, config);
[Omega_2, ~,~] = BNB_GB(y, H, config);
[~,x_hat]=M_GFOC_Delta(y,H,[Omega_1;Omega_2],config.GIC_beta,config.Nei,config.signal_sparsity,config.signal_sparsity);

end
