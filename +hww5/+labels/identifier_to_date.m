function date = identifier_to_date(ident)

date = strrep( ident, '.mat', '' );
date = strrep( date, '_', ':' );

end