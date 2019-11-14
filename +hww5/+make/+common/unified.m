function out_file = unified(out_file, mat_file, mat_file_path)

[task_path, identifier, ext] = fileparts( mat_file_path );
[session_path, task_name] = fileparts( task_path );
[~, session_name] = fileparts( session_path );

identifier = [ identifier, ext ];

out_file.identifier = identifier;
out_file.session_dir_components = { session_name };
out_file.task_dir_components = { session_name, task_name };
out_file.task_id = task_name;

end