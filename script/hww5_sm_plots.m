%%  sm plots

collapse_delays = true;

find_task = @(l, id) @(m) find(l, id, m);
subj_func = ternary( is_drug, @hww5.find_nhp, @hww5.find_nhp_saline_or_human );
drug_func = ternary( is_drug, hww5.make_find(drugs), @hww5.identity_mask_func );

sm_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'sm') ...
  , @(m) find(l, 'initiated-true', m) ...
  , @(m) subj_func(l, m) ...
  , @(m) drug_func(l, m) ...
  , @(m) hww5.find_non_outliers(l, m) ...
);

sm_mask = sm_mask_func( outs.labels, rowmask(outs.labels) );
sm_labels = prune( outs.labels(sm_mask) );

if ( collapse_delays )
  replace_each = { 'subject-type' };
  replace_I = findall( sm_labels, replace_each );
  for i = 1:numel(replace_I)
    replace_ind = replace_I{i};
    [to_rep, to_rep_with] = hww5.make_small_med_large_delay_labels( ...
      combs(sm_labels, 'delay', replace_ind) );
    
    for j = 1:numel(to_rep)
      rep_ind = findor( sm_labels, to_rep{j}, replace_ind );
      setcat( sm_labels, 'delay', to_rep_with{j}, rep_ind );
    end
  end
end

[pcorr, pcorr_labels] = proportions_of( ...
  sm_labels, {'run-id', 'delay', 'trial-type'}, 'correct' );

%%

do_norm = is_norm && is_drug;
do_save = true;
overlay_points = false;
per_trial_types = trufls;

plt_combs = dsp3.numel_combvec( ...
    per_trial_types ...
);

for idx = 1:size(plt_combs, 2)
  
shared_utils.general.progress( idx, size(plt_combs, 2) );
  
c = plt_combs(:, idx);
per_trial_type = per_trial_types(c(1));

if ( do_norm )
  ylims = [];
else
  ylims = [0, 1];
end

norm_each = {'subject', 'delay'};
if ( norm_each_task_order )
  norm_each{end+1} = 'task-order';
end
if ( per_trial_type )
  norm_each{end+1} = 'trial-type';
end
norm_cats = {'drug'};
norm_labs = {'saline'};

anova_each = {'subject-type'};
anova_factors = {'delay'};
if ( per_trial_type )
  anova_factors{end+1} = 'trial-type';
end
if ( is_drug )
  anova_factors{end+1} = 'drug';
end
if ( task_order_factor )
  anova_factors{end+1} = 'task-order';
end

xcats = {'delay'};
if ( is_drug )
  gcats = {'drug'};
  pcats = {'trial-type', 'task-id', 'correct', 'subject-type'};
else
  gcats = {'trial-type'};
  pcats = {'drug', 'task-id', 'correct', 'subject-type'};
end
if ( ~per_trial_type )
  gcats = setdiff( gcats, {'trial-type'} );
  pcats = setdiff( pcats, {'trial-type'} );
end

plot_subdir = 'basic_behavior/sm_pcorr';

[mean_pcorr, mean_labs] = hww5.maybe_normalize_and_collapse( pcorr, pcorr_labels' ...
  , 'mask_func', @(l, m) find(l, 'correct-true', m) ...
  , 'collapse', false ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', norm_cats ...
  , 'norm_labs', norm_labs ...
  , 'exclude_non_finite', true ...
);

if ( numel(combs(mean_labs, 'drug')) == 1 )
  anova_factors = setdiff( anova_factors, {'drug'} );
end

anova_outs = dsp3.anovan2( mean_pcorr, mean_labs', anova_each, anova_factors );
if ( do_save )
  save_p = hww5.plot_directory( conf, fullfile(plot_subdir, 'stats') );
  dsp3.save_anova_outputs( anova_outs, save_p, [anova_factors, anova_each] );
end

hww5.plot_significant_anova_effects( mean_pcorr, mean_labs', anova_outs, plot_subdir ...
  , 'do_save', do_save ...
  , 'addtl_pcats', anova_each ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
);

hww5.plot.sm_pcorr( mean_pcorr, mean_labs ...
  , 'mean', false ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'fcats', {} ...
  , 'norm', false ...
  , 'points_are', ternary(overlay_points, {'subject'}, {}) ...
  , 'y_label', '% correct' ...
  , 'y_lims', ylims ...
  , 'do_save', do_save ...
  , 'config', conf ...
  , 'exclude_non_finite', true ...
  , 'per_panel_labels', true ...
  , 'plot_subdir', plot_subdir ...
);

end
