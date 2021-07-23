function labels = add_task_order(labels, require5)

if ( nargin < 2 )
  require5 = true;
end

day_I = findall( labels, {'day', 'subject'} );

for i = 1:numel(day_I)
  [run_I, run_C] = findall( labels, {'run-id', 'task-id'}, day_I{i} );
  % expect 5 runs per day.
  if ( require5 )
    assert( numel(run_I) == 5, 'Expected 5 runs per day; got %d', numel(run_I) );
  end
  
  to_date = eachcell( @identifier_to_date, run_C(1, :) );
  date_nums = datenum( datestr(to_date) );
  [~, sort_ind] = sort( date_nums );
  
  run_I = run_I(sort_ind);
  run_C = run_C(:, sort_ind);
  task_order = strjoin( run_C(2, :), '->' );
  
  for j = 1:numel(run_I)
    addsetcat( labels, 'task-order', task_order, run_I{j} );
  end
end

prune( labels );

end

function date = identifier_to_date(id)

date = strrep( strrep(id, '_', ':'), '.mat', '' );

end