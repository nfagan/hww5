function tf = ac_completed(trial_data)

tf = false( size(trial_data.data) );

for i = 1:numel(trial_data.data)
  if ( isfield(trial_data.data(i).events, 'ac_reward_on') )
    tf(i) = ~isnan( trial_data.data(i).events.ac_reward_on );
  end
end

end