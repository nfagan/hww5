function m = find_nhp(l, m)

if ( nargin < 2 )
  m = rowmask( l );
end

m = find( l, 'nhp', m );

end