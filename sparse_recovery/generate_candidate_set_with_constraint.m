function Xi = generate_candidate_set_with_constraint(Omega, N_Omega, s, delta)
% Build, bottom-up, every Lambda subset of N[Omega] with |Lambda| = k (k=1..s)
% satisfying |Lambda intersect Omega| >= k - delta.
%
% Key reformulation: |Lambda intersect Omega| >= k - delta is equivalent to
% |Lambda \ Omega| <= delta, i.e. Lambda may contain at most delta elements
% that lie OUTSIDE Omega. So we never enumerate-then-filter: we pick b "outside"
% elements (b = 0..delta) and the remaining k-b "inside" elements directly.

Xi = {};

In  = intersect(N_Omega, Omega);   % elements of N[Omega] that count toward the intersection
Out = setdiff(N_Omega, Omega);     % elements that consume the delta budget
nIn  = numel(In);
nOut = numel(Out);

for k = 1:s
    if k > nIn + nOut
        continue;
    end

    % number of outside elements: 0..delta, also bounded by k and by nOut
    for b = 0:min([delta, k, nOut])
        a = k - b;                 % number of inside elements
        if a > nIn
            continue;              % not enough inside elements for this split
        end

        inCombos  = subset_combos(In,  a);
        outCombos = subset_combos(Out, b);

        for ic = 1:numel(inCombos)
            for oc = 1:numel(outCombos)
                Lambda = sort([inCombos{ic}; outCombos{oc}]);
                Xi{end+1} = Lambda; %#ok<AGROW>
            end
        end
    end
end

end


function C = subset_combos(v, k)
% Return a cell array of column vectors, each a k-element subset of v.
% Guards the nchoosek(scalar, k) gotcha (a scalar v would be read as a count).
v = v(:);
n = numel(v);
if k == 0
    C = {zeros(0, 1)};       % the empty subset
elseif k > n
    C = {};                  % impossible split
elseif k == n
    C = {v};                 % the whole set (also covers the n==1 case safely)
else
    M = nchoosek(v, k);      % here n >= 2, so v is treated as a vector
    C = cell(size(M, 1), 1);
    for i = 1:size(M, 1)
        C{i} = M(i, :)';
    end
end

end
