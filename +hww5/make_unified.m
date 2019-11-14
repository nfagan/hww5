function results = make_unified(varargin)

defaults = hww5.make_defaults();
defaults.sessions = 'new';

params = shared_utils.general.parsestruct( defaults, varargin );

if ( ischar(params.sessions) && strcmp(params.sessions, 'new') )
  sessions = find_new_sessions( params );
else
  sessions = cellstr( params.sessions );
end

results = cell( numel(sessions), 1 );

for i = 1:numel(sessions)
  results{i} = run_session( sessions{i}, params );
end

results = hww5.cat_results( results );

end

function sessions = find_new_sessions(params)

raw_dirs = shared_utils.io.find( fullfile(hww5.dataroot(params.config), 'raw'), 'folders' );
possible_sessions = shared_utils.io.filenames( raw_dirs );
search_for = hww5.session_to_datestr( possible_sessions );

sessions = {};

task_ids = hww5.task_ids();
unified_mats = cell( size(task_ids) );

for i = 1:numel(task_ids)
  unified_p = hww5.intermediate_dir( fullfile('unified', task_ids{i}), params.config );
  
  if ( shared_utils.io.dexists(unified_p) )
    unified_mats{i} = shared_utils.io.findmat( unified_p );
  else
    unified_mats{i} = {};
  end
end

for i = 1:numel(search_for)
  for j = 1:numel(task_ids)
    has_session = cellfun( @(x) ~isempty(strfind(x, search_for{i})), unified_mats{j} );
    
    if ( isempty(has_session) || ~any(has_session) )
      sessions{end+1} = possible_sessions{i};
      break;
    end
  end
end

sessions = unique( sessions );

end

function results = run_session(session_dir, params)

session_dir_path = fullfile( hww5.dataroot(params.config), 'raw', session_dir );

task_id_func_map = containers.Map();
task_id_func_map('ac') = @ac_unified;
task_id_func_map('ba') = @ba_unified;
task_id_func_map('gf') = @gf_unified;
task_id_func_map('ja') = @ja_unified;
task_id_func_map('sm') = @sm_unified;

task_ids = keys( task_id_func_map );
results = cell( numel(task_ids), 1 );

for i = 1:numel(task_ids)
  task_id = task_ids{i};
  
  source_dir = fullfile( session_dir_path, task_id );
  dest_dir = hww5.intermediate_dir( fullfile('unified', task_id), params.config );
  
  runner = hww5.make_runner( params );
  runner.input_directories = { source_dir };
  runner.output_directory = dest_dir;
  runner.load_func = @load;
  runner.get_identifier_func = @get_identifier;
  runner.call_with_filepath = true;
  runner.get_directory_name_func = @get_directory_name;
  
  tmp_results = runner.run( @wrap_func, task_id, task_id_func_map(task_id) );
  results{i} = tmp_results(:);
end

results = hww5.cat_results( results );

end

function name = get_directory_name(varargin)

[~, name] = fileparts( varargin{1} );

end

function out_file = wrap_func(files, file_path, task_id, unified_func, varargin)

src_file = shared_utils.general.get( files, task_id );
out_file = unified_func( src_file, file_path );

end

function out_file = ac_unified(mat_file, mat_file_path)

out_file = hww5.make.common.unified( mat_file, mat_file, mat_file_path );

end

function out_file = ba_unified(mat_file, mat_file_path)

out_file = hww5.make.common.unified( mat_file, mat_file, mat_file_path );

end

function out_file = gf_unified(mat_file, mat_file_path)

out_file = hww5.make.common.unified( mat_file, mat_file, mat_file_path );

end

function out_file = ja_unified(mat_file, mat_file_path)

out_file = hww5.make.common.unified( mat_file, mat_file, mat_file_path );

end

function out_file = sm_unified(mat_file, mat_file_path)

out_file = hww5.make.common.unified( mat_file, mat_file, mat_file_path );

end

function out = get_identifier(varargin)

out = shared_utils.io.filenames( varargin{2}, true );

end