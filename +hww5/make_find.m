function f = make_find(selectors)
f = @(l, m) find(l, selectors, m);
end