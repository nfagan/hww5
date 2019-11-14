function tf = sm_was_correct(trial_file)

data = trial_file.data(:);
tf = arrayfun( @(x) ~any(structfun(@identity, x.errors)), data );

end