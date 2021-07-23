function labs = make_first_look_labels(fix_events, labels, mask, include_direction)

assert_ispair( fix_events, labels );

if ( nargin < 4 )
  include_direction = false;
end
if ( nargin < 3 )
  mask = rowmask( labels );
end

non_empties = cellfun( @(x) ~isempty(x), fix_events );
non_empty_inds = cellfun( @(x) min(x(:, 1)), fix_events(non_empties) );
ts = nan( size(fix_events) );
ts(non_empties) = non_empty_inds;

labs = cell( size(labels, 1), 1 );
labs(:) = { '<first-look>' };

for i = 1:numel(mask)
  m = mask(i);
  
  [~, ind] = min( ts(m, :) );
  has_look = true;
  
  if ( ind == 1 )
    l = sprintf( 'first-%s',  char(cellstr(labels, 'left-image-category', m)) );
  elseif ( ind == 2 )
    l = sprintf( 'first-%s',  char(cellstr(labels, 'right-image-category', m)) );
  else
    has_look = false;
  end
  
  if ( has_look )
    if ( ~include_direction )
      l = strrep( l, 'left-', '' );
      l = strrep( l, 'right-', '' );
    end
    
    labs{m} = l;
  end
end

end