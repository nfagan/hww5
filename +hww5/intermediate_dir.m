function p = intermediate_dir(kind, conf)

%   INTERMEDIATE_DIR -- Get the absolute path to an intermediate directory.
%
%     p = ... intermediate_dir( KIND ); returns the absolute path to
%     the intermediate directory `KIND`, using the root data directory
%     given by the saved config file.
%
%     p = ... intermediate_dir( ..., CONF ); uses the config file
%     `CONF` to generate the absolute path, instead of the saved config
%     file.

if ( nargin < 1 ), kind = ''; end
if ( nargin < 2 || isempty(conf) )
  conf = hww5.config.load();
end

p = shared_utils.io.fullfiles( hww5.dataroot(conf), 'intermediates', kind );

if ( ischar(kind) )
  p = char( p );
end

end