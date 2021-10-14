function [dat, labs] = ac_basic_bars(data, labels, varargin)

assert_ispair( data, labels );

defaults = struct();
defaults.mean = true;
defaults.each = { 'run-id' };
defaults.xcats = {};
defaults.gcats = {};
defaults.pcats = {};
defaults.fcats = {};
defaults.mask_func = @(l, m) m;
defaults.points_are = {};
defaults.do_save = false;
defaults.norm = false;
defaults.norm_each = {};
defaults.norm_cats = {};
defaults.norm_labs = {};
defaults.plot_subdir = 'basic_behavior';
defaults.config = hww5.config.load();
defaults.y_label = '';
defaults.y_lims = [];
defaults.exclude_non_finite = false;
defaults.per_panel_labels = false;

validateattributes( data, {'double'}, {'column'}, mfilename, 'data' );

params = shared_utils.general.parsestruct( defaults, varargin );
mask = params.mask_func( labels, rowmask(labels) );

if ( params.mean )
  [labs, I] = keepeach( labels', params.each, mask );
  dat = bfw.row_nanmean( data, I );
else
  dat = data(mask, :);
  labs = labels(mask);
end

if ( params.norm )
  [dat, labs] = hww5.normalize_to( ...
    dat, labs, params.norm_each, params.norm_cats, params.norm_labs );
end

if ( params.exclude_non_finite )
  finite_ind = find( isfinite(dat) );
  dat = dat(finite_ind);
  labs = labs(finite_ind);
end

hww5.plot.basic_bars( dat, labs, params.xcats, params.gcats, params.pcats, params.fcats ...
  , 'config', params.config ...
  , 'points_are', params.points_are ...
  , 'do_save', params.do_save ...
  , 'plot_subdir', params.plot_subdir ...
  , 'y_label', params.y_label ...
  , 'y_lims', params.y_lims ...
  , 'per_panel_labels', params.per_panel_labels ...
);

end