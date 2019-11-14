function defaults = make_defaults(assign_to)

if ( nargin == 0 )
  defaults = struct();
else
  defaults = assign_to;
end

defaults.loop_runner = [];
defaults.task_ids = hww5.task_ids();
defaults.files = [];
defaults.not_files = [];
defaults.filter_files_func = [];
defaults.overwrite = false;
defaults.append = true;
defaults.save = true;
defaults.log_level = 'info';
defaults.is_parallel = true;
defaults.keep_output = false;
defaults.error_handler = 'default';
defaults.skip_existing = true;
defaults.config = hww5.config.load();

end