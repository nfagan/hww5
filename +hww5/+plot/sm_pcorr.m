function varargout = sm_pcorr(rt, labels, varargin)

[varargout{1:nargout}] = hww5.plot.ac_basic_bars( rt, labels ...
  , 'plot_subdir', 'basic_behavior/sm_pcorr' ...
  , varargin{:} ...
);

end