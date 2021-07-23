function basic_bars(data, labels, xcats, gcats, pcats, fcats, varargin)

assert_ispair( data, labels );
validateattributes( data, {'double'}, {'column'}, mfilename, 'data' );

defaults = struct();
defaults.config = hww5.config.load();
defaults.do_save = false;
defaults.plot_subdir = 'basic_behavior';
defaults.points_are = {};
defaults.y_label = '';
defaults.y_lims = [];

params = shared_utils.general.parsestruct( defaults, varargin );

fig_I = findall_or_one( labels, fcats );

for i = 1:numel(fig_I)
  pl = plotlabeled.make_common();

  if ( ~isempty(params.points_are) )
    pl.points_are = params.points_are;
    pl.add_points = true;
  end

  dat = data(fig_I{i});
  labs = labels(fig_I{i});
  axs = pl.bar( dat, labs, xcats, gcats, csunion(pcats, fcats) );

  if ( ~isempty(params.y_label) && ~isempty(axs) )
    ylabel( axs(1), params.y_label );
  end
  
  if ( ~isempty(params.y_lims) )
    shared_utils.plot.set_ylims( axs, params.y_lims );
  end

  if ( params.do_save )
    shared_utils.plot.fullscreen( gcf );
    save_p = fullfile( hww5.dataroot(params.config), 'plots' ...
      , dsp3.datedir, params.plot_subdir );
    dsp3.req_savefig( gcf, save_p, labs, unique([xcats, gcats, pcats, fcats]) );
  end
end

end