function defaults = plot_defaults(assign_to)

if ( nargin == 0 )
  defaults = struct();
else
  defaults = assign_to;
end

defaults.base_subdir = '';
defaults.prefix = '';

end