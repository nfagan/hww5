function out = logical_map_rows_each(data, I, op)

out = false( rows(data), 1 );

for i = 1:numel(I)
  tf = op( rowref(data, I{i}) );
  validateattributes( tf, {'logical'}, {'column'}, mfilename, 'logical index' );
  out(I{i}) = tf;
end

end