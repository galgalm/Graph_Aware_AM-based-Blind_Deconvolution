function test_candidate_set()
% TEST_CANDIDATE_SET  Verify the bottom-up candidate generator matches the
% naive generate-all-then-filter reference, over many random inputs.
%
% Checks, for each random (Omega, N_Omega, s, delta):
%   (a) both methods return the SAME set of candidates (order-independent),
%   (b) every candidate Lambda really satisfies |Lambda cap Omega| >= |Lambda| - delta.
%
% Run:  >> test_candidate_set

rng(0);                         % reproducible
n_trials = 500;
fprintf('Running %d random trials...\n', n_trials);

for t = 1:n_trials
    % --- random problem instance -------------------------------------
    universe = 1:randi([3 12]);             % ground set of indices
    m        = randi([0 numel(universe)]);  % |Omega|
    Omega    = sort(randperm(numel(universe), m));        % the support
    % N[Omega] = Omega plus some extra "outside" neighbours
    outside_pool = setdiff(universe, Omega);
    k_out    = randi([0 numel(outside_pool)+1]) - 1;      % how many outside to add
    k_out    = max(0, min(k_out, numel(outside_pool)));
    extra    = outside_pool(randperm(numel(outside_pool), k_out));
    N_Omega  = sort([Omega, extra]);

    s     = randi([1 max(1, numel(N_Omega))]);
    delta = randi([0 4]);

    % --- run both generators -----------------------------------------
    Xi_new = generate_candidate_set_with_constraint(Omega(:), N_Omega(:), s, delta);
    Xi_ref = reference_generator(Omega(:), N_Omega(:), s, delta);

    set_new = canonical_set(Xi_new);
    set_ref = canonical_set(Xi_ref);

    % (a) the two sets must be identical
    if ~isequal(set_new, set_ref)
        fprintf(2, 'MISMATCH on trial %d\n', t);
        fprintf(2, '  Omega   = [%s]\n', num2str(Omega));
        fprintf(2, '  N_Omega = [%s]\n', num2str(N_Omega));
        fprintf(2, '  s = %d, delta = %d\n', s, delta);
        fprintf(2, '  |new| = %d, |ref| = %d\n', numel(set_new), numel(set_ref));
        only_new = setdiff(set_new, set_ref);
        only_ref = setdiff(set_ref, set_new);
        if ~isempty(only_new), fprintf(2, '  only in new: %s\n', strjoin(only_new, ' | ')); end
        if ~isempty(only_ref), fprintf(2, '  only in ref: %s\n', strjoin(only_ref, ' | ')); end
        error('test_candidate_set:mismatch', 'Sets differ on trial %d.', t);
    end

    % (b) every candidate must independently satisfy the constraint
    for i = 1:numel(Xi_new)
        Lambda = Xi_new{i};
        k = numel(Lambda);
        if numel(unique(Lambda)) ~= k
            error('test_candidate_set:dupes', 'Trial %d: Lambda has duplicate indices.', t);
        end
        if ~all(ismember(Lambda, N_Omega))
            error('test_candidate_set:scope', 'Trial %d: Lambda not a subset of N[Omega].', t);
        end
        inter = numel(intersect(Lambda, Omega));
        if inter < k - delta
            error('test_candidate_set:constraint', ...
                'Trial %d: candidate violates |L cap O| >= k - delta.', t);
        end
    end
end

fprintf('All %d trials passed: new generator == reference, constraint holds.\n', n_trials);
end


function Xi = reference_generator(Omega, N_Omega, s, delta)
% The ORIGINAL generate-all-then-filter version, kept here as ground truth.
Xi = {};
for k = 1:s
    if k > numel(N_Omega)
        continue;
    end
    combos = nchoosek(N_Omega, k);     % N_Omega has >=1 elems; guarded below
    if isscalar(N_Omega)               % avoid nchoosek scalar gotcha in the ref too
        combos = N_Omega;              % single index, only k==1 reaches here
    end
    for i = 1:size(combos, 1)
        Lambda = combos(i, :)';
        if numel(intersect(Lambda, Omega)) >= k - delta
            Xi{end+1} = Lambda; %#ok<AGROW>
        end
    end
end
end


function keys = canonical_set(Xi)
% Turn a cell array of index-vectors into a sorted set of canonical string
% keys, so two collections can be compared independent of order.
keys = cell(1, numel(Xi));
for i = 1:numel(Xi)
    v = sort(Xi{i}(:))';
    keys{i} = strjoin(arrayfun(@(x) sprintf('%d', x), v, 'UniformOutput', false), ',');
end
keys = unique(keys);          % a set: dedupe + sort
end
