function tf = ba_was_correct(trial_file)

event_name = 'ba_reward_on';
tf = hww5.is_non_nan_trial_event( trial_file.data, event_name );

end