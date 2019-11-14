function hww5_basic_behavior_plots(outs, varargin)

defaults = hww5.plot_defaults( hww5.make_defaults() );
defaults.mask_func = @(labels) rowmask(labels);

params = shared_utils.general.parsestruct( defaults, varargin );
task_ids = cellstr( params.task_ids );

base_mask = get_base_mask( outs.labels, params.mask_func );

for i = 1:numel(task_ids)
  task_id = task_ids{i};
  
  inputs = input_dispatch( task_id, outs, base_mask, params );
  feval( sprintf('%s_plots', task_id), inputs{:} );
end

end

function outs = input_dispatch(task_id, outs, base_mask, params)

switch ( task_id )
  case 'ba'
    outs = { outs.labels', outs.lookdur, base_mask, params };
  case {'ja', 'sm'}
    outs = { outs.labels', base_mask, params };
  case {'gf', 'ac'}
    outs = { outs.labels', outs.rt, base_mask, params };
  otherwise
    error( 'Unhandled case "%s".', task_id );
end

end

function sm_plots(labels, mask, params)

sm_mask = find( labels, 'sm', mask );
sm_percent_correct( labels, sm_mask, params );

end

function sm_percent_correct(labels, mask, params)

p_corr_each = { 'date', 'delay', 'trial-type' };
[p_corr, p_corr_labels] = percent_correct( labels, p_corr_each, mask );

pl = plotlabeled.make_common();

fcats = {'subject'};
xcats = 'drug';
gcats = 'delay';
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

[figs, axs, I] = pl.figures( @bar, p_corr, p_corr_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Percent correct' );

if ( params.save )
  save_p = plot_save_path( params, 'sm', 'percent_correct' );
  save_figs( figs, save_p, p_corr_labels, [fcats, pcats], I, params.prefix );
end

end

function ac_plots(labels, rt, mask, params)

ac_mask = find( labels, 'ac', mask );
ac_rt( labels, rt, ac_mask, params );

end

function ac_rt(labels, rt, mask, params)

mean_each = { 'date', 'image-category', 'image-roi' };
[rt_labels, I] = keepeach( labels', mean_each, mask );
mean_rt = bfw.row_nanmean( rt, I );

fcats = {'subject'};
xcats = {'drug'};
gcats = 'image-category';
pcats = [ {'subject', 'task-id', 'image-roi'}, cellstr(fcats) ];

pl = plotlabeled.make_common();

[figs, axs, I] = pl.figures( @bar, mean_rt, rt_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Response time' );

if ( params.save )
  save_p = plot_save_path( params, 'ac', 'response_time' );
  save_figs( figs, save_p, rt_labels, [fcats, pcats], I, params.prefix );
end

end

function gf_plots(labels, rt, mask, params)

gf_mask = find( labels, 'gf', mask );
gf_rt( labels, rt, gf_mask, params );

end

function gf_rt(labels, rt, mask, params)

mean_each = { 'date', 'delay', 'trial-type' };
[rt_labels, I] = keepeach( labels', mean_each, mask );
mean_rt = bfw.row_nanmean( rt, I );

fcats = {'subject'};
xcats = {'drug'};
gcats = 'delay';
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

pl = plotlabeled.make_common();

[figs, axs, I] = pl.figures( @bar, mean_rt, rt_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Response time' );

if ( params.save )
  save_p = plot_save_path( params, 'gf', 'response_time' );
  save_figs( figs, save_p, rt_labels, [fcats, pcats], I, params.prefix );
end

end

function ja_plots(labels, mask, params)

ja_mask = find( labels, 'ja', mask );
ja_percent_correct( labels, ja_mask, params );

end

function ja_percent_correct(labels, mask, params)

[p_corr, p_corr_labels] = percent_correct( labels, 'date', mask );

pl = plotlabeled.make_common();

fcats = {};
xcats = 'task-id';
gcats = 'drug';
pcats = [ {'subject'}, cellstr(fcats) ];

[figs, axs, I] = pl.figures( @bar, p_corr, p_corr_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Percent correct' );

if ( params.save )
  save_p = plot_save_path( params, 'ja', 'percent_correct' );
  save_figs( figs, save_p, p_corr_labels, [fcats, pcats], I, params.prefix );
end

end

function ba_plots(labels, lookdur, mask, params)

ba_mask = find( labels, 'ba', mask );
ba_lookdur( labels, lookdur, ba_mask, params );

end

function ba_lookdur(labels, lookdur, mask, params)

mean_each = { 'run-id', 'image-directness', 'left-image-category', 'right-image-category' };
[dur_labels, mean_I] = keepeach( labels', mean_each, mask );
dur_means = bfw.row_nanmean( lookdur, mean_I );

tmp_right_cat = cellstr( dur_labels, 'right-image-category' );
rmcat( dur_labels, {'right-image-category', 'image-category'} );
renamecat( dur_labels, 'left-image-category', 'image-category' );

repmat( dur_labels, 2 );
dur_means = [ dur_means(:, 1); dur_means(:, 2) ];
setcat( dur_labels, 'image-category', tmp_right_cat, (rows(dur_labels)/2 + 1):rows(dur_labels) );
current = cellstr( dur_labels, 'image-category' );
current = strrep( current, 'right-', '' );
current = strrep( current, 'left-', '' );
setcat( dur_labels, 'image-category', current );

pl = plotlabeled.make_common();

fcats = { 'subject' };
xcats = 'image-category';
gcats = 'drug';
pcats = [ {'image-directness', 'task-id'}, cellstr(fcats) ];

[figs, axs, I] = pl.figures( @bar, dur_means, dur_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Looking duration' );

if ( params.save )
  save_p = plot_save_path( params, 'ba', 'looking_duration' );
  save_figs( figs, save_p, dur_labels, [fcats, pcats], I, params.prefix );
end

end

function [data, new_labels] = percent_correct(labels, spec, mask)

[new_labels, I] = keepeach( labels', spec, mask );
data = nan( numel(I), 1 );

for i = 1:numel(I)
  num_tot = numel( I{i} );
  num_corr = numel( find(labels, 'correct-true', I{i}) );
  data(i) = num_corr / num_tot;
end

end

function p = plot_save_path(params, task_id, varargin)

p = fullfile( hww5.dataroot(params.config), 'plots', dsp3.datedir() ...
  , params.base_subdir, task_id, varargin{:} );

end

function save_figs(figs, save_p, labels, cats, inds, prefix)

for i = 1:numel(figs)
  f = figs(i);
  
  shared_utils.plot.fullscreen( f );
  dsp3.req_savefig( f, save_p, prune(labels(inds{i})), cats, prefix );
end

end

function mask = get_base_mask(labels, mask_func)

mask = mask_func( labels );

end