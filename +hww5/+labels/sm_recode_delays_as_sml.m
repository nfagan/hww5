function labels = sm_recode_delays_as_sml(labels)

delays = 0:0.2:2;
delay_strs = { 'small-delay', 'medium-delay', 'large-delay' };

dist_delays = shared_utils.vector.distribute( delays, numel(delay_strs) );

for i = 1:numel(delay_strs)  
  search_strs = arrayfun( @(x) sprintf('delay-%0.2f', x), dist_delays{i}, 'un', 0 );
  
  delay_ind = find( labels, search_strs );
  setcat( labels, 'delay', delay_strs{i}, delay_ind );
end

sm_ind = find( labels, 'sm' );
matched_cmbs = combs( labels, 'delay', sm_ind );
assert( isempty(setdiff(matched_cmbs, delay_strs)) ...
  , 'Some delays were not counted.' );

end