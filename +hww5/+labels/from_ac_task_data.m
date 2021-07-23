function labs = from_ac_task_data(trial_file)

data = trial_file.data(:);
image_types = {data.image_type};
image_files = {data.image_file};

split_types = cellfun( @(x) strsplit(lower(x), '_'), image_types, 'un', 0 );
split_files = cellfun( @(x) strsplit(lower(x), '.'), image_files, 'un', 0 );

labs = fcat.with( {'image-category', 'image-roi'}, numel(split_types) );
orig_rois = { 'eyes', 'mouth', 'scr' };
orig_categories = { 'fear', 'lip', 'neutral', 'threat', 'anger', 'happiness' };

human_rois = orig_rois;
human_categories = { 'neutral', 'threat', 'anger', 'happiness', 'fear' };

for i = 1:numel(split_types)
  split_type = split_types{i};
  split_file = split_files{i};
  
  if ( numel(split_type) == 2 )    
    roi = select_one( orig_rois, split_type{1} );
    category = select_one( orig_categories, split_type{2} );
    
    if ( numel(roi) == 1 )
      setcat( labs, 'image-roi', roi, i );
    end
    
    if ( numel(category) == 1 )
      setcat( labs, 'image-category', category, i );
    end
  else
    error_str = 'Expected %d matches from string "%s"; got %d.';
    
    if ( numel(split_type) == 1 )
      category = select_one( human_categories, split_type{1} );
      
      if ( numel(category) == 1 )
        setcat( labs, 'image-category', category, i );
        
      else
        error( error_str, 1, image_types{i}, 0 );
      end
    else
      error( error_str, 1, image_types{i}, numel(split_type) );
    end
    
    if ( numel(split_file) == 4 )
      roi = '';
      if ( ~isempty(strfind(image_files{i}, 'scrambled')) )
        roi = 'scr';
      else
        if ( strcmp(split_file{3}, 'm') )
          roi = 'mouth';
        elseif ( strcmp(split_file{3}, 'e') )
          roi = 'eyes';          
        end
      end
      
      if ( isempty(roi) )
        error( error_str, 1, image_files{i}, 0 );
      else
        setcat( labs, 'image-roi', roi, i );
      end
      
    else
      error( error_str, 4, image_files{i}, numel(split_file) );
    end
  end
end

initiated = hww5.ac_initiated( trial_file );
completed = hww5.ac_completed( trial_file );

addsetcat( labs, 'initiated', 'initiated-false' );
setcat( labs, 'initiated', 'initiated-true', find(initiated) );
addsetcat( labs, 'completed', 'completed-false' );
setcat( labs, 'completed', 'completed-true', find(completed) );

end

function res = select_one(options, current)

res = options(cellfun(@(x) ~isempty(strfind(current, x)), options));

end