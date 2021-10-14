%%  nhp

conf = hww5.config.load();
conf.PATHS.data_root = 'C:\data\hww5_nhp';

filter_files_func = @identity;
% filter_files_func = @(files) shared_utils.io.filter_files(files, '03-Sep-2019 17_52_53');
task_ids = hww5.task_ids;

nhp_outs = hww5_basic_behavior( ...
    'config', conf ...
  , 'is_parallel', true ...
  , 'task_ids', task_ids ...
  , 'filter_files_func', filter_files_func ...
  , 'error_handler', 'error' ...
);

hww5.labels.assign_drug( nhp_outs.labels, hww5.labels.drugs_by_session() );
hww5.labels.add_task_order( nhp_outs.labels );
addsetcat( nhp_outs.labels, 'subject-type', 'nhp' );

%%  human

conf = hww5.config.load();

% not_files = {'08-Jun-2021 15_07_55', '08-Jun-2021 15_08_06', '08-Jun-2021 15_07_49'};
% filter_files_func = @(files) shared_utils.io.filter_files(files, {}, not_files);
filter_files_func = @identity;

human_outs = hww5_basic_behavior( ...
    'config', conf ...
  , 'is_parallel', true ...
  , 'filter_files_func', filter_files_func ...
  , 'error_handler', 'error' ...
  , 'io_error_handler', 'warn' ...
  , 'include_edf', true ...
);

require5_per_day = false;
hww5.labels.add_task_order( human_outs.labels, require5_per_day );
addcat( human_outs.labels, 'drug' );
addsetcat( human_outs.labels, 'subject-type', 'human' );

ac_anger_ind = find( human_outs.labels, {'ac', 'anger'} );
ac_happiness_ind = find( human_outs.labels, {'ac', 'happiness'} );
setcat( human_outs.labels, whichcat(human_outs.labels, 'anger'), 'threat', ac_anger_ind );
setcat( human_outs.labels, whichcat(human_outs.labels, 'happiness'), 'lip', ac_happiness_ind );

%%  Fix eb7 subject.

task_dirs = hww5.task_ids;
eb7_file_ids = {};

for i = 1:numel(task_dirs)
  eb7_files = shared_utils.io.find( fullfile(hww5.dataroot, 'raw/EB7', task_dirs{i}), '.mat' );
  assert( numel(eb7_files) == 1 );
  eb7_id = shared_utils.io.filenames( eb7_files{1}, true );
  rep_ind = find( human_outs.labels, eb7_id );
  assert( numel(rep_ind) > 0 );
  assert( strcmp(combs(human_outs.labels, 'subject', rep_ind), 'FG6') );
  eb7_file_ids{i} = eb7_id;  
%   setcat( human_outs.labels, 'subject', 'EB7', rep_ind );
end

%%  combine outputs

fs = fieldnames( nhp_outs );
outs = struct();

for i = 1:numel(fs)
  nhp_field = nhp_outs.(fs{i});
  human_field = human_outs.(fs{i});
  if ( fcat.is(nhp_field) )
    combined = [ nhp_field'; human_field ];
  else
    combined = [ nhp_field; human_field ];
  end
  outs.(fs{i}) = combined;
end

%%  save

to_save = rmfield( outs, 'edf_file' );
save( fullfile(hww5.dataroot, 'preprocessed/behav.mat'), 'to_save' );

%%  load

outs = shared_utils.io.fload( fullfile(hww5.dataroot, 'preprocessed/behav.mat') );

%%  outlier detect

sesh_I = findall( outs.labels, 'run-id' );
% within_devs = hww5.logical_map_rows_each( ...
%   outs.rt, sesh_I, @(data) hww5.within_deviations(data, 2) );
within_devs = hww5.logical_map_rows_each( ...
  outs.pupil_size, sesh_I, @(data) hww5.within_deviations(data, 2) );

addsetcat( outs.labels, 'outlier', 'outlier-false' );
setcat( outs.labels, 'outlier', 'outlier-true', find(~within_devs) );

%%  compare outliers detected based on rt vs pupil size for ac

outlier_mask = pipe(rowmask(outs.labels) ...
  , @(m) find(outs.labels, {'ac'}, m) ...
  , @(m) intersect(m, find(~isnan(outs.pupil_size))) ...
  , @(m) intersect(m, find(~isnan(outs.rt))) ...
);

sesh_I = findall( outs.labels, 'run-id', outlier_mask );
rt_within_devs = hww5.logical_map_rows_each( ...
  outs.rt, sesh_I, @(data) hww5.within_deviations(data, 2) );
ps_within_devs = hww5.logical_map_rows_each( ...
  outs.pupil_size, sesh_I, @(data) hww5.within_deviations(data, 2) );

n_rt_outliers = sum( ~rt_within_devs(outlier_mask) );
n_pup_outliers = sum( ~ps_within_devs(outlier_mask) );

n_outlier = sum( ...
  ~ps_within_devs(outlier_mask) | ~rt_within_devs(outlier_mask) );

s = intersect( ...
    find(~ps_within_devs(outlier_mask)) ...
  , find(~rt_within_devs(outlier_mask)) ...
);

numel(s) / n_outlier

%%  total num pupil outliers

ps_outlier_mask = pipe(rowmask(outs.labels) ...
  , @(m) intersect(m, find(~isnan(outs.pupil_size))) ...
);
rt_outlier_mask = pipe(rowmask(outs.labels) ...
  , @(m) intersect(m, find(~isnan(outs.rt))) ...
);

ps_sesh_I = findall( outs.labels, 'run-id', ps_outlier_mask );
rt_sesh_I = findall( outs.labels, 'run-id', rt_outlier_mask );

ps_within_devs = hww5.logical_map_rows_each( ...
  outs.pupil_size, ps_sesh_I, @(data) hww5.within_deviations(data, 2) );
rt_within_devs = hww5.logical_map_rows_each( ...
  outs.rt, rt_sesh_I, @(data) hww5.within_deviations(data, 2) );

ps_outlier = intersect( ps_outlier_mask, find(~ps_within_devs) );
rt_outlier = intersect( rt_outlier_mask, find(~rt_within_devs) );

numel(ps_outlier) / numel(ps_outlier_mask)
numel(rt_outlier) / numel(rt_outlier_mask)
