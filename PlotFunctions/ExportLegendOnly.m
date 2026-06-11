function ExportLegendOnly(R, filename, type)
% type: 'oneline' | 'twolines' | 'onecolumn' | 'twocolumns' (default 'twolines')

if nargin < 3
    type='twolines';
end
if nargin < 2
    filename = 'legend_two_lines.eps'; % Default filename with extension
end
fontScale = 1.2;
fsLegendCompact = 9 * fontScale;   % oneline, twocolumns
fsLegendTwoline = 12 * fontScale;  % twolines
% onecolumn: text size is independent of row spacing (rowH / ItemTokenSize use fontScale only)
fsOneColumn = 14;
legendMarkerSize = 8;              % fixed; not scaled with fsOneColumn or fontScale
fig = figure;
hold on;
raw_names = R.solver_names;
solver_names=GetNames(R.solver_names);
h = gobjects(1, length(solver_names));
for solver_idx = 1:length(solver_names)
   [solver_color, solver_marker] = GetSolverStyle(raw_names{solver_idx}, solver_idx);
   h(solver_idx) = plot(nan, nan, ...
    'LineWidth', 2, ...
    'Color', solver_color, ...
    'Marker', solver_marker, ...
    'MarkerSize', legendMarkerSize);
  if strcmp(type, 'onecolumn')
      if strcmp(raw_names{solver_idx}, 'AM_MGFOC_Delta_1_GBNB_OMP')
          labels{solver_idx} = [sprintf('AM-MGFOC\n$(\\delta=1)$') '\quad'];
      elseif strcmp(raw_names{solver_idx}, 'AM_MGFOC_Delta_s_GBNB_OMP')
          labels{solver_idx} = [sprintf('AM-MGFOC\n$(\\delta=s)$') '\quad'];
      else
          labels{solver_idx} = ['$' solver_names{solver_idx} '\quad$'];
      end
  else
      labels{solver_idx} = ['$' solver_names{solver_idx} '\quad$'];
  end
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
        set(lgd, 'FontSize', fsLegendCompact);
        lgd.ItemTokenSize = [50 * fontScale, 18 * fontScale];  % [width, height] - increases spacing between entries
        axis off;
        %set(fig, 'Visible', 'on');
        fig.Position= [ 743   813   1200    65 * fontScale];  % Made wider to accommodate more spacing
        exportgraphics(fig, filename, 'Resolution', 300);

    case 'twolines'
        % Reverse legend order only; each h(k) keeps its color/marker (same idea as onecolumn)
        hLeg = fliplr(h);
        labelsLeg = flip(labels);
        numEntries = length(solver_names);
        % Odd count: put the extra entry on the second row (e.g. 9 -> 4 + 5, not 5 + 4)
        numRow1 = floor(numEntries / 2);
        n2 = numEntries - numRow1;
        
        % Create first row legend (first half of reversed order)
        lgd1 = legend(hLeg(1:numRow1), labelsLeg(1:numRow1), ...
            'Interpreter', 'latex', ...
            'Location', 'north', ...
            'Orientation', 'horizontal', ...
            'FontSize', fsLegendTwoline);
        lgd1.Box = 'off';
        lgd1.EdgeColor = [0 0 0];
        lgd1.LineWidth = 1.5;
        lgd1.ItemTokenSize = [30 * fontScale, 18 * fontScale];  % Control spacing between entries
        
        % Second row: dummy lines on ax2 matching hLeg(numRow1+1:end) (reversed tail)
        ax2 = axes('Position', get(gca, 'Position'), 'Visible', 'off');
        hold(ax2, 'on');
        h2 = gobjects(1, n2);
        for idx = 1:n2
            src = hLeg(numRow1 + idx);
            h2(idx) = plot(ax2, nan, nan, ...
                'LineWidth', 2, ...
                'Color', src.Color, ...
                'Marker', src.Marker, ...
                'MarkerSize', legendMarkerSize);
        end
        lgd2 = legend(ax2, h2, labelsLeg(numRow1+1:end), ...
            'Interpreter', 'latex', ...
            'Location', 'south', ...
            'Orientation', 'horizontal', ...
            'FontSize', fsLegendTwoline);
        lgd2.Box = 'off';
        lgd2.EdgeColor = [0 0 0];
        lgd2.LineWidth = 1.5;
        lgd2.ItemTokenSize = [30 * fontScale, 18 * fontScale];  % Control spacing between entries
        
        set(gca, 'Visible', 'off');
        axis off;
        
        % Tight layout
        set(fig, 'Units', 'inches');
        fig.Position = [1 1 11 1.2 * fontScale];  % Made wider for better spacing
        
        % Export with tight bounding box
        exportgraphics(fig, filename, 'Resolution', 300, 'ContentType', 'vector', 'BackgroundColor', 'none');

    case 'onecolumn'
        % Row spacing: ItemTokenSize height only — not tied to fsOneColumn (change text without changing rows)
        rowH = 32 * fontScale;
        nEnt = numel(labels);
        mlIdx = local_multilineLegendIndices(raw_names);
        % Reverse legend order only; each h(k) keeps its color/marker (remap rows for multiline icon nudge)
        hLeg = fliplr(h);
        labelsLeg = flip(labels);
        if isempty(mlIdx)
            mlIdxNudge = [];
        else
            mlIdxNudge = nEnt + 1 - mlIdx;
        end
        legIcons = [];
        wState = warning('off', 'all');
        try
            [lgd, legIcons] = legend(hLeg, labelsLeg, ...
                'Interpreter', 'latex', ...
                'Location', 'northeast', ...
                'Orientation', 'vertical', ...
                'NumColumns', 1);
        catch
            lgd = legend(hLeg, labelsLeg, ...
                'Interpreter', 'latex', ...
                'Location', 'northeast', ...
                'Orientation', 'vertical', ...
                'NumColumns', 1);
        end
        warning(wState);
        set(gca, 'Visible', 'off');
        lgd.ItemTokenSize = [55 * fontScale, rowH];
        set(lgd, 'FontSize', fsOneColumn);
        axis off;
        set(fig, 'Units', 'inches');
        numEntries = length(solver_names);
        figHeight = min((0.52 * numEntries + 0.85) * fontScale, 9 * fontScale);
        fig.Position = [1 1 1.85 * fontScale figHeight];
        drawnow;
        alignLegendMultilineTop(lgd);
        nudgeLegendIconsUp(legIcons, nEnt, mlIdxNudge, lgd);
        drawnow;
        exportgraphics(fig, filename, 'Resolution', 300, 'ContentType', 'vector', 'BackgroundColor', 'none');

    case 'twocolumns'
        numEntries = length(solver_names);
        lgd = legend(h, labels, ...
            'Interpreter', 'latex', ...
            'Location', 'northeast', ...
            'Orientation', 'vertical', ...
            'NumColumns', 2);
        set(gca, 'Visible', 'off');
        set(lgd, 'FontSize', fsLegendCompact);
        lgd.ItemTokenSize = [50 * fontScale, 18 * fontScale];
        axis off;
        set(fig, 'Units', 'inches');
        numRows = ceil(numEntries / 2);
        figHeight = min((0.42 * numRows + 0.5) * fontScale, 6 * fontScale);
        fig.Position = [1 1 3.6 * fontScale figHeight];
        exportgraphics(fig, filename, 'Resolution', 300, 'ContentType', 'vector', 'BackgroundColor', 'none');

end
%   close(fig);
end

function alignLegendMultilineTop(lgd)
% Anchor multiline label text at top (pairs with nudgeLegendIconsUp when two-output legend works).
ht = findall(lgd, 'Type', 'text');
for k = 1:numel(ht)
    s = ht(k).String;
    if isempty(s)
        continue;
    end
    isML = false;
    if ischar(s)
        isML = (size(s, 1) > 1) || any(s == 10);
    elseif iscell(s)
        isML = numel(s) > 1;
    elseif isstring(s)
        isML = any(contains(s, newline));
    end
    if isML
        ht(k).VerticalAlignment = 'top';
    end
end
end

function idx = local_multilineLegendIndices(raw_names)
idx = [];
for i = 1:numel(raw_names)
    if strcmp(raw_names{i}, 'AM_MGFOC_Delta_1_GBNB_OMP') || ...
            strcmp(raw_names{i}, 'AM_MGFOC_Delta_s_GBNB_OMP')
        idx(end + 1) = i; %#ok<AGROW>
    end
end
end

function nudgeLegendIconsUp(legIcons, nEntries, multilineIdx, lgd)
% Move line/marker graphics up for multiline rows so they sit near the first text line.
if isempty(multilineIdx)
    return;
end
dy = 0.028;
expected = nEntries + 2 * nEntries;
if ~isempty(legIcons) && numel(legIcons) >= expected
    for k = 1:numel(multilineIdx)
        e = multilineIdx(k);
        if e < 1 || e > nEntries
            continue;
        end
        for ii = [nEntries + 2 * e - 1, nEntries + 2 * e]
            if ii <= numel(legIcons) && isgraphics(legIcons(ii)) && strcmp(legIcons(ii).Type, 'line')
                legIcons(ii).YData = legIcons(ii).YData + dy;
            end
        end
    end
    return;
end
if nargin < 4 || ~isgraphics(lgd)
    return;
end
lines = findall(lgd, 'Type', 'line');
if numel(lines) < 2 * nEntries
    return;
end
ys = zeros(numel(lines), 1);
for i = 1:numel(lines)
    ys(i) = mean(lines(i).YData(:));
end
[~, ord] = sort(ys, 'descend');
lines = lines(ord);
for k = 1:numel(multilineIdx)
    e = multilineIdx(k);
    if e < 1 || e > nEntries
        continue;
    end
    for jj = 2 * e - 1 : min(2 * e, numel(lines))
        lines(jj).YData = lines(jj).YData + dy;
    end
end
end

function new_names=GetNames(names)

new_names=cell(1,numel(names));
for i=1:numel(names)

    if strcmp(names{i},'PR_Inv')
        new_names{i}='PR-INV';
    end
    
    if strcmp(names{i},'AM_Lasso') || strcmp(names{i},'AM_L1')
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
    
    if strcmp(names{i},'AM_Lasso_GFOC') || strcmp(names{i},'AM_L1_GFOC')
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
