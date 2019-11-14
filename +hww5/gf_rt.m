function rt = gf_rt(trial_file)

events = hww5.cell_events_to_struct( {trial_file.data.events} );
rt = arrayfun( @(x) x.gf_entered_target - x.images_on, events );

end