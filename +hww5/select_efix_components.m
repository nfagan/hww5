function out = select_efix_components(edf_file, fieldname, indices)

out = cellfun( @(x) hww5.select_efix_component(edf_file, fieldname, x), indices, 'un', 0 );

end