function tf = sm_initiated(trial_file)

event_name = 'sm_image_on';
tf = hww5.is_non_nan_trial_event( trial_file.data, event_name );

end