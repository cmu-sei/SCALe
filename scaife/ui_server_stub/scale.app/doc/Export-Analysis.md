---
title: 'SCALe : Export Analysis Results from the Web Application (Internal)'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
<!-- <legal> -->
<!-- SCALe version r.6.7.0.0.A -->
<!--  -->
<!-- Copyright 2021 Carnegie Mellon University. -->
<!--  -->
<!-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING -->
<!-- INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON -->
<!-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR -->
<!-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF -->
<!-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS -->
<!-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT -->
<!-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, -->
<!-- TRADEMARK, OR COPYRIGHT INFRINGEMENT. -->
<!--  -->
<!-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or -->
<!-- contact permission@sei.cmu.edu for full terms. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- DM19-1274 -->
<!-- </legal> -->

SCALe : Export Analysis Results from the Web Application (Internal)
====================================================================

Prerequisites for This Step
---------------------------

1.  Access to a SCALe web app (you need the URL of the application plus
    a username and password, obtainable from your SCALe administrator)
2.  A supported web browser (currently Chrome, Firefox, or Internet
    Explorer)
3.  The dos2unix alerts from Coverity and Fortify uploaded to the
    web application (as done in [Step
    3](Upload-Source-Code-and-Analysis-Outputs.md))

After auditing alertConditions in the SCALe web app, you can export the
results of your audit to a SQLite or CSV file. Note that **a SQLite
export contains all the data from the project, but a CSV export does
not** (e.g., a CSV export does not contain secondary alert
messages, may not contain all (or any) of the primary alert
messages, and may not include alert IDs). An exported SQLite or CSV
file is often further analyzed to produce statistics for a report.

To obtain a CSV file, go to the SCALe web app homepage and click the
**Export CSV** link for the desired project.

In this case, we download an archive of CSV files for the dos2unix audit.

![Export dos2unix](attachments/ExportTables.png)

Save the file to your local system. You can now open this file in a
spreadsheet tool such as Excel. The CSV file contains information about
every alert in the project: the tool that produced the alert,
the file and line number where the alert occurs, the message from
the alert, and so on. (However, as mentioned above, a SQLite export
contains all the data from a project but a CSV export does not.) See
[this table](The-SCALe-Web-App.md#alertcondition-viewer-fields)
for a detailed explanation of all the alert fields.

This completes our demo of the SCALe process.

 ------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Inspect-Alerts-for-Violations-of-CERT-Secure-Coding-Rules.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Audit-Instructions.md)

Attachments:
------------

![](images/icons/bullet_blue.gif) [ExportTables](attachments/ExportTables.png) (image/png)
