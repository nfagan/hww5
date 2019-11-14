function tf = gf_was_correct(trial_file)

data = trial_file.data(:);
tf = arrayfun( @(x) isfield(x.events, 'reward_on') && ~isnan(x.events.reward_on), data );

end