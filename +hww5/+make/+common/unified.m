function out_file = unified(out_file, mat_file, mat_file_path)

[task_path, identifier, ext] = fileparts( mat_file_path );
[session_path, task_name] = fileparts( task_path );
[~, session_name] = fileparts( session_path );

identifier = [ identifier, ext ];

out_file.identifier = identifier;
out_file.session_dir_components = { session_name };
out_file.task_dir_components = { session_name, task_name };
out_file.task_id = task_name;
out_file.run_index = run_index( task_path, identifier );

if ( isfield(out_file, 'opts') )
  out_file.opts = prune_opts( out_file.opts );
end

end

function opts = prune_opts(opts)

% image_info contains the raw data for each image. We don't need to
% duplicate this since it's already present in the raw task file.
if ( shared_utils.struct.is_field(opts, 'STIMULI.setup.image_info') )
  opts.STIMULI.setup = rmfield( opts.STIMULI.setup, 'image_info' );
end

end

function run_ind = run_index(task_path, identifier)

mats = shared_utils.io.filenames( shared_utils.io.findmat(task_path) );
dates = sort( datetime(hww5.labels.identifier_to_date(mats)) );
ident_to_date = datetime( hww5.labels.identifier_to_date(identifier) );

[~, run_ind] = ismember( ident_to_date, dates );

if ( run_ind == 0 )
  error( 'No date matched "%s".', identifier );
end

end