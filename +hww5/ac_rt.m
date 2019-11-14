function rt = ac_rt(data_file)

events = hww5.cell_events_to_struct( {data_file.data.events} );
rt = arrayfun( @(x) x.ac_entered_target - x.ac_images_on, events );

end