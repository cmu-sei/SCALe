-- Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Diagnostics, Checkers WHERE Diagnostics.id = Messages.diagnostic AND Diagnostics.checker = Checkers.name AND Checkers.rule = 'NONE' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Diagnostics, Checkers WHERE Diagnostics.id = Messages.diagnostic AND Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '%-CPP' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Diagnostics, Checkers WHERE Diagnostics.id = Messages.diagnostic AND Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___0_-C' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Diagnostics, Checkers WHERE Diagnostics.id = Messages.diagnostic AND Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___1_-C' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Diagnostics, Checkers WHERE Diagnostics.id = Messages.diagnostic AND Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___2_-C' );
DELETE FROM Diagnostics WHERE id IN (SELECT Diagnostics.id FROM Diagnostics, Checkers WHERE Diagnostics.checker = Checkers.name AND Checkers.rule = 'NONE' );
DELETE FROM Diagnostics WHERE id IN (SELECT Diagnostics.id FROM Diagnostics, Checkers WHERE Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '%-CPP' );
DELETE FROM Diagnostics WHERE id IN (SELECT Diagnostics.id FROM Diagnostics, Checkers WHERE Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___0_-C' );
DELETE FROM Diagnostics WHERE id IN (SELECT Diagnostics.id FROM Diagnostics, Checkers WHERE Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___1_-C' );
DELETE FROM Diagnostics WHERE id IN (SELECT Diagnostics.id FROM Diagnostics, Checkers WHERE Diagnostics.checker = Checkers.name AND Checkers.rule LIKE '___2_-C' );
