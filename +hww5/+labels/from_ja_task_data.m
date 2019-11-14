function labels = from_ja_task_data(data_file)

was_correct = hww5.ja_was_correct( data_file );

correct_strs = hww5.labels.correct_str( was_correct );
look_dir_strs = image_look_direction( data_file.data );
response_strs = response_direction( data_file.data );

labels = fcat.create( ...
    'correct', correct_strs ...
  , 'image-look-direction', look_dir_strs ...
  , 'response-direction', response_strs ...
);

end

function strs = response_direction(data)

strs = { data.response_direction };
strs = strrep( strs, 'center-', 'selected-' );
strs(cellfun('isempty', strs)) = { 'selected-none' };

end

function strs = image_look_direction(data)

strs = { data.image_look_direction };
strs = cellfun( @(x) sprintf('image-look-%s', x), strs, 'un', 0 );

end