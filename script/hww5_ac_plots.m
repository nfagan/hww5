%%  ac plots

find_task = @(l, id) @(m) find(l, id, m);
find_saline = @(l) @(m) find(l, 'saline', m);

ac_rt_mask_func = @(l, m) pipe(m ...
  , find_task(l, 'ac') ...
  , find_saline(l) ...
);

per_expression = false;
do_norm = false;
do_save = true;
im_cat = 'image-category';

xcats = {'image-roi'};
gcats = {};
pcats = {'task-id', 'drug', 'subject'};
each = {'run-id', 'image-roi'};
norm_each = {};

if ( per_expression )
  each{end+1} = im_cat;
  gcats{end+1} = im_cat;
  norm_each{end+1} = im_cat;
end

hww5.plot.ac_rt( outs.rt, outs.labels ...
  , 'mask_func', ac_rt_mask_func ...
  , 'each', each ...
  , 'xcats', xcats ...
  , 'gcats', gcats ...
  , 'pcats', pcats ...
  , 'points_are', {'subject'} ...
  , 'do_save', do_save ...
  , 'norm', do_norm ...
  , 'norm_each', norm_each ...
  , 'norm_cats', {'image-roi'} ...
  , 'norm_labs', {'scr'} ...
  , 'config', conf ...
);