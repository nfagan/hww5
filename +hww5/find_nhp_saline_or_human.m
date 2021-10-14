function m = find_nhp_saline_or_human(l, m)

if ( nargin < 2 )
  m = rowmask( l );
end

monk_ind = find( l, {'saline', 'nhp'}, m );
human_ind = find( l, {'human'}, m );
m = union( monk_ind, human_ind );

end