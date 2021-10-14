function [norm_data, norm_labels] = normalize_to(data, labels, each, norm_cats, norm_labs, varargin)

assert_ispair( data, labels );

each_I = findall_or_one( labels, each, varargin{:} );

norm_labels = fcat();
norm_data = cell( numel(each_I), 1 );
norm_label = strjoin( cellstr(norm_labs), '_' );

clns = colons( ndims(data)-1 );

for i = 1:numel(each_I)
  target_mask = findnone( labels, norm_labs, each_I{i} );
  baseline_mask = find( labels, norm_labs, each_I{i} );
  
  sal_data = nanmean( data(baseline_mask, clns{:}), 1 );
  
  [drug_I, drug_labs] = findall( labels, norm_cats, target_mask );
  norm_dat = cell( numel(drug_I), 1 );
  
  for j = 1:numel(drug_I)
    drug_ind = drug_I{j};
    
    curr_rows = rows( norm_labels );
    label_assign_ind = (curr_rows + 1):(curr_rows + numel(drug_ind));
    normed_lab = sprintf( '%s/%s', strjoin(drug_labs(:, j), '_'), norm_label );
    normed_lab = repmat( {normed_lab}, numel(label_assign_ind), 1 );
    
    norm_dat{j} = data(drug_ind, clns{:}) ./ sal_data;    
    append( norm_labels, labels, drug_ind );
    setcat( norm_labels, norm_cats, normed_lab, label_assign_ind );
  end
  
  norm_data{i} = vertcat( norm_dat{:} );
end

norm_data = vertcat( norm_data{:} );

assert_ispair( norm_data, norm_labels );
prune( norm_labels );

end