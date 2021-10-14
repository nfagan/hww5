function [data, labels] = preprocess_keep_first_n(data, labels, mask, each)

I = findall_or_one( labels, each, mask );
keep_ind = false( rows(data), 1 );
first_n = floor( mean(cellfun(@numel, I)) );

for i = 1:numel(I)
  keep_n = min( numel(I{i}), first_n );
  I{i} = I{i}(1:keep_n);
  keep_ind(I{i}) = true;
end

mask = find(keep_ind);
data = data(mask, :);
labels = prune( labels(mask) );

end