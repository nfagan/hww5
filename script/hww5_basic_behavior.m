function outs = hww5_basic_behavior(varargin)

defaults = hww5.make_defaults();
params = hwwa.parsestruct( defaults, varargin );

task_ids = cellstr( params.task_ids );
results = cell( numel(task_ids), 1 );

inputs = { 'task_data', 'meta', 'edf', 'edf_sync' };

for i = 1:numel(task_ids)
  task_id = task_ids{i};

  runner = hww5.make_runner( params );
  hww5.apply_inputs_outputs( runner, inputs, '', task_id, params.config );
  runner.convert_to_non_saving_with_output();

  tmp_results = runner.run( @basic_behavior, task_id );
  results{i} = tmp_results(:);
end

results = hww5.cat_results( results );
outputs = shared_utils.pipeline.extract_outputs_from_results( results );

if ( ~isempty(outputs) )
  match_categories( outputs );
end

outs = shared_utils.struct.soa( outputs );

end

function match_categories(outputs)

labels = { outputs.labels };
categories = unique( cat_expanded(1, eachcell(@getcats, labels)) );
eachcell( @(x) addcat(x, categories), labels );

end

function labels = make_labels(task_data_file, meta_file)

labels = hww5.labels.from_task_data( task_data_file );
meta_labels = hww5.labels.from_meta( meta_file );

join( labels, meta_labels );

end

function rt = make_rt(task_data_file, task_id)

switch ( task_id )
  case 'gf'
    rt = hww5.gf_rt( task_data_file );
  case 'ac'
    rt = hww5.ac_rt( task_data_file );
  otherwise
    rt = nan( numel(task_data_file.data), 1 );
end

end

function lookdur = make_lookdur(task_data_file, edf_file, sync_file, task_id)

import shared_utils.struct.field_or;

lookdur = nan( numel(task_data_file.data), 2 );

if ( ~strcmp(task_id, 'ba') )
  return
end

image_onset_func = @(x) field_or( x.events, 'ba_images_on', nan );
image_offset_func = @(x) field_or( x.events, 'ba_reward_on', nan );

mat_ts = sync_file.mat;
edf_ts = sync_file.edf;

image_onset = arrayfun( image_onset_func, task_data_file.data );
image_offset = arrayfun( image_offset_func, task_data_file.data );

image_onset = round( shared_utils.sync.cinterp(image_onset, mat_ts, edf_ts) );
image_offset = round( shared_utils.sync.cinterp(image_offset, mat_ts, edf_ts) );

for i = 1:numel(image_onset)
  start = image_onset(i);
  stop = image_offset(i);
  
  if ( isnan(start) || isnan(stop) )
    continue;
  end
  
  t_ind = edf_file.samples.time >= start & edf_file.samples.time <= stop;
  pos_x = edf_file.samples.posX(t_ind);
  pos_y = edf_file.samples.posY(t_ind);
  
  lookdur(i, 1) = sum( bfw.bounds.rect(pos_x, pos_y, task_data_file.left_image_roi) );
  lookdur(i, 2) = sum( bfw.bounds.rect(pos_x, pos_y, task_data_file.right_image_roi) );
end

end

function outs = basic_behavior(files, task_id)

task_data_file = shared_utils.general.get( files, fullfile('task_data', task_id) );
meta_file = shared_utils.general.get( files, fullfile('meta', task_id) );
edf_file = shared_utils.general.get( files, fullfile('edf', task_id) );
sync_file = shared_utils.general.get( files, fullfile('edf_sync', task_id) );

labels = make_labels( task_data_file, meta_file );
rt = make_rt( task_data_file, task_id );
lookdur = make_lookdur( task_data_file, edf_file, sync_file, task_id );

outs = struct();
outs.rt = rt;
outs.lookdur = lookdur;
outs.labels = labels;

end