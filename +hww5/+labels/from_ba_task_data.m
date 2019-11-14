function labs = from_ba_task_data(trial_file)

data = trial_file.data(:);

labs = fcat.with( {'image-category', 'image-directness' ...
  , 'left-image-category', 'right-image-category', 'left-image-filename' ...
  , 'right-image-filename'}, numel(data) );

left_images = {data.left_image_category};
right_images = {data.right_image_category};
left_image_files = cellfun( @(x) sprintf('left-%s', x), {data.left_image_filename}, 'un', 0 );
right_image_files = cellfun(@(x) sprintf('right-%s', x),{data.right_image_filename}, 'un', 0 );
image_directness = {data.directness};

pairs = cellfun( @(x, y) strjoin(sort({x, y}), '-'), left_images, right_images, 'un', 0 );

setcat( labs, 'image-category', pairs );
setcat( labs, 'left-image-category', cellfun(@(x) sprintf('left-%s', x), left_images, 'un', 0) );
setcat( labs, 'right-image-category', cellfun(@(x) sprintf('right-%s', x), right_images, 'un', 0) );
setcat( labs, 'image-directness', image_directness );
setcat( labs, 'left-image-filename', left_image_files );
setcat( labs, 'right-image-filename', right_image_files );

end