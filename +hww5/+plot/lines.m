function lines(data, labels, varargin)

assert_ispair( data, labels );

defaults = struct();
defaults.gcats = {};
defaults.pcats = {};
defaults.fcats = {};
defaults.do_save = false;
defaults.config = hww5.config.load;
defaults.plot_subdir = '';

params = shared_utils.general.parsestruct( defaults, varargin );

gcats = params.gcats;
fcats = params.fcats;
pcats = csunion( params.pcats, fcats );

fig_I = findall_or_one( labels, fcats );
for i = 1:numel(fig_I)
  fig_ind = fig_I{i};
  d = data(fig_ind, :);
  l = prune( labels(fig_ind) );
  pl = plotlabeled.make_common();
  axs = pl.lines( d, l, gcats, pcats );
  
  if ( params.do_save )
    shared_utils.plot.fullscreen( gcf );
    save_p = hww5.plot_directory( params.config, params.plot_subdir );
    dsp3.req_savefig( gcf, save_p, l, unique([gcats, pcats, fcats]) );
  end
end

end