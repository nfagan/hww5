function obj = make_runner(make_params)

if ( nargin < 1 || isempty(make_params) )
  make_params = hww5.make_defaults();
end

if ( nargin > 1 )
  make_params = shared_utils.general.parsestruct( make_params, varargin );
end

obj = shared_utils.pipeline.LoopedMakeRunner;

obj.files_aggregate_type = 'containers.Map';

% Whether to attempt to save output.
obj.save = make_params.save;

% Whether to attempt to run the function in parallel.
obj.is_parallel = make_params.is_parallel;

% Whether to allow existing files to be overwritten.
obj.overwrite = make_params.overwrite;

% Whether to keep the output in memory after saving, and return as part of
% `results`.
obj.keep_output = make_params.keep_output;

% Function that restricts the list of files in a directory to those
% containing string(s). However, if `files_containing` is empty, then all 
% files are used.

if ( isempty(make_params.filter_files_func) )
  obj.filter_files_func = @(x) shared_utils.io.filter_files( x, make_params.files, make_params.not_files );
else
  obj.filter_files_func = make_params.filter_files_func;
end

obj.get_directory_name_func = @(varargin) hww5.directory_name(varargin{:});

% Function that obtains the unified_filename from a loaded file.
obj.get_identifier_func = @(x, y) hww5.extract_identifier( x );

% Controls the verbosity of output to the console.
obj.log_level = make_params.log_level;

% Optionally sets error-handling behavior.
if ( ~strcmp(make_params.error_handler, 'default') )
  obj.set_error_handler( make_params.error_handler );
end

% Optionally avoid processing file identifiers that are already present
% in the object's output directory.
if ( make_params.skip_existing )
  obj.set_skip_existing_files();
end

end