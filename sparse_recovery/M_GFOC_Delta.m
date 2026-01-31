function [Omega_opt, x] = M_GFOC_Delta(y, F, Omega_inputs, beta, Nei, s, delta)
% M_GFOC_DELTA - Multi-GFOC with confidence parameter delta



%% Define GIC objective function handles
M = @(S) F(:,S);
Psu = @(S) (M(S).'*M(S))^(-1)*M(S).';
P = @(S) M(S)*(M(S).'*M(S))^(-1)*M(S).';
pre = @(S) y.'*P(S)*y - beta*(length(S));


Omega_u = unique(Omega_inputs(:));
N_Omega_u = unique([Omega_inputs(:); vertcat(Nei{unique(Omega_inputs(:))})]); %first order neighberhood
Xi_delta = generate_candidate_set_with_constraint(Omega_u, N_Omega_u, s, delta);
Omega_opt = select_best_support(Xi_delta, pre);
Omega_opt = sort(Omega_opt, 'ascend');
x = zeros(size(F, 2), 1);
if ~isempty(Omega_opt)
    x(Omega_opt) = Psu(Omega_opt)*y;
end

end


function Xi = generate_candidate_set_with_constraint(Omega, N_Omega, s, delta)

Xi = {};

% For each support size k = 1 to s
for k = 1:s
    if k > length(N_Omega)
        continue;
    end
    
    % Generate all k-subsets of N[Ω]
    combos = nchoosek(N_Omega, k);
    
    % Filter by constraint
    for i = 1:size(combos, 1)
        Lambda = combos(i, :)';
        
        % Check constraint: |Λ ∩ Ω| ≥ k - δ
        intersection_size = length(intersect(Lambda, Omega));
        if intersection_size >= k - delta
            Xi{end+1} = Lambda;
        end
    end
end

end


function Omega_opt = select_best_support(Xi_delta, pre_func)

cost_best = -inf;
Omega_opt = [];

% Evaluate each candidate
for i = 1:length(Xi_delta)
    Lambda = Xi_delta{i};
    cost = pre_func(Lambda);
    
    if cost > cost_best
        cost_best = cost;
        Omega_opt = Lambda;
    end
end

end

