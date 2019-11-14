function labels = from_sm_task_data(data_file)

import hww5.labels.tf_str;

trial_data = data_file.data;

was_correct = hww5.sm_was_correct( data_file );
initiated = [ trial_data.initiated ];
cue_delays = [ trial_data.cue_delay ];

trial_type = { trial_data.trial_type };
cue_delay_strs = hww5.labels.prefixed_num2str( cue_delays, 'delay-' );
was_correct_strs = hww5.labels.correct_str( was_correct );
initiated_strs = arrayfun( @(x) sprintf('initiated-%s', tf_str(x)), initiated, 'un', 0 );

labels = fcat.create( 'trial-type', trial_type, 'delay', cue_delay_strs ...
  , 'correct', was_correct_strs, 'initiated', initiated_strs );

end