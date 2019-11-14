function durs = ba_lookdur(unified_file, trial_file, edf_file, sync_file)

events = hww5.cell_events_to_struct( {trial_file.data.events} );

start_ts = hww5.mat2edf_time( [events.ba_images_on], sync_file );
stop_ts = hww5.mat2edf_time( [events.ba_reward_on], sync_file );

matches_trial = hww5.is_fix_event_within_interval( edf_file, start_ts, stop_ts );

x_trial = hww5.select_efix_components( edf_file, 'posX', matches_trial );
y_trial = hww5.select_efix_components( edf_file, 'posY', matches_trial );
dur_trial = hww5.select_efix_components( edf_file, 'duration', matches_trial );

left_image_rect = unified_file.opts.STIMULI.ba_image1.vertices;
right_image_rect = unified_file.opts.STIMULI.ba_image2.vertices;

left_ib = cellfun( @(x, y) bfw.bounds.rect(x, y, left_image_rect), x_trial, y_trial, 'un', 0 );
right_ib = cellfun( @(x, y) bfw.bounds.rect(x, y, right_image_rect), x_trial, y_trial, 'un', 0 );

left_durs = cellfun( @(x, y) sum(x(y)), dur_trial, left_ib );
right_durs = cellfun( @(x, y) sum(x(y)), dur_trial, right_ib );

durs = [ left_durs(:), right_durs(:) ];

end