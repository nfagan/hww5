function I = find_within_sds(data, num_devs, I)

validateattributes( data, {'numeric'}, {'vector'}, mfilename, 'data' );
validateattributes( num_devs, {'numeric'}, {'scalar'}, mfilename, 'num_devs' );

if ( nargin < 3 )
  I = { rowmask(data) };
end

for i = 1:numel(I)
  d = data(I{i});
  
  mu = nanmean( d );
  sig = nanstd( d );
  
  lt = d < mu - sig * num_devs;
  gt = d > mu + sig * num_devs;
  
  oob = lt | gt;
  
  I{i}(oob) = [];
end

end