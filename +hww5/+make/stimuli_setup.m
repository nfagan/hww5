function stim_setup_file = stimuli_setup(files, task_id)

un_kind = fullfile( 'unified', task_id );

hww5.validatefiles( files, un_kind );
unified_file = shared_utils.general.get( files, un_kind );

stim_setup_file = struct();
stim_setup_file.identifier = unified_file.identifier;
stim_setup_file.task_id = unified_file.task_id;
stim_setup_file.stimuli_setup = unified_file.opts.STIMULI.setup;
stim_setup_file.screen_rect = unified_file.opts.WINDOW.rect;

end