function out = mat2edf_time(mat_events, sync_file, do_round)

if ( nargin < 3 )
  do_round = true;
end

out = shared_utils.sync.cinterp( mat_events, sync_file.mat, sync_file.edf );

if ( do_round )
  out = round( out );
end

end