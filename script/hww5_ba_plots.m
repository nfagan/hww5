%%  ba plots

find_task = @(l, id) @(m) find(l, id, m);
find_saline = @(l) @(m) find(l, 'saline', m);

ba_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'ba') ...
  , find_saline(l) ...
  , @(m) find(l, 'correct-true', m) ...
);

im_cond = 'image-condition';
im_cat = 'image-category';
im_dir_cat = 'image-directness';
first_look_cat = 'first-look-image-category';

ba_ind = find( outs.labels, 'ba' );
ba_labels = prune( outs.labels(ba_ind) );
renamecat( ba_labels, im_cat, im_cond );
addcat( ba_labels, im_cat );

first_look_labs = hww5.make_first_look_labels( ...
  outs.image_onset_fix_events(ba_ind, :), ba_labels );
addsetcat( ba_labels, first_look_cat, first_look_labs );

[lookdur, ind, im_cats] = hww5.collapse_left_right( outs.lookdur(ba_ind, :), ba_labels );
nfix = hww5.collapse_left_right( outs.num_fix(ba_ind, :), ba_labels );

lookdur_labels = prune( ba_labels(ind) );
setcat( lookdur_labels, im_cat, im_cats );

%%  lookdur / nfix

per_expression = false;
do_norm = false;
do_save = false;
is_lookdur = false;

xcats = { im_cat };
gcats = { im_dir_cat };
pcats = { 'task-id', 'drug', im_cond };
fcats = { 'subject' };
each = { 'run-id', im_cat, im_dir_cat, im_cond };
norm_each = { im_cat };

if ( is_lookdur )
  pltdat = lookdur;
  y_label = 'lookdur (ms)';
  plot_subdir = 'basic_behavior/ba_lookdur';
else
  pltdat = nfix;
  y_label = '# fixations';
  plot_subdir = 'basic_behavior/ba_nfix';
end

hww5.plot.ba_lookdur( pltdat, lookdur_labels ...
  , 'mask_func', ba_mask_func ...
  , 'each', each ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', fcats ...
  , 'points_are', {} ...
  , 'do_save', do_save ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', {'image-roi'} ...
  , 'norm_labs', {'scr'} ...
  , 'y_label', y_label ...
  , 'plot_subdir', plot_subdir ...
  , 'config', conf ...
);

%%  first look proportions

do_save = true;

ba_mask = ba_mask_func( ba_labels, rowmask(ba_labels) );
[props, prop_labels] = proportions_of( ...
  ba_labels, {'run-id', im_cond, im_dir_cat}, {first_look_cat}, ba_mask );

hww5.plot.ba_lookdur( props, prop_labels ...
  , 'mask_func', @(l, m) m ...
  , 'mean', false ...
  , 'xcats', first_look_cat ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', fcats ...
  , 'points_are', {} ...
  , 'do_save', do_save ...
  , 'y_label', 'Proportion' ...
  , 'y_lims', [0, 1] ...
  , 'plot_subdir', 'basic_behavior/ba_first_look' ...
  , 'config', conf ...
);

%%  image heatmap

ba_mask = ba_mask_func( outs.labels, rowmask(outs.labels) );
ba_rois = outs.rois(ba_mask);
ba_l_image = cat_expanded( 1, cellfun(@(x) x.left_image_roi, ba_rois, 'un', 0) );
ba_r_image = cat_expanded( 1, cellfun(@(x) x.right_image_roi, ba_rois, 'un', 0) );
ba_fix = outs.image_onset_fix_events(ba_mask, :);
ba_labels = prune( outs.labels(ba_mask) );

norm_fix = [];
norm_fix_labels = fcat();

for i = 1:size(ba_fix, 1)
  l_i = ba_l_image(i, :);
  r_i = ba_r_image(i, :);
  
  if ( ~isempty(ba_fix{i, 1}) )
    l_x = ba_fix{i, 1}(:, 2);
    l_y = ba_fix{i, 1}(:, 3);
  else
    l_x = zeros( 0, 2 );
    l_y = zeros( 0, 2 );
  end
  
  if ( ~isempty(ba_fix{i, 2}) )
    r_x = ba_fix{i, 2}(:, 2);
    r_y = ba_fix{i, 2}(:, 3);
  else
    r_x = zeros( 0, 2 );
    r_y = zeros( 0, 2 );
  end
  
  fx_l = shared_utils.rect.fract_x( l_i, l_x );
  fy_l = shared_utils.rect.fract_y( l_i, l_y );
  fx_r = shared_utils.rect.fract_x( r_i, r_x );
  fy_r = shared_utils.rect.fract_y( r_i, r_y );
  
  fl = [ fx_l(:), fy_l(:) ];
  fr = [ fx_r(:), fy_r(:) ];
  
  keep_l = all( fl >= 0 & fl <= 1, 2 );
  keep_r = all( fr >= 0 & fr <= 1, 2 );
  
  fl = fl(keep_l, :);
  fr = fr(keep_r, :);
  
  left_cat = strrep( cellstr(ba_labels, 'left-image-category', i), 'left-', '' );
  right_cat = strrep( cellstr(ba_labels, 'right-image-category', i), 'right-', '' );
  
  norm_fix = [ norm_fix; fl ];
  for j = 1:size(fl, 1)
    append( norm_fix_labels, ba_labels, i );
    setcat( norm_fix_labels, 'image-category', left_cat, rows(norm_fix_labels) );
  end
  norm_fix = [ norm_fix; fr ];
  for j = 1:size(fr, 1)
    append( norm_fix_labels, ba_labels, i );
    setcat( norm_fix_labels, 'image-category', right_cat, rows(norm_fix_labels) );
  end
end

assert_ispair( norm_fix, norm_fix_labels );

%%

do_save = true;
heat_map_each = {'run-id', 'image-category', 'correct'};

[heat_maps, heat_map_labs, x_edges, y_edges] = hwwa_make_gaze_heatmap( ...
  norm_fix(:, 1), norm_fix(:, 2), norm_fix_labels, heat_map_each, [0, 1], [0, 1], 0.05, 0.05 ...
  , 'mask', ba_mask_func(norm_fix_labels, rowmask(norm_fix_labels)) ...
);

% pcats = setdiff( heat_map_each, 'run-id' );
pcats = union( pcats, {'subject'} );

pl = plotlabeled.make_spectrogram( y_edges, x_edges );
axs = pl.imagesc( heat_maps, heat_map_labs, pcats );

if ( do_save )
  shared_utils.plot.fullscreen( gcf );
  dsp3.req_savefig( gcf, hww5.plot_directory(conf, 'basic_behavior/ba_image_heatmap') ...
    , heat_map_labs, pcats );
end
