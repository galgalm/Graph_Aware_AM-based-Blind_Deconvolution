function C = khatri_rao(A, B)
    % Validate the size of A and B
    [mA, pA] = size(A);
    [mB, pB] = size(B);
    
    if pA ~= pB
        error('Number of columns of A must be equal to number of columns of B.');
    end
    
    % Initialize the result matrix
    C = [];
    
    % Compute Khatri-Rao product
    for i = 1:pA
        % Compute the Kronecker product of the i-th columns of A and B
        C_i = kron(A(:, i), B(:, i));
        
        % Append the result to C
        C = [C, C_i];
    end
end
