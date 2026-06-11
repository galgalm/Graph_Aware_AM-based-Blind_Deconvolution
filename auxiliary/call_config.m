function config = call_config(str)


    base=struct('trials',10, ...
                'solver_names',{{'PR_Inv','AM_L1','AM_L1_GFOC',...
                'AM_OMP','AM_OMP_GFOC','AM_GBNB',...
                'AM_GBNB_GFOC','AM_MGFOC_Delta_1_GBNB_OMP','AM_MGFOC_Delta_s_GBNB_OMP'}},...
               'BD_tol', 1e-4, 'BD_iter', 10,'GIC_beta',0,...
               'h_DC',0.5,'Inv_lambda',1);


      switch str.graph

       % * Config A - 2D grid with centered support  *
       %-----------------------------------------
       %=========================================
       case 'squared'
         custom = struct('samples', 10, 'graph_size', 64, ...
        'graph_type', 'squared', 'graph_weight', 'uniform', ...
        'graph_max_eigenvalue', 8, ...
        'signal_sparsity', 4, 'signal_distribution', 'gaussian', ...
        'noise_snr',50,'noise_distribution', 'gaussian',...
        'filter_degree',4,'filter_coefficients','rand_close_to_1',...
        'filter_coefficients_sigma',0.1);

       case 'brain'
         script_dir = fileparts(mfilename('fullpath'));
         repo_dir = fileparts(script_dir);
         brain_data_path = fullfile(repo_dir, 'Underlying Graphs', 'brain_data_processed.mat');
         load(brain_data_path, 'W_brain');

         custom = struct('samples', 10, 'W_brain', {W_brain}, ...
        'graph_type', 'brain', 'graph_weight', 'uniform', ...
        'graph_max_eigenvalue', 8, ...
        'signal_sparsity', 4 ,'signal_distribution', 'gaussian', ...
        'noise_snr',50,'noise_distribution', 'gaussian',...
        'filter_degree',4,'filter_coefficients','rand_close_to_1',...
        'filter_coefficients_sigma',0.1);

       case 'erdus-reyni'
         custom = struct('samples', 10, 'graph_size', 64, ...
        'graph_type', 'erdus-reyni', 'graph_weight', 'uniform', ...
        'graph_max_eigenvalue', 8, ...
        'signal_sparsity', 4, 'signal_distribution', 'gaussian', ...
        'noise_snr',50,'noise_distribution', 'gaussian',...
        'filter_degree',4,'filter_coefficients','rand_close_to_1',...
        'filter_coefficients_sigma',0.1, 'erdus_p',0.06);

       case 'sensor'
         custom = struct('samples', 10, 'graph_size', 64, ...
        'graph_type', 'sensor', 'graph_weight', 'uniform', ...
        'graph_max_eigenvalue', 8, ...
        'signal_sparsity', 4, 'signal_distribution', 'gaussian', ...
        'noise_snr',50,'noise_distribution', 'gaussian',...
        'filter_degree',4,'filter_coefficients','rand_close_to_1',...
        'filter_coefficients_sigma',0.1, 'sensor_d',1.7,'sensor_degree',4);


      end

    switch str.support
            case 'fixed-center'
                custom.signal_support='squared_fixed';
                custom.signal_support_fixed=[28,29,36,37];
            case 'fixed-edges'
                custom.signal_support='squared_fixed';
                custom.signal_support_fixed=[1,8,57,64];
            case 'fixed-EdgeToCenter'
                custom.signal_support= 'squared_change';
                custom.signal_support_change= (1:1:sqrt(64)/2);
                custom.vary.name = 'signal_support_change';
                custom.vary.values =custom.signal_support_change;

            case 'rand'
                custom.signal_support='rand';
            case 'rand-pairs'
                 custom.signal_support='rand-pairs';
            case 'rand-four'
                 custom.signal_support='rand-four';

   end


   switch str.Xaxis
       case 'filter-degree'
           custom.filter_degree=[1,2,3,4,5]; custom.filter_coefficients='rand_close_to_1';
           custom.vary.name = 'filter_degree'; custom.vary.values =custom.filter_degree;  %Xaxis variable
       case 'noise-snr'
           custom.noise_snr=[10,20,30,40]; custom.vary.name = 'noise_snr'; custom.vary.values =custom.noise_snr; %Xaxis variable
       case 'maxeigenvalue'
           custom.graph_max_eigenvalue=[1,3,6,9,12]; custom.vary.name = 'graph_max_eigenvalue'; custom.vary.values =custom.graph_max_eigenvalue; %Xaxis variable
       case 'sparsity'  % runtime/complexity vs signal sparsity s (use rand-family support)
           % Sweep s on a larger graph so the sparse regime stays meaningful:
           % at n=64, s=10 is about 16% density; at n=80, the selected
           % range s=[2,4,6] remains sparse throughout.
           custom.graph_size=80;
           custom.signal_sparsity=[2,4,6]; custom.vary.name = 'signal_sparsity'; custom.vary.values =custom.signal_sparsity; %Xaxis variable
           custom.filter_degree=3;
           custom.solver_names={'AM_OMP_GFOC','AM_GBNB_GFOC','AM_MGFOC_Delta_1_GBNB_OMP'}; %options: 'PR_Inv','AM_OMP_GFOC','AM_GBNB_GFOC','AM_MGFOC_Delta_1_GBNB_OMP'

       case 'graph-size'  % runtime/complexity vs |V| (exclude brain; squared needs perfect squares; ER stays connected at these sizes with p=0.06)
           custom.graph_size=[64,100,144]; custom.vary.name = 'graph_size'; custom.vary.values =custom.graph_size; %Xaxis variable
           custom.filter_degree=3;
           custom.solver_names={'AM_OMP_GFOC','AM_GBNB_GFOC','AM_MGFOC_Delta_1_GBNB_OMP'}; %options: 'AM_OMP_GFOC','AM_GBNB_GFOC','AM_MGFOC_Delta_1_GBNB_OMP'


   end

config.name=sprintf('graph_%s_support_%s_Xaxis_%s',str.graph,str.support,str.Xaxis);

custom_fields =  fieldnames(custom);
base_fields = setdiff(fieldnames(base), fieldnames(custom));

for i = 1:numel(custom_fields)
    config.(custom_fields{i}) = custom.(custom_fields{i});
end

for i = 1:numel(base_fields)
    config.(base_fields{i}) = base.(base_fields{i});
end




end
