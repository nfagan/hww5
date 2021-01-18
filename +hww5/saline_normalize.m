function [norm_data, norm_labels] = saline_normalize(data, labels, each, varargin)

assert_ispair( data, labels );

each_I = findall( labels, each, varargin{:} );

saline_lab = hww5.labels.saline();
drug_cat = hww5.labels.categories.drug();

norm_labels = fcat();
norm_data = cell( numel(each_I), 1 );

clns = colons( ndims(data)-1 );

for i = 1:numel(each_I)
  drug_mask = findnone( labels, saline_lab, each_I{i} );
  saline_ind = find( labels, saline_lab, each_I{i} );
  
  sal_data = nanmean( data(saline_ind, clns{:}), 1 );
  
  [drug_I, drug_labs] = findall( labels, drug_cat, drug_mask );
  norm_dat = cell( numel(drug_I), 1 );
  
  for j = 1:numel(drug_I)
    drug_ind = drug_I{j};
    
    curr_rows = rows( norm_labels );
    label_assign_ind = (curr_rows + 1):(curr_rows + numel(drug_ind));
    norm_lab = sprintf( '%s/%s', drug_labs{j}, saline_lab );
    
    norm_dat{j} = data(drug_ind, clns{:}) ./ sal_data;    
    append( norm_labels, labels, drug_ind );
    setcat( norm_labels, drug_cat, norm_lab, label_assign_ind );
  end
  
  norm_data{i} = vertcat( norm_dat{:} );
end

norm_data = vertcat( norm_data{:} );

assert_ispair( norm_data, norm_labels );
prune( norm_labels );

end