function [data, labels] = maybe_collapse_and_normalize(data, labels, varargin)

validateattributes( data, {'numeric'}, {'2d'}, mfilename, 'data' );

defaults = struct();
defaults.mask_func = @(l, m) m;
defaults.collapse = true;
defaults.collapse_op = @(x) nanmean(x, 1);
defaults.collapse_each = {};
defaults.norm = false;
defaults.norm_each = {};
defaults.norm_cats = {};
defaults.norm_labs = {};
defaults.exclude_non_finite = false;

params = shared_utils.general.parsestruct( defaults, varargin );
mask = params.mask_func( labels, rowmask(labels) );

if ( params.collapse )
  [labels, I] = keepeach( labels', params.collapse_each, mask );
  data = rowop( data, I, params.collapse_op );
else
  data = data(mask, :);
  labels = labels(mask);
end

if ( params.norm )
  [data, labels] = hww5.normalize_to( ...
    data, labels, params.norm_each, params.norm_cats, params.norm_labs );
end

if ( params.exclude_non_finite )
  finite_ind = find( isfinite(data) );
  data = data(finite_ind, :);
  labels = labels(finite_ind);
end

end