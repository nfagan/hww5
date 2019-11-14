function out = select_efix_component(edf_file, fieldname, index)

out = edf_file.events.Efix.(fieldname)(index);

end