-- <legal>
-- SCALe version r.6.7.0.0.A
-- 
-- Copyright 2021 Carnegie Mellon University.
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

CREATE TABLE IF NOT EXISTS LizardMetrics (
    name TEXT KEY,
    length INTEGER,
    sloc INTEGER,
    parent TEXT,
    file_methods INTEGER,
    cyc_comp INTEGER,
    avg_cyc_comp REAL,
    func_params INTEGER,
    avg_sloc_file REAL,
    avg_params REAL,
    avg_sloc_folder REAL,
    tokens INTEGER,
    avg_tokens REAL,
    start_line INTEGER,
    end_line INTEGER
);
CREATE INDEX Lizard_Parent ON LizardMetrics (parent);
