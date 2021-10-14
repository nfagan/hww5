function subsets = generate_significant_anova_factor_subsets(data, labels, source_I, anova_tables)

assert_ispair( data, labels );
assert( numel(source_I) == numel(anova_tables) );

validateattributes( data, {'numeric'}, {'2d', 'column'}, mfilename, 'data' );

subsets = {};

for i = 1:numel(anova_tables)
  sig_factors = hww5.significant_anova_factors( anova_tables{i} );
  for j = 1:numel(sig_factors)
    sig_fac = sig_factors{j};
    subsets{end+1} = struct( ...
        'factors', {sig_fac} ...
      , 'data', data(source_I{i}) ...
      , 'labels', labels(source_I{i}) ...
    );
  end
end

end