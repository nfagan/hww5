function name = directory_name(varargin)

if ( nargin == 0 )
  name = '';
  return
end

dir_path = varargin{1};
name = dir_path;

intermediate_str = sprintf( 'intermediates%s', filesep );

intermediate_dir = strfind( dir_path, intermediate_str );

if ( numel(intermediate_dir) ~= 1 )
  return;
end

try
  num_str = numel( intermediate_str );
  name = dir_path(intermediate_dir+num_str:end);
  
  if ( isempty(name) )
    name = dir_path;
  end
  
catch err
  warning( err.message );
end

end