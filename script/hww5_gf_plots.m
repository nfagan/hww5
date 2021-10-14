%%  gf plots

find_task = @(l, id) @(m) find(l, id, m);
find_correct = @(l) @(m) find(l, 'correct-true', m);

is_drug = true;
subj_func = ternary( is_drug, @hww5.find_nhp, @hww5.find_nhp_saline_or_human );

sesh_I = findall( outs.labels, 'run-id' );
within_devs = hww5.logical_map_rows_each( ...
  outs.rt, sesh_I, @(data) hww5.within_deviations(data, 2) );

gf_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'gf') ...
  , find_correct(l) ...
  , @(m) subj_func(l, m) ...
);

% , @(m) hww5.find_nhp(l, m) ...

each = {'run-id', 'trial-type', 'correct'};
norm_each = {'subject', 'trial-type', 'correct'};
if ( norm_each_task_order )
  norm_each{end+1} = 'task-order';
end
norm_cats = {'drug'};
norm_labs = {'saline'};
anova_each = {'subject-type'};
anova_factors = {'trial-type'};
if ( is_drug )
  anova_factors{end+1} = 'drug';
end
if ( task_order_factor )
  anova_factors{end+1} = 'task-order';
end

xcats = {'trial-type'};

if ( is_drug )
  gcats = {'drug'};
  pcats = {'correct', 'subject-type'};
else
  gcats = {};
  pcats = {'correct', 'drug', 'subject-type'};
end

do_save = true;
do_norm = true;

plot_subdir = 'basic_behavior/gf_rt';

[mean_rt, mean_labs] = hww5.maybe_normalize_and_collapse( outs.rt, outs.labels' ...
  , 'mask_func', gf_mask_func ...
  , 'collapse', true ...
  , 'collapse_each', each ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
  , 'exclude_non_finite', true ...
);

anova_outs = dsp3.anovan2( mean_rt, mean_labs', anova_each, anova_factors );
if ( do_save )
  save_p = hww5.plot_directory( conf, fullfile(plot_subdir, 'stats') );
  dsp3.save_anova_outputs( anova_outs, save_p, [anova_factors, anova_each] );
end

hww5.plot_significant_anova_effects( mean_rt, mean_labs', anova_outs, plot_subdir ...
  , 'do_save', do_save ...
  , 'addtl_pcats', anova_each ...
);

hww5.plot.gf_rt( mean_rt, mean_labs' ...
  , 'mean', false ...
  , 'norm', false ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'points_are', {'subject'} ...
  , 'do_save', do_save ...
  , 'plot_subdir', plot_subdir ...
  , 'y_label', 'Response time (s)' ...
  , 'per_panel_labels', true ...
);

%%  pcorr

find_task = @(l, id) @(m) find(l, id, m);
gf_pcorr_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'gf') ...
  , @(m) subj_func(l, m) ...
);

%   , @(m) hww5.find_nhp(l, m) ...

gf_each = { 'run-id', 'trial-type' };
[pcorr, pcorr_labels] = proportions_of( outs.labels, gf_each, 'correct' ...
  , hwwa.make_mask(outs.labels, gf_pcorr_mask_func) );

plt_mask_func = @(l, m) pipe(m, @(m) find(l, 'correct-true', m));

norm_each = {'subject', 'correct', 'trial-type'};
if ( norm_each_task_order )
  norm_each{end+1} = 'task-order';
end
norm_cats = {'drug'};
norm_labs = {'saline'};

xcats = 'trial-type';
if ( is_drug )
  gcats = {'drug'};
  pcats = {'correct', 'subject-type'};
else
  gcats = {'correct'};
  pcats = {'drug', 'subject-type'};
end

anova_each = {'subject-type', 'correct'};
anova_factors = {'trial-type'};
if ( is_drug )
  anova_factors{end+1} = 'drug';
end
if ( task_order_factor )
  anova_factors{end+1} = 'task-order';
end
plot_subdir = 'basic_behavior/gf_pcorr';

do_save = true;
do_norm = true;

[pcorr, pcorr_labels] = hww5.maybe_normalize_and_collapse( pcorr, pcorr_labels ...
  , 'collapse', false ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
  , 'exclude_non_finite', true ...
);

anova_outs = dsp3.anovan2( pcorr, pcorr_labels, anova_each, anova_factors );
if ( do_save )
  save_p = hww5.plot_directory( conf, fullfile(plot_subdir, 'stats') );
  dsp3.save_anova_outputs( anova_outs, save_p, [anova_factors, anova_each] );
end

hww5.plot_significant_anova_effects( pcorr, pcorr_labels', anova_outs, plot_subdir ...
  , 'do_save', do_save ...
  , 'addtl_pcats', anova_each ...
);

hww5.plot.gf_pcorr( pcorr, pcorr_labels ...
  , 'mask_func', plt_mask_func ...
  , 'each', {} ...
  , 'mean', false ...
  , 'norm', false ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'points_are', {'subject'} ...
  , 'y_label', '% correct' ...
  , 'do_save', do_save ...
  , 'per_panel_labels', true ...
);

%%  saccade info

gf_mask = gf_mask_func( outs.labels, rowmask(outs.labels) );
gf_saccades = outs.trial_saccades(gf_mask);
gf_rois = outs.rois(gf_mask);
gf_labels = outs.labels(gf_mask);

ib_info = false( numel(gf_saccades), 2 );
peak_vel = nan( numel(gf_saccades), 1 );
sacc_start_inds = nan( size(peak_vel) );
sacc_start_pos = nan( numel(gf_saccades), 2 );

for i = 1:numel(gf_saccades)
  gf_sacc = gf_saccades{i};
  stop_p = hww5.saccade_stop_pos( gf_sacc );
  
  roi_l = gf_rois{i}.left_target;
  roi_r = gf_rois{i}.right_target;
  roi_scr = gf_rois{i}.screen;
  
  ib_l = shared_utils.rect.inside( roi_l, stop_p );
  ib_r = shared_utils.rect.inside( roi_r, stop_p );
  
  min_l = find( ib_l, 1 );
  min_r = find( ib_r, 1 );
  min_ind = [];

  empty_l = isempty( min_l );
  empty_r = isempty( min_r );

  if ( empty_l && ~empty_r )
    % right
    ib_info(i, 2) = true;
    min_ind = min_r;
    
  elseif ( empty_r && ~empty_l )
    % left
    ib_info(i, 1) = true;
    min_ind = min_l;
    
  elseif ( ~empty_l && ~empty_r )
    if ( min_l < min_r )
      ib_info(i, 1) = true;
      min_ind = min_l;
      
    else
      ib_info(i, 2) = true;
      min_ind = min_r;
    end
  end
  
  if ( ~isempty(min_ind) )
    start_pos = hww5.saccade_start_pos( gf_sacc(min_ind, :) );
    px = max( 0, min(1, shared_utils.rect.fract_x( roi_scr, start_pos(1))) );
    py = max( 0, min(1, shared_utils.rect.fract_x( roi_scr, start_pos(2))) );
    px_norm = abs( px * 2 - 1 );
    
    peak_vel(i) = hww5.saccade_peak_vel( gf_sacc(min_ind, :) );
    sacc_start_inds(i) = hww5.saccade_start_ind( gf_sacc(min_ind, :) );
    sacc_start_pos(i, :) = [px_norm, py];
  end
end

has_sacc = any( ib_info, 2 );

%%  peak vel

norm_each = {'trial-type', 'correct'};
norm_cats = {'drug'};
norm_labs = {'saline'};

hww5.plot.gf_peak_vel( peak_vel, gf_labels' ...
  , 'mask_func', gf_mask_func ...
  , 'each', {'run-id', 'trial-type', 'correct'} ...
  , 'xcats', {'trial-type'} ...
  , 'gcats', {} ...
  , 'pcats', {'correct', 'drug', 'subject-type'} ...
  , 'points_are', {'subject'} ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
  , 'do_save', true...
  , 'norm', true ...
  , 'y_label', 'Saccade peak velocity (deg/s)' ...
);

%%  eye pos

do_save = true;

heat_map_each = {'run-id', 'trial-type', 'correct'};

[heat_maps, heat_map_labs, x_edges, y_edges] = hwwa_make_gaze_heatmap( ...
  sacc_start_pos(:, 1), sacc_start_pos(:, 2), gf_labels, heat_map_each, [-1, 1], [0, 1], 0.05, 0.05 ...
  , 'mask', gf_mask_func(gf_labels, rowmask(gf_labels)) ...
);

pcats = setdiff( heat_map_each, 'run-id' );
pcats = union( pcats, {'subject'} );

pl = plotlabeled.make_spectrogram( y_edges, x_edges );
axs = pl.imagesc( heat_maps, heat_map_labs, pcats );

if ( do_save )
  shared_utils.plot.fullscreen( gcf );
  dsp3.req_savefig( gcf, hww5.plot_directory(conf, 'basic_behavior/gf_sacc_start_heatmap') ...
    , heat_map_labs, pcats );
end
