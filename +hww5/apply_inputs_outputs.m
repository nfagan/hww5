function apply_inputs_outputs(runner, input_dir, output_dir, subdirs, conf)

if ( nargin < 4 || isempty(conf) )
  conf = hww5.config.load();
end

subdirs = cellstr( subdirs );

runner.input_directories = fullfiles( input_dir, conf, subdirs );
runner.output_directory = char( fullfiles(output_dir, conf, subdirs) );

end

function p = fullfiles(dir, conf, subdirs)

p = shared_utils.io.fullfiles( hww5.intermediate_dir(dir, conf), subdirs{:} );

end