function p = plot_directory(conf, varargin)
if ( isempty(conf) )
  conf = hww5.config.load();
end
p = fullfile( hww5.dataroot(conf), 'plots', dsp3.datedir, varargin{:} );
end