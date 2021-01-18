function tf = sm_was_correct(trial_file)

data = trial_file.data(:);
% tf = arrayfun( @(x) ~any(structfun(@identity, x.errors)), data );

is_correct = ...
  @(x) isfield(x.events, 'sm_reward') && ~isnan(x.events.sm_reward);
tf = arrayfun( is_correct, data );

end