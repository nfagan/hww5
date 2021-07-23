function [all_data, all_inds, cat_labs] = collapse_left_right(data, labels, mask)

assert_ispair( data, labels );

if ( nargin < 3 )
  mask = rowmask( data );
end

[l_I, l_cats] = findall( labels, 'left-image-category', mask );
[r_I, r_cats] = findall( labels, 'right-image-category', mask );

l_cat_base = strrep( l_cats, 'left-', '' );
r_cat_base = strrep( r_cats, 'right-', '' );

all_cats = unique( [l_cat_base, r_cat_base] );

all_data = [];
all_inds = [];
cat_labs = {};

for i = 1:numel(all_cats)
  l_cat_ind = find( strcmp(l_cat_base, all_cats{i}) );
  r_cat_ind = find( strcmp(r_cat_base, all_cats{i}) );
  
  if ( ~isempty(l_cat_ind) )
    l_ind = l_I{l_cat_ind};
    all_data = [ all_data; data(l_ind, 1) ];
    all_inds = [ all_inds; l_ind ];
    cat_labs = [ cat_labs; repmat(all_cats(i), numel(l_ind), 1) ];
  end
  if ( ~isempty(r_cat_ind) )
    r_ind = r_I{r_cat_ind};
    all_data = [ all_data; data(r_ind, 2) ];
    all_inds = [ all_inds; r_ind ];
    cat_labs = [ cat_labs; repmat(all_cats(i), numel(r_ind), 1) ];
  end
end

end