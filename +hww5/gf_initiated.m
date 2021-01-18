function tf = gf_initiated(trial_file)

event_name = 'images_on';
tf = hww5.is_non_nan_trial_event( trial_file.data, event_name );

end