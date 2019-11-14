function results = cat_results(results)

if ( isempty(results) )
  results = hww5.empty_results();
else
  results = vertcat( results{:} );
end

end