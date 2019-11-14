function meta_file = meta(files, task_id)

un_kind = fullfile( 'unified', task_id );

hww5.validatefiles( files, un_kind );
unified_file = shared_utils.general.get( files, un_kind );

meta_file = struct();
meta_file.identifier = unified_file.identifier;
meta_file.task_id = unified_file.task_id;
meta_file.subject = unified_file.opts.META.subject;

end