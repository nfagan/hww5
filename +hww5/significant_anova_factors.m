function split_sig_factors = significant_anova_factors(tbl, alpha)

if ( nargin < 2 )
  alpha = 0.05;
end

if ( iscell(tbl) )
  split_sig_factors = cellfun( ...
    @(x) hww5.significant_anova_factors(x, alpha), tbl, 'un', 0 );
  return
end

ps = vertcat( tbl.Prob_F{1:end-2} );
sig_ps = ps < alpha;
sig_factors = tbl.Source(sig_ps);
split_sig_factors = cellfun( @(x) strsplit(x, '*'), sig_factors, 'un', 0 );

end