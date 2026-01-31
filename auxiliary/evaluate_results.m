function [f_score, mse_X, mse_H] = evaluate_results(X_true, X_hat, H_true, H_hat)

    % Compute support for X_true and X_hat
    support_true = X_true ~= 0; % Binary support matrix for X_true
    support_hat = X_hat ~= 0;  % Binary support matrix for X_hat

    % True Positives (TP), False Positives (FP), False Negatives (FN)
    tp = sum(support_true & support_hat, 'all'); % True positives
    fp = sum(~support_true & support_hat, 'all'); % False positives
    fn = sum(support_true & ~support_hat, 'all'); % False negatives

    % Precision and Recall
    precision = tp / (tp + fp + eps); % Avoid division by zero
    recall = tp / (tp + fn + eps);    % Avoid division by zero

    % F-score
    f_score = 2 * (precision * recall) / (precision + recall + eps);

    % Mean Squared Error (MSE) for X
    mse_X = mean((X_true - X_hat).^2, 'all');
  
    % Mean Squared Error (MSE) for H
    H_true=H_true/norm(H_true,'fro'); %normalization
    H_hat=H_hat/norm(H_hat,'fro'); %normalization
    mse_H = mean((H_true - H_hat).^2, 'all');
end