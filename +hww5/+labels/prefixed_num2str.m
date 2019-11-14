function strs = prefixed_num2str(delays, prefix)

strs = arrayfun( @(x) sprintf('%s%0.2f', prefix, x), delays, 'un', 0 );

end