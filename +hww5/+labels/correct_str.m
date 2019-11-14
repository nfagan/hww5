function correct_strs = correct_str(was_correct)

correct_strs = arrayfun( @(x) sprintf('correct-%s', hww5.labels.tf_str(x)), was_correct, 'un', 0 );

end