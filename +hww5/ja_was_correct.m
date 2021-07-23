function tf = ja_was_correct(trial_file)

data = trial_file.data(:);
% tf = arrayfun( @(x) ~any(structfun(@identity, x.errors)), data );
tf = by_error( data );

end

function tf = by_error(data)

tf = arrayfun( @(x) ~any(structfun(@identity, x.errors)), data );

end

function tf = by_event_type(trial_file, data)

tf_reward = hww5.is_non_nan_trial_event( data, 'reward_on' );
tf_initiated = hww5.ja_initiated( trial_file );
tf = tf_reward(:) & tf_initiated(:);

end