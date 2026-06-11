function plot_sensor_supp()
% plot_sensor_supp()
% Generates the support-averaged sensor figures for the third row of suppR1.tex.
% Averages over {rand, rand-pairs} for the sensor graph only, for each sweep.
% Outputs to avg_figures/ as:
%   avg_graph_size_graphs_sensor_supports_rand_rand_pairs_Runtime.eps      (panel i)
%   avg_signal_sparsity_graphs_sensor_supports_rand_rand_pairs_Runtime.eps (panel j)
%   avg_noise_snr_graphs_sensor_supports_rand_rand_pairs_MSE_X.eps         (panel k)
%   avg_signal_sparsity_graphs_sensor_supports_rand_rand_pairs_F_score_.eps(panel l)
% (PlotAveragedRs/PlotR emit every metric; we use only the ones above.)

mainFolder = fileparts(mfilename('fullpath'));
addpath(genpath(mainFolder));

graphs   = {'sensor'};
supports = {'rand','rand-pairs'};

for p = {'graph_size','signal_sparsity','noise_snr'}
    PlotAveragedRs('Results/graph_*.mat', graphs, supports, 'avg_figures', p{1});
end
close all;
end
