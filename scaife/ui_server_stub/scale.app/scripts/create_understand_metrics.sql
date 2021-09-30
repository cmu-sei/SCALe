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

CREATE TABLE IF NOT EXISTS UnderstandMetrics (
    Kind  BOOLEAN,
    Name  TEXT,
    File  TEXT,
    AltAvgLineBlank  INTEGER,
    AltAvgLineCode  INTEGER,
    AltAvgLineComment  INTEGER,
    AltCountLineBlank  INTEGER,
    AltCountLineCode  INTEGER,
    AltCountLineComment  INTEGER,
    AvgCyclomatic  INTEGER,
    AvgCyclomaticModified  INTEGER,
    AvgCyclomaticStrict  INTEGER,
    AvgEssential  INTEGER,
    AvgLine  INTEGER,
    AvgLineBlank  INTEGER,
    AvgLineCode  INTEGER,
    AvgLineComment  INTEGER,
    CountClassBase  INTEGER,
    CountClassCoupled  INTEGER,
    CountClassDerived  INTEGER,
    CountDeclClass  INTEGER,
    CountDeclClassMethod  INTEGER,
    CountDeclClassVariable  INTEGER,
    CountDeclFile  INTEGER,
    CountDeclFileCode  INTEGER,
    CountDeclFileHeader  INTEGER,
    CountDeclFunction  INTEGER,
    CountDeclInstanceMethod  INTEGER,
    CountDeclInstanceVariable  INTEGER,
    CountDeclInstanceVariablePrivate  INTEGER,
    CountDeclInstanceVariableProtected  INTEGER,
    CountDeclInstanceVariablePublic  INTEGER,
    CountDeclMethod  INTEGER,
    CountDeclMethodAll  INTEGER,
    CountDeclMethodConst  INTEGER,
    CountDeclMethodFriend  INTEGER,
    CountDeclMethodPrivate  INTEGER,
    CountDeclMethodProtected  INTEGER,
    CountDeclMethodPublic  INTEGER,
    CountInput  INTEGER,
    CountLine  INTEGER,
    CountLineBlank  INTEGER,
    CountLineCode  INTEGER,
    CountLineCodeDecl  INTEGER,
    CountLineCodeExe  INTEGER,
    CountLineComment  INTEGER,
    CountLineInactive  INTEGER,
    CountLinePreprocessor  INTEGER,
    CountOutput  INTEGER,
    CountPath  INTEGER,
    CountPathLog  INTEGER,
    CountSemicolon  INTEGER,
    CountStmt  INTEGER,
    CountStmtDecl  INTEGER,
    CountStmtEmpty  INTEGER,
    CountStmtExe  INTEGER,
    Cyclomatic  INTEGER,
    CyclomaticModified  INTEGER,
    CyclomaticStrict  INTEGER,
    Essential  INTEGER,
    Knots  INTEGER,
    MaxCyclomatic  INTEGER,
    MaxCyclomaticModified  INTEGER,
    MaxCyclomaticStrict  INTEGER,
    MaxEssential  INTEGER,
    MaxEssentialKnots  INTEGER,
    MaxInheritanceTree  INTEGER,
    MaxNesting  INTEGER,
    MinEssentialKnots  INTEGER,
    PercentLackOfCohesion  INTEGER,
    RatioCommentToCode  INTEGER,
    SumCyclomatic  INTEGER,
    SumCyclomaticModified  INTEGER,
    SumCyclomaticStrict  INTEGER,
    SumEssential  INTEGER
);
CREATE INDEX Understand_Names ON UnderstandMetrics (Name);
CREATE INDEX Understand_Files ON UnderstandMetrics (File);
