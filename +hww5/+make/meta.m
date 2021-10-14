function meta_file = meta(files, task_id)

un_kind = fullfile( 'unified', task_id );

hww5.validatefiles( files, un_kind );
unified_file = shared_utils.general.get( files, un_kind );

meta_file = struct();
meta_file.identifier = unified_file.identifier;
meta_file.task_id = unified_file.task_id;
meta_file.subject = get_subject( unified_file );

end

function subj = get_subject(unified_file)

date = hww5.labels.identifier_to_date( unified_file.identifier );
day = hww5.labels.day_from_date( date );

if ( ismember(unified_file.identifier, eb7_file_ids()) )
  % Fix mislabeled EB7 subject.
  subj = 'EB7';
  
elseif ( strcmp(day, '091619') )
  % fix mislabeled sept 16.
  subj = relabel_091619( unified_file );
else
  subj = unified_file.opts.META.subject;
end

end

function subj = relabel_091619(unified_file)

if ( unified_file.run_index == 1 )
  subj = 'hitch';
else
  subj = 'tar';
end

end

function ids = eb7_file_ids()

ids = [
  {'07-Jun-2021 12_46_50.mat'}
  {'07-Jun-2021 12_29_06.mat'}
  {'07-Jun-2021 12_51_55.mat'}
  {'07-Jun-2021 13_02_00.mat'}
  {'07-Jun-2021 12_41_42.mat'}
];

end