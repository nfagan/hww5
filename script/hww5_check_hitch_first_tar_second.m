function hww5_check_hitch_first_tar_second(labels, varargin)

[I, days] = findall( labels, {'day', 'task-id'}, varargin{:} );

for i = 1:numel(I)
  [date_I, dates] = findall( labels, 'date', I{i} );
  date_ts = datetime( dates );
  day = cellstr( datestr(date_ts, 'mmddyy') );
  assert( all(strcmp(day, days{1, i})) );
  
  assert( numel(dates) == 2, 'Expected 2 files; got %d', numel(dates) );
  
  [~, min_ind] = min( date_ts );
  [~, max_ind] = max( date_ts );
  
  first_monk = combs( labels, 'subject', date_I{min_ind} );
  sec_monk = combs( labels, 'subject', date_I{max_ind} );
  
  assert( all(strcmp(first_monk, 'hitch')) && all(strcmp(sec_monk, 'tar')) );
end

end