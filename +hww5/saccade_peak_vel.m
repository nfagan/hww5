function pos = saccade_peak_vel(sacc_info)
if ( isempty(sacc_info) )
  pos = [];
else
  pos = sacc_info(:, 3);
end
end