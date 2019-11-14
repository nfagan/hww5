function labs = from_ac_task_data(trial_file)

data = trial_file.data(:);
image_types = {data.image_type};
split_types = cellfun( @(x) strsplit(lower(x), '_'), image_types, 'un', 0 );

labs = fcat.with( {'image-category', 'image-roi'}, numel(split_types) );
rois = { 'eyes', 'mouth', 'scr' };
categories = { 'fear', 'lip', 'neutral', 'threat' };

for i = 1:numel(split_types)
  split_type = split_types{i};
  
  if ( numel(split_type) == 2 )    
    roi = select_one( rois, split_type{1} );
    category = select_one( categories, split_type{2} );
    
    if ( numel(roi) == 1 )
      setcat( labs, 'image-roi', roi, i );
    end
    
    if ( numel(category) == 1 )
      setcat( labs, 'image-category', category, i );
    end
  end
end

end

function res = select_one(options, current)

res = options(cellfun(@(x) ~isempty(strfind(current, x)), options));

end