function sync_file = edf_sync(files, task_id)

unified_file = shared_utils.general.get( files, fullfile('unified', task_id) );
edf_file = shared_utils.general.get( files, fullfile('edf', task_id) );

mat_sync = unified_file.tracker_sync;
edf_sync = edf_file.events.Messages.time(strcmp(edf_file.events.Messages.info, 'RESYNCH'));

if ( numel(mat_sync.times) ~= numel(edf_sync) )
  error( 'Numbers of mat (%d) and edf (%d) sync times do not match.' ...
    , numel(mat_sync.times), numel(edf_sync) );
end

sync_file = struct();
sync_file.identifier = edf_file.identifier;
sync_file.mat = mat_sync.times(:);
sync_file.edf = edf_sync(:);

end