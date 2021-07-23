%%  gf plots

find_task = @(l, id) @(m) find(l, id, m);
find_saline = @(l) @(m) find(l, 'saline', m);
find_correct = @(l) @(m) find(l, 'correct-true', m);

gf_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'gf') ...
  , find_saline(l) ...
  , find_correct(l) ...
);

hww5.plot.gf_rt( outs.rt, outs.labels ...
  , 'mask_func', gf_mask_func ...
  , 'each', {'run-id', 'trial-type', 'correct'} ...
  , 'xcats', {'trial-type'} ...
  , 'gcats', {} ...
  , 'pcats', {'correct', 'drug'} ...
  , 'points_are', {'subject'} ...
  , 'do_save', true ...
  , 'norm', false ...
  , 'y_label', 'Response time (s)' ...
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

hww5.plot.gf_peak_vel( peak_vel, gf_labels' ...
  , 'mask_func', gf_mask_func ...
  , 'each', {'run-id', 'trial-type', 'correct'} ...
  , 'xcats', {'trial-type'} ...
  , 'gcats', {} ...
  , 'pcats', {'correct', 'drug'} ...
  , 'points_are', {'subject'} ...
  , 'do_save', true...
  , 'norm', false ...
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
