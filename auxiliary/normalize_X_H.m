function [X_hat_normalized, H_hat_adjusted] = normalize_X_H(X_hat, H_hat)
    column_norms = vecnorm(X_hat, 2, 1); % Vector of column norms (1 x M)
    column_norms(column_norms == 0) = 1;
    X_hat_normalized = X_hat ./ column_norms; % Broadcasting to normalize each column
    average_norm = mean(column_norms); % Average norm across all columns
    H_hat_adjusted = H_hat * average_norm; % Adjust H_hat once using the average norm
end

