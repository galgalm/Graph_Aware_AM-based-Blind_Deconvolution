function [color, marker, style_idx] = GetSolverStyle(solver_name, fallback_idx)
%GETSOLVERSTYLE Return the canonical plot style for a solver name.
% Styles are keyed by solver name so partial-method plots match full plots.

if nargin < 2 || isempty(fallback_idx)
    fallback_idx = 1;
end

colors = DefineSolverColors();
markers = DefineSolverMarkers();
canonical_solver_names = { ...
    'PR_Inv', ...
    'AM_Lasso', ...
    'AM_Lasso_GFOC', ...
    'AM_OMP', ...
    'AM_OMP_GFOC', ...
    'AM_GBNB', ...
    'AM_GBNB_GFOC', ...
    'AM_MGFOC_Delta_1_GBNB_OMP', ...
    'AM_MGFOC_Delta_s_GBNB_OMP'};

solver_name = NormalizeSolverName(solver_name);
style_idx = find(strcmp(canonical_solver_names, solver_name), 1);

if isempty(style_idx)
    style_idx = fallback_idx;
end

color = colors(mod(style_idx - 1, size(colors, 1)) + 1, :);
marker = markers{mod(style_idx - 1, length(markers)) + 1};
end

function solver_name = NormalizeSolverName(solver_name)
if isstring(solver_name)
    solver_name = char(solver_name);
end
solver_name = strtrim(solver_name);

switch solver_name
    case 'AM_L1'
        solver_name = 'AM_Lasso';
    case 'AM_L1_GFOC'
        solver_name = 'AM_Lasso_GFOC';
end
end

function colors = DefineSolverColors()
% Okabe-Ito (8) + gray (9th); RGB in [0,1].
colors = [
    0.9412, 0.8941, 0.2588;  % PR_Inv
    0.4157, 0.2392, 0.6039;  % AM_Lasso
    0.8000, 0.4745, 0.6549;  % AM_Lasso_GFOC
    0.8353, 0.3686, 0.0000;  % AM_OMP
    0.9020, 0.6235, 0.0000;  % AM_OMP_GFOC
    0.0000, 0.0000, 0.0000;  % AM_GBNB
    0.5000, 0.5000, 0.5000;  % AM_GBNB_GFOC
    0.3373, 0.7059, 0.9137;  % AM_MGFOC_Delta_1_GBNB_OMP
    0.0000, 0.6196, 0.4510;  % AM_MGFOC_Delta_s_GBNB_OMP
];
end

function markers = DefineSolverMarkers()
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x'};
end
