---
title: 'SCAIFE: Debugging Test Suite Auto Adjudications'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Source Code Analysis Integrated Framework Environment (SCAIFE)](SCAIFE-Welcome.md)
<!-- <legal> -->
<!-- Copyright 2021 Carnegie Mellon University. -->
<!--  -->
<!-- This material is based upon work funded and supported by the -->
<!-- Department of Defense under Contract No. FA8702-15-D-0002 with -->
<!-- Carnegie Mellon University for the operation of the Software -->
<!-- Engineering Institute, a federally funded research and development -->
<!-- center. -->
<!--  -->
<!-- The view, opinions, and/or findings contained in this material are -->
<!-- those of the author(s) and should not be construed as an official -->
<!-- Government position, policy, or decision, unless designated by other -->
<!-- documentation. -->
<!--  -->
<!-- References herein to any specific commercial product, process, or -->
<!-- service by trade name, trade mark, manufacturer, or otherwise, does -->
<!-- not necessarily constitute or imply its endorsement, recommendation, -->
<!-- or favoring by Carnegie Mellon University or its Software Engineering -->
<!-- Institute. -->
<!--  -->
<!-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING -->
<!-- INSTITUTE MATERIAL IS FURNISHED ON AN 'AS-IS' BASIS. CARNEGIE MELLON -->
<!-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR -->
<!-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF -->
<!-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS -->
<!-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT -->
<!-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, -->
<!-- TRADEMARK, OR COPYRIGHT INFRINGEMENT. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- This work is licensed under a Creative Commons Attribution-ShareAlike -->
<!-- 4.0 International License. -->
<!--  -->
<!-- Carnegie Mellon® and CERT® are registered in the U.S. Patent and -->
<!-- Trademark Office by Carnegie Mellon University. -->
<!--   -->
<!-- DM20-0043 -->
<!-- </legal> -->

SCAIFE: Debugging Test Suite Auto Adjudications
==================

When modifying SCAIFE so that it works with a new test suite type, there are two major debug areas: making sure that the logic works correctly, and making sure that the input test suite micro-dataset provides sufficient test cases for marking true positives and false positives. (The micro-dataset is used for automated tests, that takes minutes instead of hours to process, so it's practical for use as part of automated tests as part of CI development of SCAIFE.) On this page, we provide methods to test and debug the logic, in case the micro-dataset doesn't yet cover sufficient test cases (and when you're not yet sure, because you haven't yet validated the logic).

There exist several scripts that cause different test suite projects to be adjudicated by SCAIFE, located within `app/scripts/automation/` - this document focuses on `create_manual_test_project_1_microjuliet_java_findbugs.py` in particular.

Once all containers are running in docker, an easy way to execute this script is:

```
docker exec scale /scale/scripts/automation/./create_manual_test_project_1_microjuliet_java_findbugs.py
```

Viewing logs from `docker logs datahub -f` can also be helpful throughout this process.

There are three methods for debugging auto adjudication results:

### 1. Auto adjudicating true results (DI_C = "TRUE") "first pass"

  In this step we debug auto adjudicating true results, while checking less of the internal logic (by overriding many logic checks for file name, file lines, CWE, and checker matching). Here we focus on ensuring the correct mappings exist for a tool's output.

   - The results of this method are stored in mongodb_datahub (port 28084) in `datahub_db.alert` as `verdict.DI_C` with a value of "TRUE". The filter `{"verdict.DI_C":"TRUE"}` will find all records correctly adjudicated in this manner.
   
   - Print statements may be added to `rapidclass_scripts/src/rclib/bin/score/score_with_defect_info.py` within the loop beginning `for di in source_file.defect_info`. Key values to note are: 
   ```
   print("{} di.present_defects: {} condition_set: {}".format(
          str(source_file.filename).ljust(90),
          str(di.present_defects).ljust(20),
          str(condition_set).ljust(73)))
   ```

   - If the `present_defects` for a source file do not match the `condition_set`, a mapping should be made via properties files, located at `app/scripts/data/properties/cwes/`. The entries map `checker_name`s to `condition_name`s by language and tools. 

      First, find the alert record in mongodb by filtering datahub_db.alert on:
   
      ```
      {"primary_message.filepath":/.*SOURCE_FILE.FILENAME.*/}
      ```
      
      using `source_file.filename` from the print statement above. Note the record's `checker_id`. 
      
      - Now query datahub_db.checker by:
      
      ```
      {_id:ObjectId('CHECKER_ID')}
      ```
      
      and copy the value for `checker_name`. We will use this in a moment.

      - Next we find the `condition_name`. Using the `checker_id` again, query `datahub_db.checker_condition` by:
      
      ```
      {"checker":ObjectId('CHECKER_ID')}
      ```
      
      and note the `conditions` array in the result. Use any of these ObjectIds to query `datahub_db.condition` with:
      
      ```
      {_id:ObjectId('CONDITIONS_ID')}
      ```

      and we see `condition_name`. Now we add a new mapping just for testing to the CWE id in the Juliet file name. The format for this new mapping is `CHECKER_NAME: CONDITIONS_ID`.
   
      For example, adding`DMI_HARDCODED_ABSOLUTE_FILENAME: CWE-789` to the file `java.findbugs_oss.properties` maps findbugs' output to a CWE for adjudication (the file name format is, `app/scripts/data/properties/cwe/LANGUAGE.TOOL_ID.properties`).  
   
   
### 2. Auto adjudicating true results (DI_C = "TRUE") in-depth

  Here we debug auto adjudications of true, while debugging more of the internal logic relating to the test suite's manifest file. 

  - Note the results are stored in mongodb exactly the same as method (1).

  - Print statements may be added to `rapidclass_scripts/src/rclib/bin/score/score_with_defect_info.py` within the loop beginning `for di in source_file.defect_info`. Here we expand our list of key values to note: 
   ```
   print("{} di.present_defects: {} condition_set: {} alert_start: {}, di.line_start: {}, di.line_end: {}".format(
          str(source_file.filename).ljust(90),
          str(di.present_defects).ljust(20),
          str(condition_set).ljust(73),
          str(alert_start).ljust(5),
          str(di.line_start).ljust(5),
          str(di.line_end)))
   ```

   - If `alert_start` does not fall between `di.line_start` and `di.line_end` a node can be added to the manifest file located at `app/demo/TOOL`, and for example, specifically at `app/demo/micro_juliet_java_findbugs_a/micro_juliet_java_manifest.xml`. Matching the line numbers can be done by adding a node to `testcase/file/mixed` for the file in question, such as,
   ```
   <mixed line="51" name="CWE-089: Improper Neutralization of Special Elements used in an SQL Command ('SQL Injection')"/>
   ```
   where the `line` number falls between `di.line_start` and `di.line_end` from the previous step print statement output.
   

### Auto adjudicating false positives (JH_C)

  - The results of this method are stored in mongodb_datahub (port 28084) in `datahub_db.alert` as `verdict.JH_C` with a value of "FALSE". The filter `{"verdict.JH_C":"FALSE"}` will find all records correctly adjudicated in this manner. If there are no records, continue to the next step.

  - Print statements similar to above may be added to `rapidclass_scripts/src/rclib/bin/score/score_with_juliet_heuristic.py`

  - In the file `scaife/datahub_server_stub/scripts/swagger_server/controllers/helper_controller.py` - we'll make an edit to temporarily change an 'elif' to an 'if', for testing JH_C. This is done to ensure that even if the meta-alert is actually a true positive specified by the manifest, it will get marked as 'False' for testing purposes.

  ```
  # change this line (approximately line 835)
  elif JH_C_false_present:

  # to
  if JH_C_false_present:
  ```

  - First, we must find an alert in `datahub_db.alert` that lies within a function. The following are examples to avoid:

  ```
  private static final boolean PRIVATE_STATIC_FINAL_TRUE = true;
  private static final boolean PRIVATE_STATIC_FINAL_FALSE = false;

  static private int intBad = 1;
  static private final ReentrantLock REENTRANT_LOCK_BAD = new ReentrantLock();
  ```
  
  Rather, we are looking for a proper function or method such as:
  
  ```
  public void bad() throws Throwable
  {
    //logic
  }  
  ```
  
  In particular, we are looking for the function beginning line number. More on this in a moment (`/micro_juliet_java/CWE789_Uncontrolled_Mem_Alloc__File_HashMap_15.java`, line 43 will be a good example function).

  - We must unzip the test suite, find and modify the file, and recreate the zip file. Here is the process:

  ```
  # suites are zip files in the `app/demo/TOOL` directory
  cd ui_server_stub/scale.app/demo/micro_juliet_java_findbugs_a

  # now unzip the test suite zip file and view its content
  unzip micro_juliet_java.zip
  cd micro_juliet_java
  ls
  
  vi CWE789_Uncontrolled_Mem_Alloc__File_HashMap_15.java
  ```

  Note on line 43 the method `public void bad() throws Throwable` and change its signature to `public void good() throws Throwable`, save, and exit the editor. Now we recreate the zip file:

  ```
  cd ../

  # delete the original zip
  rm micro_juliet_java.zip

  # create the new zip
  zip -r micro_juliet_java.zip micro_juliet_java

  # clean up the files we unzipped
  rm -rf micro_juliet_java
  ```

  - Now add a properties file mapping for `CHECKER_NAME: CONDITIONS_ID` as outlined in (1) above.


----

## Confirming Stats Module

To confirm that the Stats module is correctly handling Juliet Java data (the above tests confirm DataHub), perform the following:

- Open the project in the SCALe GUI after running the script (typically http://localhost:8083), and check two things: 

  - (A) That each meta-alert has a confidence value.
  - (B) There are at least 2 different confidence values (set ordering to be by confidence value, then first set the order 'ascending' then 'descending', and check if the confidence is different for the top meta-alert with those different orders).


## Other background information that you might find helpful

A. (From `helper_controller.py`) Regarding the aggregation of auto-determinations in alerts the distinct values in the meta-alert verdict field:

  Verdict Definitions:
      1. JH_C: Verdicts scored using the Juliet naming heuristic (JH) and
      “canonical” mappings (C). Here canonical is meant to be the opposite of speculative.
      1. DI_C: Verdicts scored using defects identified (DI) by the SARD manifest,
      and canonical mappings.
      
  Rules on aggregation:
   1. For any DI_C verdict (specific to a CWE) mapped to an alert, its meta-alert must be True. Ignore any different (false) JH_C verdict.

   1. Only True verdicts for test suites derived from DI_C, and CERT rule-mapped-from-CWEs should be sent to the Stats module.

   1. For any JH_C verdict (specific to a CWE) that is False, that is the verdict for the meta-alert.

  When aggregating alerts to the meta-alert level, eliminate the additional portion of the array in the verdict that has the conditions so that the auto_verdict field takes the form
  `{"JH_C": "TRUE", "DI_C": "TRUE"}`
  //TODO you'll see these values in meta_a and alert verdict fields


B. (From `score_with_juliet_heuristic.py`) Regarding detail on (3) above and specific to Juliet: 

  This is only applicable to alerts generated from the Juliet testsuite. An alert is identified as true or false based on the name of the function and file within which it occurs.

  Functions that contain the word "good", or which are inside a file that contains the word "good", are considered to be false positives.

  Functions that contain the word "bad", or which are inside a file that contains the word "bad", are considered to be true positives.

  Examples:

  This script is passed the name of the database containing alerts to be scored.
  ```
  $ python score_alerts_juliet_funcname_heuristic.py db_name
  ```
  The typical database authentication mechanisms apply.

## Technique for using log file instead of print to debug

Typically, `docker logs datahub -f` is used to display print statements that are helpful during the debugging process. In some cases where print statements do not output correctly, an alternative method can be used to write to a local file within the container, which can then be viewed through a docker `exec` command.

1. To debug a method in question, modify the python file in this manner: 

```
# for a particular method
def aggregate_auto_determinations(meta_alerts):
  with open("/debug.log", "a") as debug_log: # wrap the method logic
    debug_log.write("METHOD: aggregate_auto_determinations() \n") # note "\n" to wrap line
    # the original method follows here
    debug_log.write("File: {}\n".format(file.name))
```

When adding the `with open`, be mindful of indentation gotchas! If the datahub container fails to start, you likely have an indentation error, and this will be shown in the logs: `docker logs datahub`.

To view the debug log:

```
docker exec datahub cat /debug.log
```