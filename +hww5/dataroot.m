function p = dataroot(conf)

%   DATAROOT -- Get the absolute path to the root data directory.
%
%     p = hww5.dataroot() returns the path to the root data directory, as
%     defined in the saved config file.
%
%     p = hww5.dataroot( CONF ) uses the config file `CONF`, instead of the
%     saved config file.

if ( nargin < 1 || isempty(conf) )
  conf = hww5.config.load();
else
  hww5.util.assertions.assert__is_config( conf );
end

p = conf.PATHS.data_root;

end