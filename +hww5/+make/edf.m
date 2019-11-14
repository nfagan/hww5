function edf_file = edf(files, task_id, conf)

if ( nargin < 3 )
  conf = hww5.config.load();
end

unified_file = shared_utils.general.get( files, fullfile('unified', task_id) );
edf_filepath = fullfile( hww5.dataroot(conf), 'raw', unified_file.session_dir_components{:}, unified_file.edf_file );

if ( ~shared_utils.io.fexists(edf_filepath) )
  error( 'Edf file "%s" does not exist in "%s".', unified_file.edf_file, fileparts(edf_filepath) );
end

edf_obj = Edf2Mat( edf_filepath );

edf_file = struct();
edf_file.identifier = unified_file.identifier;
edf_file.samples = get_samples( edf_obj );
edf_file.events = get_events( edf_obj );

end

function s = copy_object(obj, fields)

s = struct();
for i = 1:numel(fields)
  s.(fields{i}) = obj.(fields{i});
end

end

function samples = get_samples(edf_obj)

copy_fields = { 'posX', 'posY', 'pupilSize', 'time' };
samples = copy_object( edf_obj.Samples, copy_fields );

end

function events = get_events(edf_obj)

copy_fields = { 'Messages', 'Sfix', 'Efix', 'Ssacc', 'Esacc', 'Sblink', 'Eblink' };
events = copy_object( edf_obj.Events, copy_fields );

end