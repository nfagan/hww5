function deg = run_px2deg(x, vres, monitor_constants)

if ( nargin < 3 || isempty(monitor_constants) )
  monitor_constants = hww5.monitor_constants();
end

if ( nargin < 2 )
  vres = monitor_constants.resolution_vertical;
end

h = monitor_constants.monitor_height_cm;
d = monitor_constants.z_dist_to_subject_cm;
deg = hwwa.px2deg( x, h, d, vres );

end