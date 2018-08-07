#!/usr/bin/env python
# Copyright (c) 2007-2015 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.

import sqlite3
import argparse
import os
import re
import hashlib
import subprocess
import sys
import random

# Gets salt value from salt.txt or creates salt.txt with salt
def getSalt():
    salt = None
    if os.path.isfile('salt.txt') is True and os.stat('salt.txt').st_size != 0:
        salt = returnSalt()
    else:
        try:
            subprocess.check_call("head /dev/urandom -c 16 | base64 > salt.txt", shell=True)
        except:
            print 'Unable to create salt!'
            sys.exit(1)

        salt = returnSalt()

    return salt

# Opens salt.txt and returns the salt value
def returnSalt():
    salt = None

    with open('salt.txt', 'r+') as saltFile:
        salt = saltFile.readline()
    saltFile.close()

    salt = salt.replace("\n", "")
    salt = salt.replace("\r", "")
 
    return salt

# Converts path to unix
def win2unix(path):
    path = re.sub( r"\w:", "", path)
    path = re.sub( r"\\\\", "/", path)
    path = re.sub( r"\\", "/", path)
    path = path.lower()

    return path
   
# Sanitizes a path and returns the new hashed path
def sanitizePath(currPath, salt):
    newPath = None
    hashList = []

    if currPath is not None:
        currPath = win2unix(currPath)
        if currPath.startswith('/'):
            currPath = currPath[1:len(currPath)]
        pathList = currPath.split('/')
        for string in pathList:
            hashString = hashlib.sha256()
            hashString.update(string + salt)
            hashList.append('/' + hashString.hexdigest())
        newPath = ''.join(hashList)

    return newPath

# Sanitizes a single field and returns that hashed field
def sanitize(entry, salt):
    newEntry = None
    hashString = hashlib.sha256()
    #print(entry, salt)
    hashString.update(entry + salt)
    newEntry = hashString.hexdigest()

    return newEntry

def openCopyDb(newDbPath, createNew):
    # Create new DB with salt/hashed path values
    if os.path.exists(newDbPath):
        if createNew is False:
            try:
                print "WARNING: Copied database of same name has already been created!"
                print "Dropping current tables and creating new tables in database copy..."
                print ""
                newConn = sqlite3.connect(newDbPath)
                newDbCursor = newConn.cursor()
                tableCursor = newConn.cursor()

                newDbCursor.execute("SELECT name from sqlite_master WHERE type='table'")
                for tableName in newDbCursor.fetchall():
                    execDropTable = 'DROP TABLE ' + tableName[0]
                    tableCursor.execute(execDropTable)

                newConn.commit()
                newConn.close()

                subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)  
           
            except:
                print "Unable to create database with added salt and sanitized path!"
                return

        # Occurs if -n argument given
        else:
            print "WARNING: Copied database of same name has already been created!"

            newDbPath = newDbPath.split('/')
            strList = newDbPath[len(newDbPath) - 1].split('.')
            strList[0] = strList[0] + '_' + str(random.randint(0, 10000000))
            newDbPath[len(newDbPath) - 1] = '.'.join(strList)
            newDbPath = '/'.join(newDbPath)

            print "New database " + newDbPath + " will be created..."
            print ""

            try:
                subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)
                print "Creating database with added salt and sanitized path..."

            except:
                print "Unable to create database with added salt and sanitized path!"
                return

    else:
        subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)
        print "Creating database with added salt and sanitized path..."

    return newDbPath

def openSanitDb(newDbPath, createNew):
    # Create new sanitized DB
    if os.path.exists(newDbPath):
        if createNew is False:
            try:
                print "WARNING: Sanitized database of same name has already been created!"
                print "Dropping current tables and creating new tables in sanitized database..."
                print ""

                newConn = sqlite3.connect(newDbPath)
                newDbCursor = newConn.cursor()
                tableCursor = newConn.cursor()

                newDbCursor.execute("SELECT name from sqlite_master WHERE type='table'")
                for tableName in newDbCursor.fetchall():
                    execDropTable = 'DROP TABLE ' + tableName[0]
                    tableCursor.execute(execDropTable)

                newConn.commit()
                newConn.close()    

                subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)  
           
            except:
                print "Unable to create sanitized database!"
                return

        # Occurs if -n argument given
        else:
            print "WARNING: Sanitized database of same name has already been created!"
            newDbPath = newDbPath.split('/')
            strList = newDbPath[len(newDbPath) - 1].split('.')
            strList[0] = strList[0] + '_' + str(random.randint(0, 10000000))
            newDbPath[len(newDbPath) - 1] = '.'.join(strList)
            newDbPath = '/'.join(newDbPath)

            print "New database " + newDbPath + " will be created..."
            print ""

            try:
                subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)
                print "Creating sanitized database..."

            except:
                print "Unable to create sanitized database!"
                return

    else:
        subprocess.check_call("sqlite3 " + newDbPath + " < create_scale_db.sql", shell=True)
        print "Creating sanitized database..."

    return newDbPath

# Creates a sanitized DB 
def createSanitDb(oldDbPath, createNew, salt):
    oldConn = sqlite3.connect(oldDbPath)

    oldDbCursor = oldConn.cursor()
    newDbPath = oldDbPath.split('/')
    
    # Get original DB name and hash
    strList = newDbPath[len(newDbPath) - 1].split('.')
    hashString = hashlib.sha256()
    hashString.update(strList[0] + salt)
    strList[0] = hashString.hexdigest()
    newDbPath[len(newDbPath) - 1] = '.'.join(strList)
    newDbPath = '/'.join(newDbPath)

    newDbPath = openSanitDb(newDbPath, createNew)

    # Dump information from original DB into new DB
    subprocess.check_call("python ./org2dbdump.py < tools.org | sqlite3 " + newDbPath, shell=True)

    # Set up strings
    execStrAttach = "ATTACH DATABASE '" + newDbPath + "' as sanitizedDb"
    execStrGetMsgs = 'SELECT id, diagnostic, path, line from main.Messages'
    
    newEntry = oldConn.cursor()
    oldDbCursor.execute(execStrAttach)
    oldDbCursor.execute(execStrGetMsgs)

    for entry in oldDbCursor.fetchall():
        entryList = list(entry)
        entryList[2] = sanitizePath(entryList[2], salt)
        entryTuple = tuple(entryList)
        newEntry.execute('INSERT INTO sanitizedDb.Messages(id, diagnostic, path, line) VALUES (?, ?, ?, ?)', entryTuple)

    oldDbCursor.execute('INSERT INTO sanitizedDb.Diagnostics SELECT * FROM main.Diagnostics')
    oldDbCursor.execute('INSERT INTO sanitizedDb.Checkers SELECT * FROM main.Checkers')
    oldDbCursor.execute('INSERT INTO sanitizedDb.CERTRules SELECT * FROM main.CERTRules')
    oldDbCursor.execute('INSERT INTO sanitizedDb.CWEs SELECT * FROM main.CWEs')
    oldDbCursor.execute('INSERT INTO sanitizedDb.DiagnosticMetaAlertLinks SELECT * FROM main.DiagnosticMetaAlertLinks')
    oldDbCursor.execute('INSERT INTO sanitizedDb.TaxonomyCheckerLinks SELECT * FROM main.TaxonomyCheckerLinks')
    oldDbCursor.execute('INSERT INTO sanitizedDb.TaxonomyEntries SELECT * FROM main.TaxonomyEntries')
    
    # Sanitize ExtraSourceContext if table exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ExtraSourceContext'")
    if len(oldDbCursor.fetchall()) == 1:
        oldDbCursor.execute('SELECT * from main.ExtraSourceContext')
        for entry in oldDbCursor.fetchall():
            entryList = list(entry)
        
            if entryList[1] != unicode('None'):
                entryList[1] = sanitize(entryList[1], salt)
            if entryList[2] != unicode('None'):
                entryList[2] = sanitize(entryList[2], salt)
            if entryList[3] != unicode('None'):
                entryList[3] = sanitize(entryList[3], salt)
            entryTuple = tuple(entryList)
        
            newEntry.execute(createInsert(7, 'ExtraSourceContext'), entryTuple)

    # Add ExtraFeatures if table exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ExtraFeatures'")
    if len(oldDbCursor.fetchall()) == 1:
        oldDbCursor.execute('INSERT INTO sanitizedDb.ExtraFeatures SELECT * from main.ExtraFeatures')
   
    # Sanitize and add LizardMetrics table if it exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='LizardMetrics'")
    if len(oldDbCursor.fetchall()) == 1:
        oldDbCursor.execute('CREATE TABLE sanitizedDb.LizardMetrics (name TEXT KEY, length INTEGER, sloc INTEGER, parent TEXT, file_methods INTEGER, cyc_comp INTEGER, avg_cyc_comp REAL, func_params INTEGER, avg_sloc_file REAL, avg_params REAL, avg_sloc_folder REAL, tokens INTEGER, avg_tokens REAL, start_line INTEGER, end_line INTEGER)')
        oldDbCursor.execute('SELECT * from main.LizardMetrics')
        for entry in oldDbCursor.fetchall():
            entryList = list(entry)
            if entryList[3] is not None:
                entryList[0] = sanitize(entryList[0], salt)
            else:
                entryList[0] = sanitizePath(entryList[0], salt)
            if entryList[3] is not None:
                entryList[3] = sanitizePath(entryList[3], salt)
            entryTuple = tuple(entryList)
                        
            newEntry.execute('INSERT INTO sanitizedDb.LizardMetrics VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', entryTuple)
   
    # Sanitize and add MetaAlerts table if it exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='MetaAlerts'")
    if len(oldDbCursor.fetchall())==1:        
       #oldDbCursor.execute('INSERT INTO sanitizedDb.MetaAlerts SELECT * from main.MetaAlerts')
       oldDbCursor.execute('SELECT * FROM main.MetaAlerts')
       for entry in oldDbCursor.fetchall():
           entryList = list(entry)
	   if entryList[4] is not None:
               entryList[4] = sanitize(entryList[4], salt)
           entryTuple = tuple(entryList)
	        
           newEntry.execute('INSERT INTO sanitizedDb.MetaAlerts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', entryTuple)
    
    # Sanitize and add CcsmMetrics table if it exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='CcsmMetrics'")
    if len(oldDbCursor.fetchall())==1:
        oldDbCursor.execute('CREATE TABLE sanitizedDb.CcsmMetrics(File TEXT KEY, Func TEXT, FileCnt INTEGER, FileSize INTEGER, FuncCnt INTEGER, KwIfCnt INTEGER, RawKwIfCnt INTEGER, KwElseCnt INTEGER, RawKwElseCnahhhht INTEGER, KwForCnt INTEGER, RawKwForCnt INTEGER, KwReturnCnt INTEGER, RawKwReturnCnt INTEGER, KwDoCnt INTEGER, RawKwDoCnt INTEGER, KwWhileCnt INTEGER, RawKwWhileCnt INTEGER, KwSwitchCnt INTEGER, RawKwSwitchCnt INTEGER, KwCaseCnt INTEGER, RawKwCaseCnt INTEGER, KwBreakCnt INTEGER, RawKwBreakCnt INTEGER, KwDefaultCnt INTEGER, RawKwDefaultCnt INTEGER, KwGotoCnt INTEGER, RawKwGotoCnt INTEGER, KwAutoCnt INTEGER, RawKwAutoCnt INTEGER, KwVolatileCnt INTEGER, KwCumVolatileCnt INTEGER, RawKwVolatileCnt INTEGER, RawKwCumVolatileCnt INTEGER, KwConstCnt INTEGER, KwCumConstCnt INTEGER, RawKwConstCnt INTEGER, RawKwCumConstCntRaw INTEGER, KwBodyConstCnt INTEGER, RawKwBodyConstCnt INTEGER, KwTypedefCnt INTEGER, KwCumTypedefCnt INTEGER, RawKwTypedefCnt INTEGER, RawKwCumTypedefCnt INTEGER, KwContinueCnt INTEGER, RawKwContinueCnt INTEGER, KwUnionCnt INTEGER, KwCumUnionCnt INTEGER, KwBodyUnionCnt INTEGER, RawKwUnionCnt INTEGER, RawKwCumUnionCnt INTEGER, RawKwBodyUnionCnt INTEGER, KwStructCnt INTEGER, KwCumStructCnt INTEGER, KwBodyStructCnt INTEGER, RawKwStructCnt INTEGER, RawKwCumStructCnt INTEGER, RawKwBodyStructCnt INTEGER, KwEnumCnt INTEGER, KwCumEnumCnt INTEGER, KwBodyEnumCnt INTEGER, RawKwEnumCnt INTEGER, RawKwCumEnumCnt INTEGER, RawKwBodyEnumCnt INTEGER, KwCharCnt INTEGER, KwCumCharCnt INTEGER, KwBodyCharCnt INTEGER, RawKwCharCnt INTEGER, RawKwCumCharCnt INTEGER, RawKwBodyCharCnt INTEGER, KwUnsignedCnt INTEGER, KwCumUnsignedCnt INTEGER, KwBodyUnsignedCnt INTEGER, RawKwUnsignedCnt INTEGER, RawKwCumUnsignedCnt INTEGER, RawKwBodyUnsignedCnt INTEGER, KwSignedCnt INTEGER, KwCumSignedCnt INTEGER, KwBodySignedCnt INTEGER, RawKwSignedCnt INTEGER, RawKwCumSignedCnt INTEGER, RawKwBodySignedCnt INTEGER, KwDoubleCnt INTEGER, KwCumDoubleCnt INTEGER, KwBodyDoubleCnt INTEGER, RawKwDoubleCnt INTEGER, RawKwCumDoubleCnt INTEGER, RawKwBodyDoubleCnt INTEGER, KwFloatCnt INTEGER, KwCumFloatCnt INTEGER, KwBodyFloatCnt INTEGER, RawKwFloatCnt INTEGER, RawKwCumFloatCnt INTEGER, RawKwBodyFloatCnt INTEGER, KwIntCnt INTEGER, KwCumIntCnt INTEGER, KwBodyIntCnt INTEGER, RawKwIntCnt INTEGER, RawKwCumIntCnt INTEGER, RawKwBodyIntCnt INTEGER, KwLongCnt INTEGER, KwCumLongCnt INTEGER, KwBodyLongCnt INTEGER, RawKwLongCnt INTEGER, RawKwCumLongCnt INTEGER,'
+ ' RawKwBodyLongCnt INTEGER, KwShortCnt INTEGER, KwCumShortCnt INTEGER, KwBodyShortCnt INTEGER, RawKwShortCnt INTEGER, RawKwCumShortCnt INTEGER, RawKwBodyShortCnt INTEGER, KwStaticCnt INTEGER, KwCumStaticCnt INTEGER, KwBodyStaticCnt INTEGER, RawKwStaticCnt INTEGER, RawKwCumStaticCnt INTEGER, RawKwBodyStaticCnt INTEGER, KwExternCnt INTEGER, KwCumExternCnt INTEGER, RawKwExternCnt INTEGER, RawKwCumExternCnt INTEGER, KwRegisterCnt INTEGER, KwCumRegisterCnt INTEGER, RawKwRegisterCnt INTEGER, RawKwCumRegisterCnt INTEGER, KwVoidCnt INTEGER, KwCumVoidCnt INTEGER, KwBodyVoidCnt INTEGER, RawKwVoidCnt INTEGER, RawKwCumVoidCnt INTEGER, RawKwBodyVoidCnt INTEGER, KwSizeofCnt INTEGER, KwCumSizeofCnt INTEGER, RawKwSizeofCnt INTEGER, RawKwCumSizeofCnt INTEGER, KwCnt INTEGER, KwCumCnt INTEGER, KwTypesCnt INTEGER, KwCumTypesCnt INTEGER, IdentLabelCnt INTEGER, RawIdentLabelCnt INTEGER, NumericConstCnt INTEGER, NumericConstCntCum INTEGER, NumericConstUniq INTEGER, NumericConstUniqCum INTEGER, RawNumericConstCnt INTEGER, RawNumericConstCntCum INTEGER, RawNumericConstUniq INTEGER, RawNumericConstUniqCum INTEGER, StringLiterals INTEGER, StringLiteralsCum INTEGER, StringLiteralsUniq INTEGER, StringLiteralsUniqCum INTEGER, RawStringLiterals INTEGER, RawStringLiteralsCum INTEGER, RawStringLiteralsUniq INTEGER, RawStringLiteralsUniqCum INTEGER, CharConsts INTEGER, CharConstsUniq INTEGER, RawCharConsts INTEGER, RawCharConstsUniq INTEGER, UnreservedIdentifiers INTEGER, UnreservedIdentifiersUniq INTEGER, BodyUnreservedIdentifiers INTEGER, BodyUnreservedIdentifiersUniq INTEGER, RawUnreservedIdentifiers INTEGER, RawUnreservedIdentifiersUniq INTEGER, VarFileLocCnt INTEGER, VarFileLocStaticCnt INTEGER, VarFileExtCnt INTEGER, VarFileVolatileCnt INTEGER, VarFileConstCnt INTEGER, VarFnLocCnt INTEGER, VarFnLocStaticCnt INTEGER, VarFnLocConstCnt INTEGER, VarFnLocVolatileCnt INTEGER, VarFnLocRegCnt INTEGER, VarFnLocAutoCnt INTEGER, VarFnExtCnt INTEGER, ReturnPointCnt INTEGER, StmtCnt INTEGER, StmtCumCnt INTEGER, RawStmtCnt INTEGER, RawStmtCumCnt INTEGER, CommentHisComf Float, CommentByteCnt INTEGER, CommentCnt INTEGER, Mccabe INTEGER, MccabeMod INTEGER, RawMccabe INTEGER, RawMccabeMod INTEGER, FuncLocalCnt INTEGER, FuncExternExplCnt INTEGER, FuncExternExplCumCnt INTEGER, FuncExternImplCnt INTEGER, FuncExternImplCumCnt INTEGER, FuncInlineCnt INTEGER, FuncCalledByLocal INTEGER, FuncCalledByExtern INTEGER, OpFnCallCnt INTEGER, FuncPaths INTEGER, OpFnCallUniqueCnt INTEGER, LocalFnCallCnt INTEGER,'
+' FileLineCnt INTEGER, FuncDefinitionLineCnt INTEGER, FuncBodyLineCnt INTEGER, StmtHisParam INTEGER, DecisionsTodo INTEGER, LoopsTodo INTEGER, FuncNesting INTEGER, HisVocf Float, OpAssignCnt INTEGER, OpAddCnt INTEGER, OpAddAssignCnt INTEGER, OpSubCnt INTEGER, OpSubAssignCnt INTEGER, OpUnaryPlusCnt INTEGER, OpUnaryMinusCnt INTEGER,  OpMultCnt INTEGER, OpMultAssignCnt INTEGER, OpDivCnt INTEGER, OpDivAssignCnt INTEGER, OpModCnt INTEGER, OpModAssignCnt INTEGER, OpIncPreCnt INTEGER, OpIncPostCnt INTEGER, OpDecPreCnt INTEGER, OpDecPostCnt INTEGER, OpShftLeftCnt INTEGER, OpShftLeftAssignCnt INTEGER, OpShftRghtCnt INTEGER, OpShftRghtAssignCnt INTEGER, OpCmpLtCnt INTEGER, OpCmpGtCnt INTEGER, OpCmpLtEqCnt INTEGER, OpCmpGtEqCnt INTEGER, OpCmpEqCnt INTEGER, OpCmpNeqCnt INTEGER, OpCommaCnt INTEGER, OpTernaryCnt INTEGER, OpLogAndCnt INTEGER, OpLogOrCnt INTEGER, OpLogNitCnt INTEGER, OpBitwiseAndCnt INTEGER, OpBitwiseAndAssignCnt INTEGER, OpBitwiseOrCnt INTEGER, OpBitwiseOrAssignCnt INTEGER, OpBitwiseXorCnt INTEGER, OpBitwiseXorAssignCnt INTEGER, OpBitwiseNotCnt INTEGER, OpPtrToMemberDirectCnt INTEGER, OpPtrToMemberIndirectCnt INTEGER, OpAddrOfCnt INTEGER, OpDerefCnt INTEGER, OpArraySubscriptCnt INTEGER, OpMemberAccessDirectCnt INTEGER, OpMemberAccessPointerCnt INTEGER, OpAlignofCnt INTEGER, OpCastCnt INTEGER, OpTypesCnt INTEGER, OpTypesCntCum INTEGER, OpCnt INTEGER,  OpCntCum INTEGER, HalsteadOperatorUniqueCnt INTEGER, HalsteadOperatorCnt INTEGER, HalsteadOperandUniqueCnt INTEGER, HalsteadOperandCnt INTEGER, HalsteadVocabulary INTEGER, HalsteadLength INTEGER, HalsteadCalcLength REAL, HalsteadVolume REAL, HalsteadDifficulty REAL, TokBool INTEGER, TokInline INTEGER, TokVirtual INTEGER, TokMutable INTEGER, TokFriend INTEGER, TokAsm INTEGER, TokClass INTEGER, TokDelete INTEGER, TokNew INTEGER, TokOperator INTEGER, TokPrivate INTEGER, TokProtected INTEGER, TokPublic INTEGER, TokThis INTEGER, TokNamespace INTEGER, TokUsing INTEGER, TokTry INTEGER, TokCatch INTEGER, TokThrow INTEGER, TokTypeid INTEGER, TokTemplate INTEGER, TokExplicit INTEGER, TokTrue INTEGER, TokFalse INTEGER, TokTypename INTEGER, TokNot INTEGER, TokNotEqual INTEGER, TokModulo INTEGER, TokModuloAssign INTEGER, TokAmp INTEGER, TokAmpamp INTEGER, TokPipepipe INTEGER, TokAndAssign INTEGER, TokLparen INTEGER, TokRparen INTEGER, TokAsterisk INTEGER, TokAsteriskAssign INTEGER, TokPlus INTEGER, TokPlusplus INTEGER, TokPlusAssign INTEGER, TokComma INTEGER,'
+ ' TokMinus INTEGER, TokMinusminus INTEGER, TokMinusAssign INTEGER, TokMemberPtr INTEGER, TokMemberRef INTEGER, TokEllipsis INTEGER, TokSlash INTEGER, TokSlashAssign INTEGER,    TokColon INTEGER, TokColoncolon INTEGER, TokLess INTEGER, TokLessless INTEGER, TokLesslessAssign INTEGER, TokLessEqual INTEGER, TokAssign INTEGER, TokComparison INTEGER, TokMore INTEGER, TokMoremore INTEGER, TokMoremoreAssign INTEGER, TokMoreEqual INTEGER, TokLsquare INTEGER, TokRsquare INTEGER, TokLbrace INTEGER, TokRbrace INTEGER, TokQuestion INTEGER, TokCaret INTEGER, TokCaretAssign INTEGER, TokPipe INTEGER, TokPipeAssign INTEGER, TokTilde INTEGER, HisCalling INTEGER )')
	oldDbCursor.execute('SELECT * FROM main.CcsmMetrics')
	for entry in oldDbCursor.fetchall():
	    entryList = list(entry)
	    if entryList[0] is not None:
		entryList[0] = sanitize(entryList[0], salt)
	    if entryList[1] is not None:
		entryList[1] = sanitize(entryList[1], salt)	
	    entryTuple = tuple(entryList)
            
            newEntry.execute(createInsert(344, 'CcsmMetrics'), entryTuple)

   # Sanitize and add UnderstandMetrics table if it exists
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='UnderstandMetrics'")
    if len(oldDbCursor.fetchall())==1:
	oldDbCursor.execute('CREATE TABLE sanitizedDb.UnderstandMetrics (Kind  BOOLEAN,Name  TEXT KEY,File  TEXT,AltAvgLineBlank  INTEGER,AltAvgLineCode  INTEGER,AltAvgLineComment  INTEGER,AltCountLineBlank  INTEGER,AltCountLineCode  INTEGER, AltCountLineComment  INTEGER, AvgCyclomatic  INTEGER, AvgCyclomaticModified  INTEGER,AvgCyclomaticStrict  INTEGER, AvgEssential  INTEGER, AvgLine  INTEGER, AvgLineBlank  INTEGER, AvgLineCode  INTEGER,'+' AvgLineComment  INTEGER, CountClassBase  INTEGER, CountClassCoupled  INTEGER, CountClassDerived  INTEGER, CountDeclClass  INTEGER, CountDeclClassMethod  INTEGER,CountDeclClassVariable  INTEGER, CountDeclFile  INTEGER,CountDeclFileCode  INTEGER, CountDeclFileHeader  INTEGER, CountDeclFunction  INTEGER, CountDeclInstanceMethod  INTEGER, CountDeclInstanceVariable  INTEGER, CountDeclInstanceVariablePrivate  INTEGER, CountDeclInstanceVariableProtected  INTEGER, CountDeclInstanceVariablePublic  INTEGER,   CountDeclMethod  INTEGER, CountDeclMethodAll  INTEGER, CountDeclMethodConst  INTEGER, CountDeclMethodFriend  INTEGER, CountDeclMethodPrivate  INTEGER,  CountDeclMethodProtected  INTEGER, CountDeclMethodPublic  INTEGER,  CountInput  INTEGER,  CountLine  INTEGER, CountLineBlank  INTEGER, CountLineCode  INTEGER, CountLineCodeDecl  INTEGER, CountLineCodeExe  INTEGER, CountLineComment  INTEGER, CountLineInactive  INTEGER, CountLinePreprocessor  INTEGER, CountOutput  INTEGER, CountPath  INTEGER, CountPathLog  INTEGER, CountSemicolon  INTEGER, CountStmt  INTEGER, CountStmtDecl  INTEGER, CountStmtEmpty  INTEGER, CountStmtExe  INTEGER,  Cyclomatic  INTEGER, CyclomaticModified  INTEGER, CyclomaticStrict  INTEGER, Essential  INTEGER, Knots  INTEGER, MaxCyclomatic  INTEGER, MaxCyclomaticModified  INTEGER, MaxCyclomaticStrict  INTEGER, MaxEssential  INTEGER, MaxEssentialKnots  INTEGER, MaxInheritanceTree  INTEGER, MaxNesting  INTEGER, MinEssentialKnots  INTEGER, PercentLackOfCohesion  INTEGER,  RatioCommentToCode  INTEGER, SumCyclomatic  INTEGER, SumCyclomaticModified  INTEGER, SumCyclomaticStrict  INTEGER, SumEssential  INTEGER )')
    	oldDbCursor.execute('SELECT * FROM main.UnderstandMetrics') 
	for entry in oldDbCursor.fetchall():
	    entryList = list(entry)
	    if entryList[1] is not None:
		entryList[1] = sanitize(entryList[1], salt)
	    if entryList[2] is not None:
		entryList[2] = sanitizePath(entryList[2], salt)
	    entryTuple = tuple(entryList)

	    newEntry.execute(createInsert(75, 'UnderstandMetrics') , entryTuple)

    oldConn.commit()
    oldConn.close()
    print "Sanitized database created!"

def createInsert(count, tableNameString):
    queryString = 'INSERT INTO sanitizedDb.'+tableNameString+' VALUES ('
    valString = ''
    for cols in range(0, count):
        if cols==(count-1):
            valString+="?"
        else:
            valString += "?,"
    final = queryString + valString + ')'
    return final
    
def copyCurrDb(oldDbPath, createNew):
    oldConn = sqlite3.connect(oldDbPath)

    oldDbCursor = oldConn.cursor()
    newDbPath = oldDbPath.split('/')
    
    # Get new name for copied db
    strList = newDbPath[len(newDbPath) - 1].split('.')
    strList[0] = strList[0] + '_with_salt'
    newDbPath[len(newDbPath) - 1] = '.'.join(strList)
    newDbPath = '/'.join(newDbPath)

    newDbPath = openCopyDb(newDbPath, createNew)

    # Dump information from original DB into new DB
    subprocess.check_call("python ./org2dbdump.py < tools.org | sqlite3 " + newDbPath, shell=True)

    # Set up strings
    execStrAttach = "ATTACH DATABASE '" + newDbPath + "' as copyDb"

    oldDbCursor.execute(execStrAttach)
    oldDbCursor.execute('INSERT INTO copyDb.Messages SELECT * FROM main.Messages')
    oldDbCursor.execute('INSERT INTO copyDb.Diagnostics SELECT * FROM main.Diagnostics')
    oldDbCursor.execute('INSERT INTO copyDb.Checkers SELECT * FROM main.Checkers')
    oldDbCursor.execute('INSERT INTO copyDb.CERTRules SELECT * FROM main.CERTRules')
    oldDbCursor.execute('INSERT INTO copyDb.CWEs SELECT * FROM main.CWEs')
    oldDbCursor.execute('INSERT INTO copyDb.DiagnosticMetaAlertLinks SELECT * FROM main.DiagnosticMetaAlertLinks')
    oldDbCursor.execute('INSERT INTO copyDb.TaxonomyCheckerLinks SELECT * FROM main.TaxonomyCheckerLinks')
    oldDbCursor.execute('INSERT INTO copyDb.TaxonomyEntries SELECT * FROM main.TaxonomyEntries')
    
    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ExtraFeatures'")
    if len(oldDbCursor.fetchall()) == 1:
	oldDbCursor.execute('INSERT INTO copyDb.ExtraFeatures SELECT * from main.ExtraFeatures')

    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ExtraSourceContext'")
    if len(oldDbCursor.fetchall()) == 1:
        oldDbCursor.execute('INSERT INTO copyDb.ExtraSourceContext SELECT * from main.ExtraSourceContext')

    oldDbCursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='LizardMetrics'")
    if len(oldDbCursor.fetchall()) == 1:
        oldDbCursor.execute('CREATE TABLE copyDb.LizardMetrics (name TEXT KEY, length INTEGER, sloc INTEGER, parent TEXT, file_methods INTEGER, cyc_comp INTEGER, avg_cyc_comp REAL, func_params INTEGER, avg_sloc_file REAL, avg_params REAL, avg_sloc_folder REAL, tokens INTEGER, avg_tokens REAL, start_line INTEGER, end_line INTEGER)')
	oldDbCursor.execute('INSERT INTO copyDb.LizardMetrics SELECT * from main.LizardMetrics')

    oldConn.commit()
    oldConn.close()

    return newDbPath

# Adds sanitized path of current DB, other fields to sanitize can be added here
def addSanitFields(dbName, salt):
    tableList = ['Messages', 'Salt']

    conn = sqlite3.connect(dbName)

    for table in tableList:
        if table == 'Messages':
            cur = conn.cursor()
            newEntry = conn.cursor()

            # Determine if path has already been sanitized/inserted into current DB
            msgCols = [i[1] for i in cur.execute('PRAGMA table_info(Messages)')]

            # Sanitize path
            if 'sanitPath' not in msgCols:
                addPathSanitStr = "ALTER TABLE Messages ADD COLUMN sanitPath TEXT"
                execStrCur = 'SELECT id, path from Messages'
                execStrNew = 'UPDATE Messages SET sanitPath=? WHERE id=?'
        
                try:
                    cur.execute(addPathSanitStr)
                    cur.execute(execStrCur)
                    for entry in cur.fetchall():
                        newPath = sanitizePath(entry[1], salt)
                        newEntry.execute(execStrNew, (newPath, entry[0]))
                except:
	            print "ERROR: Unable to add sanitized database value/s."
                    conn.close()
                    sys.exit(1)

        else:
            cur = conn.cursor()
            cur.execute("CREATE TABLE Salt (salt TEXT KEY)")
            cur.execute("INSERT INTO Salt VALUES (?)", (salt,))

    conn.commit()
    conn.close()

def main():
    parser = argparse.ArgumentParser(description="Creates sanitized version of database")
    parser.add_argument("db", help="Database to sanitize")
    parser.add_argument("-n", "--newDb", help="Create new database if db of same name found", 
        action="store_true", default=False)
    args = parser.parse_args()

    if not os.path.exists(args.db):
        raise Exception("Target database does not exist")

    salt = getSalt()
    dbCopyPath = copyCurrDb(args.db, args.newDb)
    addSanitFields(dbCopyPath, salt)
    newDbPath = createSanitDb(args.db, args.newDb, salt)

if __name__ == "__main__":
    main()
