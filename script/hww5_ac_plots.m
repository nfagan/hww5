find_task = @(l, id) @(m) find(l, id, m);

is_drug = true;
is_norm = true;
is_omnibus = true;
remove_pupil_outliers = false;
norm_each_task_order = false;
task_order_factor = false;
% drugs = { 'ot', 'saline' };
drugs = { 'ot', '5htp', 'saline' };

subj_func = ternary( is_drug, @hww5.find_nhp, @(l, m) hww5.find_nhp(l, find(l, 'saline', m)) );
drug_func = ternary( is_drug, hww5.make_find(drugs), @hww5.identity_mask_func );
pup_outlier_func = ternary( ...
  remove_pupil_outliers, @hww5.find_non_outliers, @hww5.identity_mask_func );

%%  ac plots rt

ac_rt_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'ac') ...
  , @(m) subj_func(l, m) ...
  , @(m) drug_func(l, m) ...
  , @(m) pup_outlier_func(l, m) ...
);

per_expressions = trufls;
per_rois = trufls;
per_subjects = false;
do_norm = is_norm && is_drug;
do_save = true;
overlay_points = false;
med_split_first_halves = false;
keep_first_n_across_runs_c = false;

if ( do_norm )
  log_transforms = false;
else
  log_transforms = false;
end

im_cat = 'image-category';

plt_combs = dsp3.numel_combvec( ...
    per_expressions ...
  , per_subjects ...
  , med_split_first_halves ...
  , log_transforms ...
  , per_rois ...
  , keep_first_n_across_runs_c ...
);

for idx = 1:size(plt_combs, 2)
  
shared_utils.general.progress( idx, size(plt_combs, 2) );
  
c = plt_combs(:, idx);
per_expression = per_expressions(c(1));
per_subject = per_subjects(c(2));
med_split_first_half = med_split_first_halves(c(3));
log_transform = log_transforms(c(4));
per_roi = per_rois(c(5));
keep_first_n_across_runs = keep_first_n_across_runs_c(c(6));

if ( ~per_roi && ~per_expression ), continue; end

im_roi = 'image-roi';

xcats = {};
fcats = {};
if ( is_drug )
  pcats = { 'task-id', 'subject-type' };
  gcats = { 'drug' };
else
  pcats = {'task-id', 'drug', 'subject-type'};
  gcats = {};
end
if ( per_subject )
  fcats{end+1} = 'subject';
end

each = {'run-id'};
norm_each = {'subject'};
if ( norm_each_task_order )
  norm_each{end+1} = 'task-order';
end
norm_cats = {'drug'};
norm_labs = {'saline'};
anova_each = {'subject-type'};
anova_factors = {};

plot_subdir = 'basic_behavior/ac_rt';
if ( med_split_first_half )
  error( 'No longer supported' );
  plot_subdir = [ plot_subdir, '-med-split' ];
end
if ( log_transform )
  plot_subdir = [ plot_subdir, '-log-tform' ];
end
if ( per_subject )
  plot_subdir = [ plot_subdir, '-per-subject' ];
end
if ( keep_first_n_across_runs )
  plot_subdir = [ plot_subdir, '-first-n-across-runs' ];
end

if ( is_drug )
  anova_factors{end+1} = 'drug';
end
if ( task_order_factor )
  anova_factors{end+1} = 'task-order';
end

if ( per_expression )
  if ( is_omnibus )
    anova_factors{end+1} = im_cat;
  else
    anova_each{end+1} = im_cat;
  end
  each{end+1} = im_cat;
  norm_each{end+1} = im_cat;
end
if ( per_roi )
  if ( is_omnibus )
    anova_factors{end+1} = im_roi;
  else
    anova_each{end+1} = im_roi;
  end
  each{end+1} = im_roi;
  norm_each{end+1} = im_roi;
end

if ( per_expression && per_roi )
  pcats{end+1} = im_cat;
  xcats{end+1} = im_roi;
elseif ( per_expression )
  if ( is_drug )
    xcats{end+1} = im_cat;  
  else
    gcats{end+1} = im_cat;
  end
elseif ( per_roi )
  if ( is_drug )
    xcats{end+1} = im_roi;
  else
    gcats{end+1} = im_roi;
  end
end

if ( keep_first_n_across_runs )
  keep_preprocess = @(data, labels, mask) hww5.preprocess_keep_first_n( ...
    data, labels, mask, {'run-id'} );
else
  keep_preprocess = [];
end

med_split_preprocess = @(data, labels, mask) hww5.preprocess_median_split_keep_first_half(...
  data, labels, mask, {'run-id'} );

[mean_rt, mean_labs] = hww5.maybe_normalize_and_collapse( outs.rt, outs.labels' ...
  , 'mask_func', ac_rt_mask_func ...
  , 'collapse', true ...
  , 'collapse_op', @(x) nanmedian(x, 1) ...
  , 'collapse_each', each ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
  , 'preprocess', ternary(keep_first_n_across_runs, keep_preprocess, []) ...
);

if ( numel(combs(mean_labs, 'drug')) == 1 )
  anova_factors = setdiff( anova_factors, {'drug'} );
end

anova_outs = dsp3.anovan2( mean_rt, mean_labs', anova_each, anova_factors );
if ( do_save )
  save_p = hww5.plot_directory( conf, plot_subdir, 'stats' );
  dsp3.save_anova_outputs( anova_outs, save_p, [anova_factors, anova_each] );
end  

hww5.plot_significant_anova_effects( mean_rt, mean_labs', anova_outs, plot_subdir ...
  , 'do_save', do_save ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
);

if ( log_transform )
  mean_rt = log10( mean_rt );
end

hww5.plot.ac_rt( mean_rt, mean_labs ...
  , 'mean', false ...
  , 'norm', false ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', fcats ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
  , 'do_save', do_save ...
  , 'config', conf ...
  , 'per_panel_labels', true ...
  , 'plot_subdir', plot_subdir ...
);

d =10;

end

%%  rt over time

ac_rt_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'ac') ...
  , @(m) subj_func(l, m) ...
  , @(m) drug_func(l, m) ...
  , @(m) hww5.find_non_outliers(l, m) ...
  , @(m) hww5.find_nhp(l, m) ...
);

per_expressions = true;
per_rois = trufls;
per_subjects = trufls;
do_save = true;

im_cat = 'image-category';
im_roi = 'image-roi';

plt_combs = dsp3.numel_combvec( ...
    per_expressions ...
  , per_subjects ...
  , per_rois ...
);

trial_bin = 5;
trial_step = trial_bin;

for idx = 1:size(plt_combs, 2)
  
shared_utils.general.progress( idx, size(plt_combs, 2) );
  
c = plt_combs(:, idx);
per_expression = per_expressions(c(1));
per_subject = per_subjects(c(2));
per_roi = per_rois(c(3));

fcats = {'subject-type'};
if ( is_drug )
  pcats = { 'task-id' };
  gcats = { 'drug' };
else
  pcats = {'task-id', 'drug'};
  gcats = {};
end
if ( per_subject )
  fcats{end+1} = 'subject';
end

each = {'run-id'};

plot_subdir = 'basic_behavior/ac_rt-over-time';
if ( per_subject )
  plot_subdir = [ plot_subdir, '-per-subject' ];
end
if ( per_roi )
  each{end+1} = im_roi;
end
if ( per_expression )
  each{end+1} = im_cat;
end
if ( per_roi && per_expression )
  pcats{end+1} = im_cat;
  gcats{end+1} = im_roi;
elseif ( per_expression )
  gcats{end+1} = im_cat;
elseif ( per_roi )
  gcats{end+1} = im_roi;
end

[tcourse, tcourse_labels] = hww5.trial_timecourse( outs.rt, outs.labels' ...
  , ac_rt_mask_func(outs.labels, rowmask(outs.labels)) ...
  , each, trial_bin, trial_step );

hww5.plot.lines( tcourse, tcourse_labels ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', fcats ...
  , 'do_save', do_save ...
  , 'plot_subdir', plot_subdir ...
);

end

%%  pcorr

find_task = @(l, id) @(m) find(l, id, m);

subj_func = ternary( is_drug, @hww5.find_nhp, @hww5.find_nhp_saline_or_human );
drug_func = ternary( is_drug, hww5.make_find(drugs), @hww5.identity_mask_func );

ac_pcorr_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'ac') ...
  , @(m) subj_func(l, m) ...
  , @(m) drug_func(l, m) ...
  , @(m) find(l, 'initiated-true', m) ...
  , @(m) hww5.find_non_outliers(l, m) ...
);

pcorr_mask = ac_pcorr_mask_func( outs.labels, rowmask(outs.labels) );
pcorr_each = { 'run-id', 'image-roi', 'image-category' };
[pcorr_labels, pcorr_I] = keepeach( ...
  outs.labels', pcorr_each, pcorr_mask );

pcorr = zeros( numel(pcorr_I), 1 );
for i = 1:numel(pcorr_I)
  tot_n = numel( pcorr_I{i} );
  num_corr = numel( find(outs.labels, 'completed-true', pcorr_I{i}) );
  pcorr(i) = num_corr / tot_n;
end

per_expressions = trufls;
per_subjects = trufls;
do_norm = is_norm && is_drug;
do_save = true;
overlay_points = false;
im_cat = 'image-category';

plt_combs = dsp3.numel_combvec( ...
    per_expressions ...
  , per_subjects ...
);

for idx = 1:size(plt_combs, 2)
  
shared_utils.general.progress( idx, size(plt_combs, 2) );
  
c = plt_combs(:, idx);
per_expression = per_expressions(c(1));
per_subject = per_subjects(c(2));

xcats = {'image-roi'};
fcats = {};
if ( is_drug )
  pcats = { 'task-id', 'subject-type' };
  gcats = { 'drug' };
else
  pcats = {'task-id', 'drug', 'subject-type'};
  gcats = {};
end
if ( per_subject )
  fcats{end+1} = 'subject';
end

norm_each = {'subject', 'image-roi'};
if ( norm_each_task_order )
  norm_each{end+1} = 'task-order';
end
norm_cats = {'drug'};
norm_labs = {'saline'};
anova_each = {'subject-type'};
anova_factors = { 'image-roi' };
anova_effect_pcats = { 'subject-type', 'task-id' };

plot_subdir = 'basic_behavior/ac_pcorr';
if ( per_subject )
  plot_subdir = [ plot_subdir, '-per-subject' ];
end

if ( is_drug )
  anova_factors{end+1} = 'drug';
end
if ( task_order_factor )
  anova_factors{end+1} = 'task-order';
end

if ( per_expression )
  each{end+1} = im_cat;
  anova_factors{end+1} = im_cat;
  if ( is_drug )
    pcats{end+1} = im_cat;
  else
    gcats{end+1} = im_cat;
  end
  norm_each{end+1} = im_cat;
end

[mean_corr, mean_labs] = hww5.maybe_normalize_and_collapse( pcorr, pcorr_labels' ...
  , 'collapse', false ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
);

if ( numel(combs(mean_labs, 'drug')) == 1 )
  anova_factors = setdiff( anova_factors, {'drug'} );
end

anova_outs = dsp3.anovan2( mean_corr, mean_labs', anova_each, anova_factors );
if ( do_save )
  save_p = hww5.plot_directory( conf, plot_subdir, 'stats' );
  dsp3.save_anova_outputs( anova_outs, save_p, [anova_factors, anova_each] );
end

hww5.plot_significant_anova_effects( mean_corr, mean_labs', anova_outs, plot_subdir ...
  , 'do_save', do_save ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
);

hww5.plot.ac_rt( mean_corr, mean_labs'...
  , 'mean', false ...
  , 'norm', false ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', fcats ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
  , 'do_save', do_save ...
  , 'config', conf ...
  , 'per_panel_labels', true ...
  , 'plot_subdir', plot_subdir ...
);

end
