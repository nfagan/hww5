function labels = add_ba_image_category_trial_type(labels, varargin)

mask = find( labels, 'ba', varargin{:} );
image_info = cellstr( labels, {'left-image-category', 'right-image-category'}, mask );

end