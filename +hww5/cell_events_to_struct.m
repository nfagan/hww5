function out = cell_events_to_struct(events)

validateattributes( events, {'cell'}, {}, mfilename, 'events' );
assert( all(cellfun('isclass', events, 'struct')), 'All event elements must be struct.' );

fields = cellfun( @(x) columnize(fieldnames(x)), events, 'un', 0 );
unique_fields = unique( vertcat(fields{:}) );

for i = 1:numel(events)
  missing_fields = find( ~isfield(events{i}, unique_fields) );
  
  for j = 1:numel(missing_fields)
    events{i}.(unique_fields{missing_fields(j)}) = nan;
  end
end

out = vertcat( events{:} );

end