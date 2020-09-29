-- <legal>
-- SCALe version r.6.2.2.2.A
-- 
-- Copyright 2020 Carnegie Mellon University.
-- 
-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
-- INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
-- TRADEMARK, OR COPYRIGHT INFRINGEMENT.
-- 
-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or
-- contact permission@sei.cmu.edu for full terms.
-- 
-- [DISTRIBUTION STATEMENT A] This material has been approved for public
-- release and unlimited distribution.  Please see Copyright notice for
-- non-US Government use and distribution.
-- 
-- DM19-1274
-- </legal>

DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Alerts, Checkers WHERE Alerts.id = Messages.alert_id AND Alerts.checker_id = Checkers.name AND Checkers.rule = 'NONE' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Alerts, Checkers WHERE Alerts.id = Messages.alert_id AND Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '%-CPP' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Alerts, Checkers WHERE Alerts.id = Messages.alert_id AND Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___0_-C' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Alerts, Checkers WHERE Alerts.id = Messages.alert_id AND Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___1_-C' );
DELETE FROM Messages WHERE id IN (SELECT Messages.id FROM Messages, Alerts, Checkers WHERE Alerts.id = Messages.alert_id AND Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___2_-C' );
DELETE FROM Alerts WHERE id IN (SELECT Alerts.id FROM Alerts, Checkers WHERE Alerts.checker_id = Checkers.name AND Checkers.rule = 'NONE' );
DELETE FROM Alerts WHERE id IN (SELECT Alerts.id FROM Alerts, Checkers WHERE Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '%-CPP' );
DELETE FROM Alerts WHERE id IN (SELECT Alerts.id FROM Alerts, Checkers WHERE Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___0_-C' );
DELETE FROM Alerts WHERE id IN (SELECT Alerts.id FROM Alerts, Checkers WHERE Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___1_-C' );
DELETE FROM Alerts WHERE id IN (SELECT Alerts.id FROM Alerts, Checkers WHERE Alerts.checker_id = Checkers.name AND Checkers.rule LIKE '___2_-C' );