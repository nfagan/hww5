function pos = saccade_stop_pos(sacc_info)
if ( isempty(sacc_info) )
  pos = zeros( 0, 2 );
else
  pos = sacc_info(:, 6:7);
end
end