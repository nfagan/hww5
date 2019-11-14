function d = session_to_datestr(sesh)

if ( iscell(sesh) )
  d = cellfun( @convert, sesh, 'un', 0 );
else
  d = convert( sesh );
end

end

function d = convert(s)

d = datestr( datetime(s, 'inputformat', 'MMddyy') );

end