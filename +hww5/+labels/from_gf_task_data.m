function labels = from_gf_task_data(data_file)

delay_strs = hww5.labels.prefixed_num2str( [data_file.data.delay], 'delay-' );
trial_type_strs = { data_file.data.trial_type };

was_correct = hww5.gf_was_correct( data_file );
initiated = hww5.gf_initiated( data_file );

was_correct_strs = hww5.labels.correct_str( was_correct );

labels = fcat.create( ...
  'delay', delay_strs ...
  , 'trial-type', trial_type_strs ...
  , 'correct', was_correct_strs ...
);

addsetcat( labels, 'initiated', 'initiated-false' );
setcat( labels, 'initiated', 'initiated-true', find(initiated) );
addsetcat( labels, 'completed', 'completed-false' );
setcat( labels, 'completed', 'completed-true', find(was_correct) );

end