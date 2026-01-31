function ExportLegendOnly(R, filename,type)

if nargin <3
    type='twolines';
end
if nargin < 2
    filename = 'legend_two_lines.eps'; % Default filename with extension
end
fig = figure;
hold on;
c=DefineColors;
m=DefineMarkers;
solver_names=GetNames(R.solver_names);
h = gobjects(1, length(solver_names));
for solver_idx = 1:length(solver_names)
   h(solver_idx) = plot(nan, nan, ...
    'LineWidth', 2, ...
    'Color',c(mod(solver_idx-1,size(c,1))+1,:),...
    'Marker', m{mod(solver_idx-1,length(m))+1}, ...
    'MarkerSize', 8);
  labels{solver_idx} = ['$' solver_names{solver_idx} '\quad$'];
end

switch type
    case 'oneline'
     numEntries = length(solver_names);
        numColumns = ceil(numEntries );
        lgd = legend(h, labels, ...
     'Interpreter', 'latex', ...
     'Location', 'southoutside', ...
    'Orientation', 'horizontal', ...
    'NumColumns', numColumns);
        set(gca, 'Visible', 'off');
        set(lgd, 'FontSize', 9);
        lgd.ItemTokenSize = [50, 18];  % [width, height] - increases spacing between entries
        axis off;
        %set(fig, 'Visible', 'on');
        fig.Position= [ 743   813   1200    65];  % Made wider to accommodate more spacing
        exportgraphics(fig, filename, 'Resolution', 300);

    case 'twolines'
        % Split entries into two rows
        numEntries = length(solver_names);
        numRow1 = ceil(numEntries / 2);
        
        % Create first row legend
        lgd1 = legend(h(1:numRow1), labels(1:numRow1), ...
            'Interpreter', 'latex', ...
            'Location', 'north', ...
            'Orientation', 'horizontal', ...
            'FontSize', 12);
        lgd1.Box = 'off';
        lgd1.EdgeColor = [0 0 0];
        lgd1.LineWidth = 1.5;
        lgd1.ItemTokenSize = [30, 18];  % Control spacing between entries
        
        % Create second row legend
        ax2 = axes('Position', get(gca, 'Position'), 'Visible', 'off');
        hold(ax2, 'on');
        h2 = gobjects(1, numEntries - numRow1);
        for idx = 1:(numEntries - numRow1)
            h2(idx) = plot(ax2, nan, nan, ...
                'LineWidth', 2, ...
                'Color', c(mod(numRow1+idx-1,size(c,1))+1,:), ...
                'Marker', m{mod(numRow1+idx-1,length(m))+1}, ...
                'MarkerSize', 8);
        end
        lgd2 = legend(ax2, h2, labels(numRow1+1:end), ...
            'Interpreter', 'latex', ...
            'Location', 'south', ...
            'Orientation', 'horizontal', ...
            'FontSize', 12);
        lgd2.Box = 'off';
        lgd2.EdgeColor = [0 0 0];
        lgd2.LineWidth = 1.5;
        lgd2.ItemTokenSize = [30, 18];  % Control spacing between entries
        
        set(gca, 'Visible', 'off');
        axis off;
        
        % Tight layout
        set(fig, 'Units', 'inches');
        fig.Position = [1 1 11 1.2];  % Made wider for better spacing
        
        % Export with tight bounding box
        exportgraphics(fig, filename, 'Resolution', 300, 'ContentType', 'vector', 'BackgroundColor', 'none');

end
%   close(fig);
end

function colors=DefineColors()
colors = [
    0.6784, 0.8471, 0.9020;   % pastel blue
    1.0000, 0.7059, 0.6667;   % pastel coral
    1.0000, 0.9490, 0.6824;   % pastel cream
    0.8196, 0.7686, 0.9412;   % pastel lavender
    0.6902, 0.9176, 0.7647;   % pastel mint
    1.0000, 0.8549, 0.7255;   % pastel peach
    0.9686, 0.7216, 0.8196;   % pastel pink
    0.6000, 0.8784, 0.8667;   % pastel teal
    0.8667, 0.7451, 0.8941;   % pastel purple
    0.7765, 0.8588, 0.7373;   % pastel sage
    0.9490, 0.7647, 0.8000;   % pastel rose
    0.7529, 0.8941, 0.9333;   % pastel sky
    ];
end

function markers=DefineMarkers()
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x'};
end

function new_names=GetNames(names)

new_names=cell(1,numel(names));
for i=1:numel(names)

    if strcmp(names{i},'PR_Inv')
        new_names{i}='PR-INV';
    end
    
    if strcmp(names{i},'AM_Lasso')
        new_names{i}='AM-\ell_1';
    end

    if strcmp(names{i},'AM_OMP')
        new_names{i}='AM-OMP';
    end

    if strcmp(names{i},'AM_GBNB')
        new_names{i}='AM-GBNB';
    end

    if strcmp(names{i},'AM_MGFOC_Delta_1_GBNB_OMP')
        new_names{i}='AM-MGFOC~(\delta=1)';
    end

    if strcmp(names{i},'AM_MGFOC_Delta_s_GBNB_OMP')
        new_names{i}='AM-MGFOC~(\delta=s)';
    end

    if strcmp(names{i},'AM_Best_GBNB_OMP')
        new_names{i}='AM-Best';
    end
    
    if strcmp(names{i},'AM_MGFOC_GBNB_OMP')
        new_names{i}='AM-MGFOC';
    end
    
    if strcmp(names{i},'AM_Lasso_GFOC')
        new_names{i}='\overline{AM-\ell_1}^{\textstyle c}';
    end

    if strcmp(names{i},'AM_OMP_GFOC')
        new_names{i}='\overline{AM-OMP}^{\textstyle c}';
    end

    if strcmp(names{i},'AM_GBNB_GFOC')
        new_names{i}='\overline{AM-GBNB}^{\textstyle c}';
    end

end

end