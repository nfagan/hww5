function hww5_basic_behavior_plots(outs, varargin)

defaults = hww5.plot_defaults( hww5.make_defaults() );
defaults.normalize = false;
defaults.per_subject = true;
defaults.mask_func = @(l, m) m;
defaults.norm_by_task_order = false;
defaults.ba_per_left_right_image_category = true;
defaults.ba_per_trial_type = true;
defaults.gf_per_delay = true;
defaults.ac_per_image_category = true;
defaults.pupil_per_task_id = true;
defaults.per_day = false;

params = shared_utils.general.parsestruct( defaults, varargin );
task_ids = cellstr( params.task_ids );

base_mask = get_base_mask( outs.labels, params.mask_func );

% pupil_size_plots( outs.pupil_size, outs.labels', base_mask, params );

for i = 1:numel(task_ids)
  task_id = task_ids{i};
  
  inputs = input_dispatch( task_id, outs, base_mask, params );
  feval( sprintf('%s_plots', task_id), inputs{:} );
end

end

function outs = input_dispatch(task_id, outs, base_mask, params)

switch ( task_id )
  case 'ba'
    outs = { outs.labels', outs.lookdur, outs.fixdur, outs.num_fix ...
      , outs.image_onset_fix_events ...
      , base_mask, params };
  case 'ja'
    outs = { outs.labels', outs.rt, base_mask, params };
  case 'sm'
    outs = { outs.lookdur(:, 1), outs.fixdur(:, 1), outs.num_fix(:, 1) ...
      , outs.labels', base_mask, params };
  case {'gf', 'ac'}
    outs = { outs.labels', outs.rt, base_mask, params };
  otherwise
    error( 'Unhandled case "%s".', task_id );
end

end

function pupil_size_plots(pupil_size, labels, mask, params)

%%

mean_each = { 'run-id', 'task-id' };
[ps_labels, I] = keepeach( labels', mean_each, mask );
mean_ps = bfw.row_nanmean( pupil_size, I );

[mean_ps, ps_labels] = maybe_normalize( mean_ps, ps_labels, mean_each, params );

if ( params.normalize )
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

fcats = {};

if ( params.per_subject )
  fcats{end+1} = 'subject';
end

xcats = { 'image-category' };
gcats = { 'drug' };
pcats = [ {'image-roi'}, cellstr(fcats) ];
pcats = maybe_include( pcats, {'task-id'}, params.pupil_per_task_id );

pl = plotlabeled.make_common();
pl.x_order = { 'neutral', 'lip', 'fear', 'threat' };
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

[figs, axs, I] = pl.figures( @bar, mean_ps, ps_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Pupil size' );

if ( params.save )
  save_p = plot_save_path( params, 'all', 'pupil_size' );
  save_figs( figs, save_p, ps_labels, [fcats, pcats], I, params.prefix );
end

end

function sm_plots(lookdur, fixdur, num_fix, labels, mask, params)

sm_mask = find( labels, 'sm', mask );

sm_lookdur( lookdur, labels, sm_mask, 'looking_duration', params );
% sm_lookdur( fixdur, labels, sm_mask, 'fixation_duration', params );
% sm_lookdur( num_fix, labels, sm_mask, 'num_fixations', params );

sm_percent_correct( labels, sm_mask, params );

end

function sm_lookdur(lookdur, labels, mask, data_type, params)

delay_cmbs = [false, true];
soc_minus_nonsoc_cmbs = trufls;
cs = dsp3.numel_combvec( delay_cmbs, soc_minus_nonsoc_cmbs );

for i = 1:size(cs, 2)
 
c = cs(:, i);
include_delay = delay_cmbs(c(1));
soc_minus_nonsoc = soc_minus_nonsoc_cmbs(c(2));

mean_each = { 'run-id', 'trial-type' };
mean_each = maybe_include_delay( mean_each, include_delay );

[mean_labs, mean_I] = keepeach( labels', mean_each, mask );
mean_lookdur = bfw.row_nanmean( lookdur, mean_I );

if ( soc_minus_nonsoc )
  [mean_lookdur, mean_labs] = ...
    social_minus_nonsocial( mean_lookdur, mean_labs, mean_each );
end

[mean_lookdur, mean_labs] = ...
  maybe_normalize( mean_lookdur, mean_labs, mean_each, params );

if ( params.normalize )  
  drug_order = normalized_drug_order();
  ylab = sprintf( 'Normalized %s', data_type );
else
  drug_order = raw_drug_order();
  ylab = sprintf( 'Raw %s', data_type );
end

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(false, varargin{:});

fcats = {'subject'};
xcats = maybe_include_delay( {}, include_delay );
gcats = 'drug';
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

if ( isempty(xcats) )
  tmp = gcats;
  gcats = xcats;
  xcats = tmp;
  pl.x_order = pl.group_order;
end

[figs, axs, I] = ...
  pl.figures( @errorbar, mean_lookdur, mean_labs, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), strrep(ylab, '_', ' ') );

if ( params.save )
  spec = [fcats, pcats, gcats, xcats];
  save_p = plot_save_path( params, 'sm', data_type );
  save_figs( figs, save_p, mean_labs, spec, I, params.prefix );
end

end

end

function sm_percent_correct(labels, mask, params)

p_corr_each = { 'run-id', 'delay', 'trial-type' };
init_mask = find( labels, 'initiated-true', mask );

soc_minus_nonsoc_combs = trufls;
recoded_delay_combs = trufls;

cs = dsp3.numel_combvec( soc_minus_nonsoc_combs, recoded_delay_combs );

for i = 1:size(cs, 2)
  
c = cs(:, i);
soc_minus_nonsoc = soc_minus_nonsoc_combs(c(1));
recode_delays = recoded_delay_combs(c(2));

p_corr_labels = labels';
maybe_recode_delays( p_corr_labels, recode_delays );

[p_corr, p_corr_labels] = percent_correct( p_corr_labels, p_corr_each, init_mask );

if ( soc_minus_nonsoc )
  [p_corr, p_corr_labels] = ...
    social_minus_nonsocial( p_corr, p_corr_labels, p_corr_each );
end

[p_corr, p_corr_labels] = ...
  maybe_normalize( p_corr, p_corr_labels, p_corr_each, params );

if ( params.normalize )
  group_order = normalized_drug_order();
else
  group_order = raw_drug_order();
end

pl = plotlabeled.make_common();
pl.group_order = group_order;
pl.color_func = @(varargin) color_function(false, varargin{:});

fcats = {'subject'};
xcats = 'delay';
gcats = 'drug';
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

[figs, axs, I] = ...
  pl.figures( @errorbar, p_corr, p_corr_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Percent correct' );

if ( params.save )
  spec = [fcats, pcats, gcats, xcats];
  save_p = plot_save_path( params, 'sm', 'percent_correct' );
  save_figs( figs, save_p, p_corr_labels, spec, I, params.prefix );
end

end

end

function ac_plots(labels, rt, mask, params)

ac_mask = find( labels, 'ac', mask );
ac_rt( labels, rt, ac_mask, params );
% ac_initiated( labels, ac_mask, params );

end

function ac_initiated(labels, mask, params)

mean_each = { 'run-id' };
initiated_outs = initiated_completed_info( labels, mean_each, mask );

fnames = fieldnames( initiated_outs.data );
data_sets = cellfun( @(x) initiated_outs.data.(x), fnames, 'un', 0 );
lab_sets = cellfun( @(x) initiated_outs.labels.(x), fnames, 'un', 0 );
kinds = fnames;

for i = 1:numel(data_sets)
  initiated_subplot( data_sets{i}, lab_sets{i}, kinds{i}, 'ac', mean_each, params );
end

end

function initiated_subplot(data, labels, data_kind, task_id, mean_each, params)

if ( params.normalize )
  norm_each = union( setdiff(mean_each, 'run-id'), {'subject'} );
  norm_each = maybe_include_task_order( norm_each, params.norm_by_task_order );
  
  [data, labels] = hww5.saline_normalize( data, labels, norm_each );
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

fcats = {};

if ( params.per_subject )
  fcats{end+1} = 'subject';
end

addtl_possible_cats = {'image-look-direction'};

xcats = {};
gcats = { 'drug' };
pcats = cellstr( fcats );
pcats = union( pcats, intersect(addtl_possible_cats, mean_each) );

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

[figs, axs, I] = pl.figures( @bar, data, labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), strrep(data_kind, '_', ' ') );

save_p = plot_save_path( params, task_id, data_kind );

if ( params.save )
  save_figs( figs, save_p, labels, [fcats, pcats, gcats], I, params.prefix );
end

if ( params.save )
  factors = [gcats, fcats];
  anova_outs = run_anovan( data, labels', {}, factors, rowmask(data) );
  
  stat_p = fullfile( save_p, 'stats' );
  dsp3.save_anova_outputs( anova_outs, stat_p, factors );
end

end

function ac_rt(labels, rt, mask, params)

mean_each = { 'run-id', 'image-roi' };
mean_each = maybe_include( mean_each, {'image-category'}, params.ac_per_image_category );

[rt_labels, I] = keepeach( labels', mean_each, mask );
mean_rt = bfw.row_nanmean( rt, I );

[mean_rt, rt_labels] = maybe_normalize( mean_rt, rt_labels, mean_each, params );

if ( params.normalize )
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

fcats = {};

if ( params.per_subject )
  fcats{end+1} = 'subject';
end

xcats = maybe_include( {}, {'image-category'}, params.ac_per_image_category );
gcats = { 'drug' };
pcats = [ {'task-id', 'image-roi'}, cellstr(fcats) ];

pl = plotlabeled.make_common();
pl.x_order = { 'neutral', 'lip', 'fear', 'threat' };
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

[figs, axs, I] = pl.figures( @bar, mean_rt, rt_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Response time' );

if ( params.save )
  save_p = plot_save_path( params, 'ac', 'response_time' );
  save_figs( figs, save_p, rt_labels, [fcats, pcats], I, params.prefix );
end

if ( params.save )
  factors = {'drug', 'image-roi'};
  factors = maybe_include_subject( factors, params.per_subject );
  factors = maybe_include( factors, {'image-category'}, params.ac_per_image_category );
  
  anova_outs = run_anovan( mean_rt, rt_labels', {}, factors, rowmask(mean_rt) );
  
  stat_p = fullfile( save_p, 'stats' );
  dsp3.save_anova_outputs( anova_outs, stat_p, factors );
end

end

function gf_plots(labels, rt, mask, params)

gf_mask = find( labels, 'gf', mask );

% gf_p_correct( labels, gf_mask, params );
gf_rt( labels, rt, gf_mask, params );
% gf_initiated( labels, gf_mask, params );

end

function gf_p_correct(labels, mask, params)

%%

const_minus_inconst_combs = trufls;
cond_combs = dsp3.numel_combvec( const_minus_inconst_combs );

for i = 1:size(cond_combs, 2)
  
cs = cond_combs(:, i);
const_minus_inconst = const_minus_inconst_combs(cs(1));

corr_each = { 'run-id', 'trial-type' };
corr_each = maybe_include_delay( corr_each, params.gf_per_delay );

[p_corr, p_corr_labels] = percent_correct( labels', corr_each, mask );
[p_corr, p_corr_labels] = ...
  maybe_consistent_minus_inconsistent( p_corr, p_corr_labels, corr_each, const_minus_inconst );
[p_corr, p_corr_labels] = maybe_normalize( p_corr, p_corr_labels, corr_each, params );

if ( params.normalize )
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

%%
fcats = maybe_include_subject( {}, params.per_subject );

xcats = maybe_include_delay( {}, params.gf_per_delay );
gcats = {'drug'};
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

[figs, axs, I] = pl.figures( @bar, p_corr, p_corr_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Percent correct' );

if ( params.save )
  save_p = plot_save_path( params, 'gf', 'percent_correct' );
  save_figs( figs, save_p, p_corr_labels, [xcats, fcats, pcats], I, params.prefix );
end

end

end

function gf_initiated(labels, mask, params)

mean_each = { 'run-id' };
initiated_outs = initiated_completed_info( labels, mean_each, mask );

fnames = fieldnames( initiated_outs.data );
data_sets = cellfun( @(x) initiated_outs.data.(x), fnames, 'un', 0 );
lab_sets = cellfun( @(x) initiated_outs.labels.(x), fnames, 'un', 0 );
kinds = fnames;

for i = 1:numel(data_sets)
  initiated_subplot( data_sets{i}, lab_sets{i}, kinds{i}, 'gf', mean_each, params );
end

end

function gf_rt(labels, rt, mask, params)

mean_each = maybe_include_delay( {'run-id', 'trial-type'}, params.gf_per_delay );
[base_labels, I] = keepeach( labels', mean_each, mask );
base_rt = bfw.row_nanmean( rt, I );

consistent_minus_inconsistent_combs = trufls;
cond_combs = dsp3.numel_combvec( consistent_minus_inconsistent_combs );

for i = 1:size(cond_combs, 2)
  
cs = cond_combs(:, i);
const_minus_inconst = consistent_minus_inconsistent_combs(cs(1));

mean_rt = base_rt;
rt_labels = base_labels';

[mean_rt, rt_labels] = ...
  maybe_consistent_minus_inconsistent( mean_rt, rt_labels, mean_each, const_minus_inconst );
[mean_rt, rt_labels] = maybe_normalize( mean_rt, rt_labels, mean_each, params );

if ( params.normalize )
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

fcats = maybe_include_subject( {}, params.per_subject );

xcats = maybe_include_delay( {}, params.gf_per_delay );
gcats = {'drug'};
pcats = [ {'subject', 'task-id', 'trial-type'}, cellstr(fcats) ];

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

[figs, axs, I] = pl.figures( @bar, mean_rt, rt_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Response time' );

if ( params.save )
  save_p = plot_save_path( params, 'gf', 'response_time' );
  save_figs( figs, save_p, rt_labels, [xcats, fcats, pcats], I, params.prefix );
end

end

end

function ja_plots(labels, rt, mask, params)

ja_mask = find( labels, 'ja', mask );

% ja_initiated_completed( labels, ja_mask, params );
% ja_rt( labels, rt, ja_mask, params );
ja_percent_correct( labels, ja_mask, params );

end

function ja_initiated_completed(labels, mask, params)

include_correct = true;
mean_each = { 'run-id' };
initiated_outs = initiated_completed_info( labels, mean_each, mask, include_correct );

fnames = fieldnames( initiated_outs.data );
data_sets = cellfun( @(x) initiated_outs.data.(x), fnames, 'un', 0 );
lab_sets = cellfun( @(x) initiated_outs.labels.(x), fnames, 'un', 0 );
kinds = fnames;

for i = 1:numel(data_sets)
  initiated_subplot( data_sets{i}, lab_sets{i}, kinds{i}, 'ja', mean_each, params );
end

%%

mean_each = { 'run-id', 'image-look-direction' };
per_direction_outs = initiated_completed_info( labels, mean_each, mask, include_correct );

fname = 'prop_correct_out_of_complete';
p_corr = per_direction_outs.data.(fname);
p_corr_labels = per_direction_outs.labels.(fname);

initiated_subplot( p_corr, p_corr_labels, fname, 'ja', mean_each, params );

end

function ja_rt(labels, rt, mask, params)

mean_each = { 'run-id' };
[rt_labels, I] = keepeach( labels', mean_each, mask );
mean_rt = bfw.row_nanmean( rt, I );

if ( params.normalize )
  norm_each = { 'subject' };
  norm_each = maybe_include_task_order( norm_each, params.norm_by_task_order );
  
  [mean_rt, rt_labels] = ...
    hww5.saline_normalize( mean_rt, rt_labels', norm_each );
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

pcats = {};

if ( params.per_subject )
  pcats{end+1} = 'subject';
end

fcats = {};
xcats = 'task-id';
gcats = 'drug';
pcats = [ pcats, cellstr(fcats) ];

[figs, axs, I] = pl.figures( @bar, mean_rt, rt_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Response time' );

if ( params.save )
  save_p = plot_save_path( params, 'ja', 'response_time' );
  save_figs( figs, save_p, rt_labels, [fcats, pcats], I, params.prefix );
end

end

function ja_percent_correct(labels, mask, params)

[p_corr, p_corr_labels] = percent_correct( labels, 'date', mask );

if ( params.normalize )
  norm_each = {'subject'};
  norm_each = maybe_include_task_order( norm_each, params.norm_by_task_order );
  
  [p_corr, p_corr_labels] = ...
    hww5.saline_normalize( p_corr, p_corr_labels, norm_each );
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

pcats = {};

if ( params.per_subject )
  pcats{end+1} = 'subject';
end

fcats = {};
xcats = 'task-id';
gcats = 'drug';
pcats = [ pcats, cellstr(fcats) ];

[figs, axs, I] = pl.figures( @bar, p_corr, p_corr_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), 'Percent correct' );

if ( params.save )
  save_p = plot_save_path( params, 'ja', 'percent_correct' );
  save_figs( figs, save_p, p_corr_labels, [fcats, pcats], I, params.prefix );
end

end

function ba_plots(labels, lookdur, fixdur, num_fix, image_onset_fix_events, mask, params)

ba_mask = find( labels, 'ba', mask );

% ba_firstlook( labels, image_onset_fix_events, ba_mask, params );

% ba_lookdur( labels, fixdur, ba_mask, 'Fixation duration', params );
ba_lookdur( labels, lookdur, ba_mask, 'Looking duration', params );
% ba_lookdur( labels, num_fix, ba_mask, 'Number of fixations', params );

% ba_initiated( labels, ba_mask, params );

end

function ba_initiated(labels, mask, params)

mean_each = { 'run-id' };
initiated_outs = initiated_completed_info( labels, mean_each, mask );

fnames = fieldnames( initiated_outs.data );
data_sets = cellfun( @(x) initiated_outs.data.(x), fnames, 'un', 0 );
lab_sets = cellfun( @(x) initiated_outs.labels.(x), fnames, 'un', 0 );
kinds = fnames;

for i = 1:numel(data_sets)
  initiated_subplot( data_sets{i}, lab_sets{i}, kinds{i}, 'ba', mean_each, params );
end

end

function labs = add_first_look_labels(labels, fix_events, mask, include_direction)

non_empties = cellfun( @(x) ~isempty(x), fix_events );
non_empty_inds = cellfun( @(x) min(x(:, 1)), fix_events(non_empties) );
ts = nan( size(fix_events) );
ts(non_empties) = non_empty_inds;

first_look_cat = 'first-look-image-category';
labs = labels';
addcat( labs, first_look_cat );

for i = 1:numel(mask)
  m = mask(i);
  
  [~, ind] = min( ts(m, :) );
  has_look = true;
  
  if ( ind == 1 )
    l = sprintf( 'first-%s',  char(cellstr(labels, 'left-image-category', m)) );
  elseif ( ind == 2 )
    l = sprintf( 'first-%s',  char(cellstr(labels, 'right-image-category', m)) );
  else
    has_look = false;
  end
  
  if ( has_look )
    if ( ~include_direction )
      l = strrep( l, 'left-', '' );
      l = strrep( l, 'right-', '' );
    end
    
    setcat( labs, first_look_cat, l, m );
  end
end

end

function [data, labels] = maybe_consistent_minus_inconsistent(data, labels, each, tf)

if ( tf )
  use_each = setdiff( each, {'trial-type'} );
  
  a = 'consistent';
  b = 'inconsistent';
  opfunc = @minus;
  sfunc = @nanmean;
  
  [data, labels] = ...
    dsp3.summary_binary_op( data, labels', use_each, a, b, opfunc, sfunc );
  
  setcat( labels, 'trial-type', sprintf('%s-%s', a, b) );
end

end

function [data, labels] = maybe_normalize(data, labels, each, params)

if ( params.normalize )  
  norm_each = union( setdiff(each, 'run-id'), 'subject' );
  norm_each = maybe_include_task_order( norm_each, params.norm_by_task_order );
  
  [data, labels] = hww5.saline_normalize( data, labels, norm_each );
end

end

function ba_firstlook(labels, fix_events, mask, params)

include_direction = false;
labs = add_first_look_labels( labels', fix_events, mask, include_direction );

props_each = { 'run-id', 'image-directness' };
props_of = { 'first-look-image-category' };

if ( params.ba_per_left_right_image_category )
  props_each{end+1} = 'image-category';
  
%   left_image_cat = cellstr( labels, 'left-image-category', mask );
%   right_image_cat = cellstr( labels, 'right-image-category', mask );
%   left_image_cat = eachcell( @(x) strrep(x, 'left-', ''), left_image_cat );
%   right_image_cat = eachcell( @(x) strrep(x, 'right-', ''), right_image_cat );
%   
%   pairs = sortrows( categorical([left_image_cat(:)'; right_image_cat(:)']) );
%   pairs = cellstr( pairs' );
%   pairs = eachcell( @(x, y) sprintf('%s-%s', x, y), pairs(:, 1), pairs(:, 2) );
%   
%   addsetcat( labs, 'ba-image-category-pair', pairs, mask );
end

[props, prop_labels] = proportions_of( labs, props_each, props_of, mask );
[props, prop_labels] = maybe_normalize( props, prop_labels', props_each, params );

if ( params.normalize )
  ylab = 'Normalized proportion of first looks to roi.';
  drug_order = normalized_drug_order();
else
  ylab = 'Proportion of first looks to roi.';
  drug_order = raw_drug_order();
end

%%
pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

fcats = maybe_include( {}, 'subject', params.per_subject );

xcats = 'first-look-image-category';
gcats = 'drug';
pcats = [ {'image-directness', 'task-id'}, cellstr(fcats) ];
pcats = maybe_include( pcats, {'image-category'}, params.ba_per_left_right_image_category );

[figs, axs, I] = pl.figures( @bar, props, prop_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), ylab );

%%
if ( params.save )
  save_p = plot_save_path( params, 'ba', 'first_look_proportions' );
  save_figs( figs, save_p, prop_labels, [fcats, pcats], I, params.prefix );
end

end

function ba_lookdur(labels, lookdur, mask, data_type, params)

mean_each = { 'run-id', 'image-directness' };

if ( params.ba_per_left_right_image_category )
  mean_each = [ mean_each, {'left-image-category', 'right-image-category'} ];
else
  mean_each = [ mean_each, {'image-category'} ];
end

[dur_labels, mean_I] = keepeach( labels', mean_each, mask );
dur_means = bfw.row_nanmean( lookdur, mean_I );

if ( params.normalize )
  norm_each = union( setdiff(mean_each, 'run-id'), 'subject' );
  norm_each = maybe_include_task_order( norm_each, params.norm_by_task_order );
  
  [dur_means, dur_labels] = hww5.saline_normalize( dur_means, dur_labels, norm_each );
  drug_order = normalized_drug_order();
else
  drug_order = raw_drug_order();
end

if ( params.ba_per_left_right_image_category )
  tmp_img_cat = cellstr( dur_labels, 'image-category' );
  tmp_right_cat = cellstr( dur_labels, 'right-image-category' );
  rmcat( dur_labels, {'right-image-category', 'image-category'} );
  renamecat( dur_labels, 'left-image-category', 'image-category' );
  addsetcat( dur_labels, 'ba-image-category-pair', tmp_img_cat );

  repmat( dur_labels, 2 );
  dur_means = [ dur_means(:, 1); dur_means(:, 2) ];
  setcat( dur_labels, 'image-category', tmp_right_cat, (rows(dur_labels)/2 + 1):rows(dur_labels) );
  current = cellstr( dur_labels, 'image-category' );
  current = strrep( current, 'right-', '' );
  current = strrep( current, 'left-', '' );
  setcat( dur_labels, 'image-category', current );
  
else
  dur_means = [ dur_means(:, 1); dur_means(:, 2) ];
  dur_labels = repmat( dur_labels', 2, 1 );
end

finite_mask = find( isfinite(dur_means) );
dur_means = dur_means(finite_mask);
dur_labels = dur_labels(finite_mask);

pl = plotlabeled.make_common();
pl.group_order = drug_order;
pl.color_func = @(varargin) color_function(params.normalize, varargin{:});

fcats = {'image-directness'};

if ( params.per_subject )
  fcats{end+1} = 'subject';
end

xcats = 'image-category';
gcats = {'drug'};
pcats = [ {'task-id'}, cellstr(fcats) ];

if ( params.ba_per_trial_type )
  pcats{end+1} = 'ba-image-category-pair';
end

[figs, axs, I] = ...
  pl.figures( @bar, dur_means, dur_labels, fcats, xcats, gcats, pcats );
shared_utils.plot.match_ylims( axs );
ylabel( axs(1), data_type );

if ( params.save )
  dir_name = strrep( lower(data_type), ' ', '_' );
  save_p = plot_save_path( params, 'ba', dir_name );
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

function colors = color_function(is_normalized, num_colors)

mat = raw_color_matrix();

if ( num_colors > rows(mat) )
  colors = jet( num_colors );
else
  if ( is_normalized )
    colors = mat(2:end, :);
  else
    colors = mat;
  end
end

end

function mat = raw_color_matrix()

saline = [ 0, 0, 0 ];
ot = [ 0, 0, 1 ];
ot_nal = [ 0, 1, 0 ];
htp = [ 1, 0, 0 ];
ot_5htp = [ 1, 0, 1 ];

mat = [ saline; ot; ot_nal; htp; ot_5htp ];

end

function order = normalized_drug_order()

order = { 'ot/saline', 'ot-nal/saline', '5htp/saline', 'ot-5htp/saline' };

end

function order = raw_drug_order()

order = { 'saline', 'ot', 'ot-nal', '5htp', 'ot-5htp' };

end

function d = normalized_subdir(params)

d = ternary( params.normalize, 'norm', 'non-norm' );

end

function p = plot_save_path(params, task_id, varargin)

p = fullfile( hww5.dataroot(params.config), 'plots', dsp3.datedir() ...
  , params.base_subdir, task_id, varargin{:}, normalized_subdir(params) );

end

function save_figs(figs, save_p, labels, cats, inds, prefix)

for i = 1:numel(figs)
  f = figs(i);
  
  shared_utils.plot.fullscreen( f );
  dsp3.req_savefig( f, save_p, prune(labels(inds{i})), cats, prefix );
end

end

function mask = get_base_mask(labels, mask_func)

mask = mask_func( labels, rowmask(labels) );

end

function each = maybe_include(each, v, tf)
if ( tf )
  each = csunion( each, v );
end
end

function norm_each = maybe_include_task_order(norm_each, tf)
if ( tf )
  norm_each = union( norm_each, {'task-order'} );
end
end

function each = maybe_include_subject(each, tf)
if ( tf )
  each = union( each, {'subject'} );
end
end

function each = maybe_include_delay(each, tf)
if ( tf )
  each = union( each, {'delay'} );
end
end

function anova_outs = run_anovan(data, labels, each, factors, mask)

try
  anova_outs = dsp3.anovan( data, labels, each, factors ...
    , 'mask', mask ...
    , 'remove_nonsignificant_comparisons', false ...
    , 'dimension', 1:numel(factors) ...
  );
catch err
  warning( err.message );
  anova_outs = [];
end

end

function outs = initiated_completed_info(labels, each, mask, include_correct)

if ( nargin < 4 )
  include_correct = false;
end

[count_initiated, initiated_labs] = ...
  counts_of( labels, each, 'initiated', mask );
[count_completed, completed_labs] = ...
  counts_of( labels, each, 'completed', mask );

[prop_initiated, prop_initiated_labs] = ...
  proportions_of( labels, each, 'initiated', mask );
[prop_completed, prop_completed_labs] = ...
  proportions_of( labels, each, 'completed', mask );

[p_complete_labs, p_complete_I] = keepeach( labels', each, mask );

p_complete = nan( size(p_complete_I) );
p_correct_out_of_complete = nan( size(p_complete_I) );

for i = 1:numel(p_complete_I)
  init_mask = find( labels, 'initiated-true', p_complete_I{i} );
  num_completed = numel( find(labels, 'completed-true', init_mask) );
  p_complete(i) = num_completed / numel( init_mask );
  
  complete_mask = find( labels, 'completed-true', p_complete_I{i} );
  correct_mask = find( labels, 'correct-true', complete_mask );
  p_correct_out_of_complete(i) = numel( correct_mask ) / numel( complete_mask );
end

outs = struct();
outs.data = struct();
outs.labels = struct();

outs.data.count_initiated = count_initiated;
outs.labels.count_initiated = initiated_labs;

outs.data.count_completed = count_completed;
outs.labels.count_completed = completed_labs;

outs.data.prop_initiated = prop_initiated;
outs.labels.prop_initiated = prop_initiated_labs;

outs.data.prop_completed = prop_completed;
outs.labels.prop_completed = prop_completed_labs;

outs.data.prop_complete_out_of_initiated = p_complete;
outs.labels.prop_complete_out_of_initiated = p_complete_labs;

if ( include_correct )
  outs.data.prop_correct_out_of_complete = p_correct_out_of_complete;
  outs.labels.prop_correct_out_of_complete = p_complete_labs';
end

end

function [data, labels] = social_minus_nonsocial(data, labels, each)

use_each = setdiff( each, {'trial-type'} );
a = 'social';
b = 'nonsocial';

opfunc = @minus;
sfunc = @nanmean;

[data, labels] = ...
  dsp3.summary_binary_op( data, labels', use_each, a, b, opfunc, sfunc );

maybe_setcat( labels, 'trial-type', sprintf('%s-%s', a, b) );

end

function labels = maybe_recode_delays(labels, tf)

if ( tf )
  labels = hww5.labels.sm_recode_delays_as_sml( labels );
end

end