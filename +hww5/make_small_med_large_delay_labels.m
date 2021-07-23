function [replace, replace_with] = make_small_med_large_delay_labels(delay_strs)

delays = fcat.parse( delay_strs, 'delay-' );
assert( ~any(isnan(delays)) );

delays = sort( delays );
distrib = shared_utils.vector.distribute( delays, 3 );
replace = cellfun( @(x) arrayfun(@(y) sprintf('delay-%0.2f', y), x, 'un', 0) ...
  , distrib, 'un', 0 );
replace_with = { 'small-delay', 'medium-delay', 'large-delay' };

end