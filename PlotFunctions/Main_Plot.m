%Plot Script 

selected_graphs = {'sensor'}; %options: 'brain', 'sensor','squared','erdus-reyni'
selected_supports = {'rand','rand-pairs'};


xAxis='graph_size';   %'graph_max_eigenvalue', 'filter_degree'

PlotAveragedRs('Results/graph_*.mat', selected_graphs, selected_supports, 'avg_figures',xAxis);

close all; 