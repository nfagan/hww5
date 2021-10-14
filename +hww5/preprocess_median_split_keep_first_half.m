function [data, labels] = preprocess_median_split_keep_first_half(data, labels, mask, each)

I = findall_or_one( labels, each, mask );
keep_ind = false( rows(data), 1 );

for i = 1:numel(I)
  d = data(I{i}, :);
  m = nanmedian( d );
  first_quant = d < m;
  keep_ind(I{i}(first_quant)) = true;
end

mask = find(keep_ind);
data = data(mask, :);
labels = prune( labels(mask) );

end