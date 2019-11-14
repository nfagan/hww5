function results = make_edfs(varargin)

defaults = hww5.make_defaults();
params = shared_utils.general.parsestruct( defaults, varargin );

task_ids = cellstr( params.task_ids );
results = cell( numel(task_ids), 1 );

for i = 1:numel(task_ids)
  task_id = task_ids{i};
  
  runner = hww5.make_runner( params );
  hww5.apply_inputs_outputs( runner, 'unified', 'edf', task_id, params.config );
  
  tmp_results = runner.run( @hww5.make.edf, task_id, params.config );
  results{i} = tmp_results(:);
end

results = hww5.cat_results( results );

end