
function conf = load()

%   LOAD -- Load the config file.

const = hww5.config.constants();

config_folder = const.config_folder;
config_file = const.config_filename;

config_filepath = fullfile( config_folder, config_file );

if ( exist(config_filepath, 'file') ~= 2 )
  fprintf( '\n Creating config file ...' );
  conf = hww5.config.create();
  hww5.config.save( conf );
end

conf = load( config_filepath );
conf = conf.(char(fieldnames(conf)));

try
  hww5.util.assertions.assert__is_config( conf );
catch err
  fprintf( ['\n Could not load the config file saved at ''%s'' because ' ...
    , ' it is not recognized as a valid config file.\n\n'], config_filepath );
  throwAsCaller( err );
end

end