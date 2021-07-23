function p = plot_directory(conf, varargin)
p = fullfile( hww5.dataroot(conf), 'plots', dsp3.datedir, varargin{:} );
end