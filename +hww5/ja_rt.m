function rt = ja_rt(data_file, stim_setup_file)

events = hww5.cell_events_to_struct( {data_file.data.events} );
reward_on = [ events.reward_on ];
stim_on = [ events.response_targets_on ];

targ_dur = stim_setup_file.stimuli_setup.ja_response1.target_duration;

entered_targ = reward_on - targ_dur;
rt = columnize( entered_targ - stim_on );

end