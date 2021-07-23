is_human = false;

conf = hww5.config.load();

if ( is_human )
  conf.PATHS.data_root = '/Volumes/external/data/changlab/hww5_human';
end

filter_files_func = @identity;
% filter_files_func = @(x) hwwa.files_containing(x, {'04-Jul-2020', '02-Sep'});
% task_ids = hww5.task_ids;
task_ids = { 'ba' };

outs = hww5_basic_behavior( ...
    'config', conf ...
  , 'is_parallel', true ...
  , 'task_ids', task_ids ...
  , 'filter_files_func', filter_files_func ...
  , 'error_handler', 'error' ...
);

if ( is_human )
  addsetcat( outs.labels, 'drug', 'saline' );
else
  hww5.labels.assign_drug( outs.labels, hww5.labels.drugs_by_session() );
end

hww5.labels.add_task_order( outs.labels );

%%
cols = {'subject', 'day', 'drug'};
day_info = sortrows( combs(outs.labels, cols)' );
t = cell2table( day_info, 'variablenames', cols );
writetable( t, '~/Desktop/day_info.csv' );

%%

[task_id_I, task_ids] = findall( outs.labels, 'task-id' );
nan_ids = {};

for i = 1:numel(task_id_I)
  nan_rt = isnan( outs.rt(task_id_I{i}) );
  if ( pnz(nan_rt) == 1 )
    nan_ids{end+1} = task_ids{i};
  end
end

%%

pup_I = findall( outs.labels, {'run-id', 'task-id'} );
num_devs = 2;

pup_inds = hww5.find_within_sds( outs.pupil_size, num_devs, pup_I );
num_orig = cellfun( @numel, pup_I );
num_new = cellfun( @numel, pup_inds );

pup_inds = sort( vertcat(pup_inds{:}) );

thresh_cat = 'within-pupil-trial-criterion';

addsetcat( outs.labels, thresh_cat, sprintf('%s-false', thresh_cat) );
setcat( outs.labels, thresh_cat, sprintf('%s-true', thresh_cat), pup_inds );

prune( outs.labels );
%%

do_save = false;

per_day = false;

% norm_combs = [ false ];
% subject_combs = [ true, false ];
% norm_by_task_order_combs = true;
% pupil_crit_combs = trufls;
% gf_per_delays = trufls;

norm_combs = false;
subject_combs = false;
norm_by_task_order_combs = false;
pupil_crit_combs = false;
gf_per_delays = false;

all_combs = dsp3.numel_combvec( norm_combs, subject_combs ...
  , norm_by_task_order_combs, pupil_crit_combs, gf_per_delays );

% task_ids = hww5.task_ids;
task_ids = { 'ac' };

% task_ids = { 'sm', 'ja' };
% task_ids = setdiff( hww5.task_ids, task_ids );
% task_ids = { 'ac', 'ba' };

% base_mask_func = @(l, m) findnone(l, 'cron', m);
base_mask_func = @(l, m) m;
% base_mask_func = @(l, m) find(l, '070220', m);

base_mask = base_mask_func( outs.labels ...
  , base_mask_func(outs.labels, rowmask(outs.labels)) );

for i = 1:size(all_combs, 2)
  shared_utils.general.progress( i, size(all_combs, 2) );
  
  normalize = norm_combs(all_combs(1, i));
  per_subject = subject_combs(all_combs(2, i));
  norm_by_task_order = norm_by_task_order_combs(all_combs(3, i));
  use_pupil_crit = pupil_crit_combs(all_combs(4, i));
  gf_per_delay = gf_per_delays(all_combs(5, i));
  
  if ( per_day )
    [day_I, day_C] = findall( outs.labels, 'day', base_mask );
  else
    day_I = {rowmask(outs.labels)};
    day_C = {''};
  end
  
  for j = 1:numel(day_I)        
    fprintf( '\n\t %d of %d', j, numel(day_I) );
    if ( normalize )
      day_mask_func = @(l, m) intersect(base_mask_func(l, m), day_I{j});
      sal_mask_func = @(l, m) fcat.mask(l, base_mask_func(l, m) ...
        , @find, 'saline' ...
      );
    
      mask_func = @(l, m) union(day_mask_func(l, m), sal_mask_func(l, m));
      
      drug_combs = combs( outs.labels, 'drug', day_I{j} );
      if ( all(strcmp(drug_combs, 'saline')) )
        % Skip saline days.
        continue;
      end
    else
      mask_func = @(l, m) intersect(base_mask_func(l, m), day_I{j});
    end
    
    base_subdir = day_C{j};

    if ( use_pupil_crit )
      mask_func = @(l, m) fcat.mask(l, mask_func(l, m) ...
        , @find, sprintf('%s-true', thresh_cat) ...
      );
      base_subdir = fullfile( base_subdir, 'with_trial_selection_criterion' );
    else
      base_subdir = fullfile( base_subdir, 'all_trials' );
    end

    hww5_basic_behavior_plots( outs ...
      , 'save', do_save ...
      , 'normalize', normalize ...
      , 'per_subject', per_subject ...
      , 'task_ids', task_ids ...
      , 'norm_by_task_order', norm_by_task_order ...
      , 'ba_per_left_right_image_category', true ...
      , 'ba_per_trial_type', false ...
      , 'gf_per_delay', gf_per_delay ...
      , 'ac_per_image_category', false ...
      , 'pupil_per_task_id', false ...
      , 'base_subdir', base_subdir ...
      , 'mask_func', mask_func ...
    );
  end
end