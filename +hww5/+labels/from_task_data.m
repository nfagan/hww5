function labs = from_task_data(task_data_file)

switch ( task_data_file.task_id )
  case 'ac'
    labs = hww5.labels.from_ac_task_data( task_data_file );
  case 'ba'
    labs = hww5.labels.from_ba_task_data( task_data_file );
  case 'gf'
    labs = hww5.labels.from_gf_task_data( task_data_file );
  case 'ja'
    labs = hww5.labels.from_ja_task_data( task_data_file );
  case 'sm'
    labs = hww5.labels.from_sm_task_data( task_data_file );
  otherwise
    error( 'Unrecognized task id "%s".', task_data_file.task_id );
end

apply_common( labs, task_data_file );
prune( labs );

end

function apply_common(labs, trial_file)

if ( ~isempty(labs) )
  identifier = trial_file.identifier;
  date = hww5.labels.identifier_to_date( identifier );
  
  addsetcat( labs, 'task-id', trial_file.task_id );
  addsetcat( labs, 'run-id', identifier );
  addsetcat( labs, 'date', date );
  addsetcat( labs, 'day', hww5.labels.day_from_date(date) );
end

end