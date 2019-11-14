
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = hww5.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% DEPENDS
DEPENDS = struct();
DEPENDS.dependencies = { ...
    hww5.util.make_dependency('shared_utils', 'https://github.com/nfagan/shared_utils') ...
  , hww5.util.make_dependency('bfw', 'https://github.com/nfagan/bfw') ...
  , hww5.util.make_dependency('categorical', 'https://github.com/nfagan/categorical') ...
  , hww5.util.make_dependency('Edf2Mat', 'https://github.com/uzh/edf-converter') ...
};

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( hww5.util.get_project_folder() );
PATHS.data_root = fullfile( hww5.util.get_project_folder(), 'data' );

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;

if ( do_save )
  hww5.config.save( conf );
end

end