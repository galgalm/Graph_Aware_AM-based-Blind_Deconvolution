
load('S:\Rev_SDGS_Sparse_Recovery\SDGS_Sparse_Recovery\Underlying_Graph\brain_data_66.mat')
%create brain graphs  - remove edges with small edge weights
W_brain=cell(6,1);
for i=1:1:6
W=100*CC(:,:,i);
max_W=max(W(:));
W((100*W)<max_W) =0;
% Remove zero rows
W( all(~W,2), : ) = [];
% Remove zero columns
W( :, all(~W,1) ) = [];

W_brain{i}=W;
end
save('S:\Rev_SDGS_Sparse_Recovery\SDGS_Sparse_Recovery\Underlying_Graph\brain_data_processed.mat','W_brain')


%create unweighted graphs
W_brain=cell(6,1);
for i=1:1:6
W=100*CC(:,:,i);
W = double(brain_graph >= min(max(W)));
W_brain{i}=W;
end
save('S:\Rev_SDGS_Sparse_Recovery\SDGS_Sparse_Recovery\Underlying_Graph\brain_data_unweighted.mat','W_brain')

