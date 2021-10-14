function tf = within_deviations(data, n_devs, dev_func, mu_func)

if ( nargin < 3 )
  dev_func = @(x) nanstd( x, [], 1 );
end
if ( nargin < 4 )
  mu_func = @(x) nanmean( x, 1 );
end

mu = mu_func( data );
dev = dev_func( data );
tf = (data < mu + dev * n_devs) & (data > mu - dev * n_devs);

end