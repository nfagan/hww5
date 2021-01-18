function tf = is_non_nan_trial_event(data, event_name)

tf = false( size(data) );

for i = 1:numel(data)
  if ( isfield(data(i).events, event_name) )
    tf(i) = ~isnan( data(i).events.(event_name) );
  end
end

end