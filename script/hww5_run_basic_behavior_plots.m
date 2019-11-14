conf = hww5.config.load();

outs = hww5_basic_behavior( 'config', conf );
hww5.labels.assign_drug( outs.labels, hww5.labels.drugs_by_session() );

%%

hww5_basic_behavior_plots( outs ...
  , 'save', false ...
);

%%