function pos = saccade_start_pos(sacc_info)
if ( isempty(sacc_info) )
  pos = zeros( 0, 2 );
else
  pos = sacc_info(:, 4:5);
end
end