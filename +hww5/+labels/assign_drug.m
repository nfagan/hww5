function labels = assign_drug(labels, drugs_by_session, varargin)

addcat( labels, 'drug' );
[I, sessions] = findall( labels, 'day', varargin{:} );

for i = 1:numel(I)
  drug = drugs_by_session(sessions{i});
  setcat( labels, 'drug', drug, I{i} );
end

end