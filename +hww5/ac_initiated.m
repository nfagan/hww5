function tf = ac_initiated(trial_file)

event_name = 'ac_present_images' ;
tf = hww5.is_non_nan_trial_event( trial_file.data, event_name );

end