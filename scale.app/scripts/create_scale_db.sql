-- Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.
CREATE TABLE Messages ( id INTEGER PRIMARY KEY, diagnostic INTEGER, path TEXT, line INTEGER, message TEXT);
CREATE TABLE Diagnostics ( id INTEGER PRIMARY KEY, checker INTEGER, primary_msg INTEGER, confidence REAL, alert_priority INTEGER );
CREATE TABLE Checkers ( id INTEGER PRIMARY KEY, name TEXT, tool INTEGER, regex BOOLEAN );
CREATE TABLE CERTrules (taxonomy_id INTEGER, severity INTEGER, liklihood INTEGER, remediation INTEGER, priority INTEGER, level INTEGER, platform TEXT );
CREATE TABLE ExtraSourceContext( message INTEGER, func TEXT, class TEXT, namespace TEXT, lineend INTEGER, colstart INTEGER, colend INTEGER);
CREATE TABLE ExtraFeatures( message INTEGER, name TEXT, value TEXT );
CREATE TABLE CWEs (taxonomy_id INTEGER, cwe_platform TEXT, cwe_likelihood TEXT);
CREATE TABLE TaxonomyEntries (id INTEGER PRIMARY KEY, name TEXT, title TEXT);
CREATE TABLE TaxonomyCheckerLinks (taxonomy_id INTEGER, checker INTEGER);
CREATE TABLE MetaAlerts (id INTEGER PRIMARY KEY, flag BOOLEAN, verdict TINYINT, previous TINYINT, notes TEXT, ignored BOOLEAN, dead BOOLEAN, inapplicable_environment BOOLEAN, dangerous_construct INTEGER, taxonomy_id INTEGER);
CREATE TABLE DiagnosticMetaAlertLinks (diagnostic INTEGER KEY, meta_alert_id INTEGER KEY);
