-- Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.
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
