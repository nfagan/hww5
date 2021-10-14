function m = find_non_outliers(l, m)

if ( nargin < 2 )
  m = rowmask( l );
end

m = find( l, 'outlier-false', m );

end