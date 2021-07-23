function outs = hww5_basic_behavior(varargin)

defaults = hww5.make_defaults();
defaults.include_edf = true;
params = hwwa.parsestruct( defaults, varargin );

task_ids = cellstr( params.task_ids );
results = cell( numel(task_ids), 1 );

inputs = { 'task_data', 'meta', 'stimuli_setup' };
if ( params.include_edf )
  inputs = [ inputs, {'edf', 'edf_sync'} ];
end

for i = 1:numel(task_ids)
  task_id = task_ids{i};

  runner = hww5.make_runner( params );
  hww5.apply_inputs_outputs( runner, inputs, '', task_id, params.config );
  runner.convert_to_non_saving_with_output();

  tmp_results = runner.run( @basic_behavior, task_id, params );
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

function rt = make_rt(task_data_file, stim_setup_file, task_id)

switch ( task_id )
  case 'gf'
    rt = hww5.gf_rt( task_data_file );
  case 'ac'
    rt = hww5.ac_rt( task_data_file );
  case 'ja'
    rt = hww5.ja_rt( task_data_file, stim_setup_file );
  otherwise
    rt = nan( numel(task_data_file.data), 1 );
end

end

function name = fixation_acquired_fieldname(task_id)

switch ( task_id )
  case 'ac'
    name = 'ac_fixation_acquired';
  case {'ba', 'gf', 'ja'}
    name = 'fixation_acquired';    
  case 'sm'
    name = 'sm_present_image';
end

end

function pupil_size = make_pupil_size(task_data_file, edf_file, sync_file, task_id)

fix_acq_name = fixation_acquired_fieldname( task_id );

fix_acquired = events_to_edf( task_data_file.data, fix_acq_name, sync_file );
fix_onset = fix_acquired - 150;

pupil_size = nan( numel(fix_onset), 1 );

for i = 1:numel(fix_onset)
  start = fix_onset(i);
  stop = fix_acquired(i);
  
  if ( isnan(start) || isnan(stop) )
    continue;
  end
  
  t_ind = edf_file.samples.time >= start & edf_file.samples.time <= stop;
  pupil_size(i) = nanmean( edf_file.samples.pupilSize(t_ind) );
end

end

function [lookdur, fixdur, num_fix] = ...
  make_look_info(task_data_file, edf_file, sync_file, stim_setup_file, task_id)

lookdur = nan( numel(task_data_file.data), 2 );
fixdur = nan( size(lookdur) );
num_fix = nan( size(lookdur) );

if ( ~strcmp(task_id, 'ba') && ~strcmp(task_id, 'sm') )
  return
end

switch ( task_id )
  case 'ba'
    image_onset_evt = 'ba_images_on';
    image_offset_evt = 'ba_reward_on';
    image_rois = {task_data_file.left_image_roi, task_data_file.right_image_roi};
    
  case 'sm'
    image_onset_evt = 'sm_image_on';
    image_offset_evt = 'sm_reward';
    image_rois = get_sm_rois( stim_setup_file );
    
  otherwise
    error( 'Unhandled task id "%s".', task_id );
end

image_onset = events_to_edf( task_data_file.data, image_onset_evt, sync_file );
image_offset = events_to_edf( task_data_file.data, image_offset_evt, sync_file );

for i = 1:numel(image_onset)
  start = image_onset(i);
  stop = image_offset(i);
  
  if ( isnan(start) || isnan(stop) )
    continue;
  end
  
  t_ind = edf_file.samples.time >= start & edf_file.samples.time <= stop;
  pos_x = edf_file.samples.posX(t_ind);
  pos_y = edf_file.samples.posY(t_ind);
  
  for j = 1:numel(image_rois)
    lookdur(i, j) = sum( bfw.bounds.rect(pos_x, pos_y, image_rois{j}) );
  end
  
  fix_t = edf_file.events.Efix.start;
  fix_t_ind = fix_t >= start & fix_t <= stop;
  fix_pos_x = edf_file.events.Efix.posX(fix_t_ind);
  fix_pos_y = edf_file.events.Efix.posY(fix_t_ind);
  fix_durs = edf_file.events.Efix.duration(fix_t_ind);
  
  for j = 1:numel(image_rois)
    is_ib_fix = bfw.bounds.rect( fix_pos_x, fix_pos_y, image_rois{j} );
    fixdur(i, j) = nanmean( fix_durs(is_ib_fix) );
    num_fix(i, j) = sum( is_ib_fix );
  end
end

end

function image_rois = get_sm_rois(stim_setup_file)

img_stim = stim_setup_file.stimuli_setup.sm_image1;
w = img_stim.size(1);
h = img_stim.size(2);

cx = mean( stim_setup_file.screen_rect([1, 3]) );
cy = mean( stim_setup_file.screen_rect([2, 4]) );

x0 = cx - w/2;
x1 = cx + w/2;
y0 = cy - h/2;
y1 = cy + h/2;

roi = [ x0, y0, x1, y1 ];
image_rois = { roi };

end

function fix_evts = ...
  make_image_onset_fix_events(task_data_file, edf_file, sync_file, task_id)

fix_evts = cell( numel(task_data_file.data), 2 );

if ( ~strcmp(task_id, 'ba') )
  return
end

image_onset = events_to_edf( task_data_file.data, 'ba_images_on', sync_file );
image_offset = events_to_edf( task_data_file.data, 'ba_reward_on', sync_file );

efix = edf_file.events.Efix;
sfix = efix.start;
fix_pos_x = efix.posX;
fix_pos_y = efix.posY;

roi_names = { 'left_image_roi', 'right_image_roi' };

for i = 1:numel(image_onset)
  start = image_onset(i);
  stop = image_offset(i);
  
  if ( isnan(start) || isnan(stop) )
    continue;
  end
  
  is_fix_within_t = sfix >= start & sfix <= stop;
  
  pos_within_tx = fix_pos_x(is_fix_within_t);
  pos_within_ty = fix_pos_y(is_fix_within_t);
  fix_ts = sfix(is_fix_within_t);
  
  for j = 1:numel(roi_names)
    roi = task_data_file.(roi_names{j});
    within_bounds = bfw.bounds.rect( pos_within_tx, pos_within_ty, roi );
    pos_info = [ ...
        columnize(fix_ts(within_bounds)) ...
      , columnize(pos_within_tx(within_bounds)) ...
      , columnize(pos_within_ty(within_bounds)) ...
    ];
  
    fix_evts{i, j} = pos_info;
  end
end

end

function events = events_to_edf(data, event_name, sync_file)

import shared_utils.struct.field_or;

image_onset_func = @(x) field_or( x.events, event_name, nan );

mat_ts = sync_file.mat;
edf_ts = sync_file.edf;

events = arrayfun( image_onset_func, data );
events = round( shared_utils.sync.cinterp(events, mat_ts, edf_ts) );

end

function outs = basic_behavior(files, task_id, params)

task_data_file = shared_utils.general.get( files, fullfile('task_data', task_id) );
meta_file = shared_utils.general.get( files, fullfile('meta', task_id) );
stim_setup_file = shared_utils.general.get( files, fullfile('stimuli_setup', task_id) );

if ( params.include_edf )
  edf_file = shared_utils.general.get( files, fullfile('edf', task_id) );
  sync_file = shared_utils.general.get( files, fullfile('edf_sync', task_id) );
end

labels = make_labels( task_data_file, meta_file );
rt = make_rt( task_data_file, stim_setup_file, task_id );

lookdur = [];
fixdur = [];
num_fix = [];
pupil_size = [];
image_onset_fix_events = [];

if ( params.include_edf )
  [lookdur, fixdur, num_fix] = ... 
    make_look_info( task_data_file, edf_file, sync_file, stim_setup_file, task_id );

  pupil_size = make_pupil_size( task_data_file, edf_file, sync_file, task_id );
  image_onset_fix_events = ...
    make_image_onset_fix_events( task_data_file, edf_file, sync_file, task_id );
end

outs = struct();
outs.rt = rt;
outs.pupil_size = pupil_size;
outs.lookdur = lookdur;
outs.fixdur = fixdur;
outs.num_fix = num_fix;
outs.labels = labels;
outs.image_onset_fix_events = image_onset_fix_events;

end