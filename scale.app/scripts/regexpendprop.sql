-- Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.
.load /usr/lib/sqlite3/pcre.so
UPDATE Diagnostics SET checker = (SELECT name FROM Checkers, Messages WHERE Messages.id = Diagnostics.primary_msg AND Checkers.regex = 1 AND Messages.message REGEXP Checkers.name) WHERE Diagnostics.checker IS NULL;
