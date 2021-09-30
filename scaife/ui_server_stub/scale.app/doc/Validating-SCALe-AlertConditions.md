---
title: 'SCALe : Validating SCALe AlertConditions'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md)
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

SCALe : Validating SCALe AlertConditions
================================

There are several processes that can be used to audit a SCALe project:

1. **Audit all that can be done in a limited time and effort:**

-   List (prioritize) fused meta-alerts according to a value such as
    priority or *confidence* that the alertCondition is a true positive. (An
    alertCondition confidence might be derived from a
    [classifier](https://insights.sei.cmu.edu/sei_blog/static-analysis-alert-classification-and-prioritization/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
    Alternatively, confidence could be derived from taxonomy
    descriptions and thus apply to every meta-alert mapped to a
    particular condition from a taxonomy, e.g., the Likelihood value for
    INT31-C is a confidence value. Alternatively, organizations or
    analysts can develop their own methods to determine alertCondition confidence
    metrics.) Filter for conditions and/or directories your particular
    organization cares about most, if that is appropriate.
-   Examine each meta-alert (with unique condition, filepath, and line
    number) sequentially, starting from the top shown in the list.
-   For each meta-alert:
    -   Examine all the fused alertConditions' messages and secondary message.
    -   Set the meta-alert's verdict (e.g., `True` or `False`),
        supplemental verdict(s), Note field text (as needed), and flag
        (as needed).
-   Proceed to the next meta-alert.

2. **Audit via sampling method:** For each condition (e.g., CERT rule
or CWE):

-   List (prioritize) fused meta-alerts according to a value such as
    priority or confidence. Filter for conditions and/or directories
    your particular organization cares about most, if that is
    appropriate.
-   For each checker associated with a condition:
    -   If there are more than 14 meta-alerts:
        -   You need only audit [a random
            sample](Creating-a-Random-Sample.md) of
            meta-alerts for that checker and condition.
    -    Otherwise, audit all of the meta-alerts.
    -   For each meta-alert in your sample:
        -   Analyze the meta-alert (and all fused alertCondition messages and
            secondary messages).
        -   Set the meta-alert's verdict (e.g., `True` or `False`),
            supplemental verdict(s), Note field text (as needed), and
            flag (as needed).
        -   If it is a true positive:
            -   Mark every other un-audited meta-alert associated with
                this condition as flagged (to indicate `Suspicious).`
            -   Proceed to the next condition.
    -   If you audited a random sample and had no true positives:
        -   Mark every remaining un-audited alertCondition associated with this
            checker as `Ignored.`
        -   Proceed to the next checker.

3. **Use** **an automated classifier:** Use an automated classifier to
partition alertConditions into expected-true (e-TP), expected-false (e-FP), and
indeterminate (I). The automated classifier can be used in conjunction
with prioritization of manual examination of indeterminate alertConditions. This
version of SCALe includes many features for integrating use of
classification, but it only performs automated classification when connected to a SCAIFE System.
[We do research on methods for accurate meta-alert classification and advanced methods for prioritizing alerts](https://www.sei.cmu.edu/research-capabilities/all-work/display.cfm?customel_datapageid_4050=6453){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).


Reference the [SCALe Web Application
documentation](The-SCALe-Web-App.md#alertcondition-viewer-fields)
and the [Quick Start
Demo](SCALe-Quick-Start-Demo-for-Auditors.md) for
information on how to use the web interface to verify alerts.

If you create a [SCALe Audit
Report](Building-an-Audit-Report.md), then Section 3 of that
report will contain several blurbs, describing important meta-alerts. When
you find a true meta-alert with a high priority you should write a blurb
about it for the report. After Section 3 is full, you can analyze the
remaining meta-alerts without writing more blurbs. However, they are also
useful in convincing yourself (and others) that your reasoning is sound
and you have not made any mistakes.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](SQL-Dump.md)
[![](attachments/arrow_up.png)](Audit-Instructions.md)
[![](attachments/arrow_right.png)](Building-an-Audit-Report.md)
