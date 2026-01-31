function results= run_slave(config)

param_values = config.vary.values;
param_name = config.vary.name;
num_vals = length(param_values);
results=zeros(4,length(config.solver_names),num_vals);  % 5 is the number of metrics currently used

for param_idx = 1:num_vals
    % Set the current value of the varying parameter
    config.(param_name) = param_values(param_idx);
    
    % === Generate data ===
    [Y, H_true, X_true, L, Psi,V,Nei] = generate_data(config); %generate data
    config.Nei = Nei;

    % === Initialize ===
    h=rand(config.filter_degree,1);
    H_components = arrayfun(@(k) h(k) * (L^k), 1:config.filter_degree, 'UniformOutput', false);
    H_init = sum(cat(3, H_components{:}), 3);

    for solver_idx=1:length(config.solver_names)

        BL_solver=config.solver_names{solver_idx}(1:2); %Choose Blind Deconvolution Solver

        switch BL_solver
            case 'AM'
                sparse_solver=config.solver_names{solver_idx}(4:end);
                t1=tic;
                [H_hat, X_hat] = Alternating_H_X(config,Y,L,Psi, V, H_init, ...
                    config.BD_iter, config.BD_tol, sparse_solver, X_true, H_true);
                runtime = toc(t1);  
            case {'PR'}
                method_solver=config.solver_names{solver_idx}(4:end);
                t1=tic;
                switch method_solver
                    case 'Inv'
                        [H_hat, X_hat] = Blind_Invertible(config,Y, V, ...
                            config.BD_iter, config.BD_tol);
                end
                runtime = toc(t1);
        end

        [f_score, mse_X, mse_H] = evaluate_results(X_true, X_hat, H_true, H_hat);
        results(:,solver_idx,param_idx)=[f_score; mse_X; mse_H; runtime];
    end

end

end


