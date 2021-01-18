function tf = ja_completed(trial_file)

tf_reward = hww5.is_non_nan_trial_event( trial_file.data, 'reward_on' );
tf_err = hww5.is_non_nan_trial_event( trial_file.data, 'ja_response_error' );
tf_initiated = hww5.ja_initiated( trial_file );

% Completed trial if subject reaches reward state (i.e., they were correct)
% or ja_response_error state (i.e., they chose incorrectly, but still made
% a selection).
tf = (tf_reward | tf_err) & tf_initiated;

end