conf = hww5.config.load();

make_inputs = struct();
make_inputs.config = conf;
make_inputs.error_handler = 'error';
make_inputs.is_parallel = false;

%%

hww5.make_unified( make_inputs );
hww5.make_meta( make_inputs );
hww5.make_task_data( make_inputs );
hww5.make_stimuli_setup( make_inputs );
hww5.make_edfs( make_inputs );
hww5.make_edf_sync( make_inputs );

%%

