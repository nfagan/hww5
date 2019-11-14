function matches_trial = is_fix_event_within_interval(edf_file, start_ts, stop_ts)

fix_starts = edf_file.events.Efix.start;
fix_stops = edf_file.events.Efix.end;

matches_trial = arrayfun( @(x, y) fix_starts >= x & fix_stops <= y, start_ts, stop_ts, 'un', 0 );

end