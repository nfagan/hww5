function out_file = task_data(files, task_id)

un_kind = fullfile( 'unified', task_id );

hww5.validatefiles( files, un_kind );
unified_file = shared_utils.general.get( files, un_kind );

out_file = struct();
out_file.identifier = unified_file.identifier;
out_file.task_id = unified_file.task_id;
out_file.data = unified_file.DATA;

if ( strcmp(task_id, 'ba') )
  out_file.left_image_roi = unified_file.opts.STIMULI.ba_image1.vertices;
  out_file.right_image_roi = unified_file.opts.STIMULI.ba_image2.vertices;
end

end