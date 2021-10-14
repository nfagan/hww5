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
defaults.per_panel_labels = false;
defaults.points_color_map = get_points_color_map();

params = shared_utils.general.parsestruct( defaults, varargin );

fig_I = findall_or_one( labels, fcats );

for i = 1:numel(fig_I)
  pl = plotlabeled.make_common();
  pl.per_panel_labels = params.per_panel_labels;

  if ( ~isempty(params.points_are) )
    pl.points_are = params.points_are;
    pl.add_points = true;
    pl.marker_size = 4;
    pl.points_color_map = params.points_color_map;
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
    save_p = hww5.plot_directory( params.config, params.plot_subdir );
    dsp3.req_savefig( gcf, save_p, labs, unique([xcats, gcats, pcats, fcats]) );
  end
end

end

function cmap = get_points_color_map()
cmap = containers.Map();
cmap('cron') = [1, 0, 0];
cmap('hitch') = [0, 1, 0];
cmap('tar') = [0, 0, 1];
end