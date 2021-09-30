---
title: 'SCALe : Creating a Random Sample'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Validating SCALe AlertConditions](Validating-SCALe-AlertConditions.md)
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

SCALe : Creating a Random Sample
=================================

This process clarifies the strategy coarsely described on page 5 of the
technical
note [Improving the Automated Detection and Analysis of Secure Coding Violations](https://resources.sei.cmu.edu/library/asset-view.cfm?assetID=295724){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
(There is an older process that is precisely described on page 4 of the
same note, but we do not address that here.)  This paper addresses how
to audit a set of alerts. See [Terms and Definitions](Terms-and-Definitions.md) for definitions of alert, alertCondition,
fusion, and meta-alert. That paper predates alertCondition fusion, and thus,
does not address meta-alerts.  NOTE: Should update this process described below to
use meta-alerts as well as the precise definition of alertCondition, whereas the description below conflates it with
alerts in some cases.

Every analysis tool contains a set of checkers. These checkers produce
alerts, some of which will be false positives. The False
Positive Rate (FPR) is the ratio of false positives to total alerts
produced by any checker.

The FPR of checkers can vary. Generally the more a checker tries to
lower its FPR, the more likely it is to not report true positives (for
fear of them actually being false). However, there are many checkers
that have such high FPRs that they can overwhelm the capability of
auditors to manage their output. Therefore, to make the auditing task
manageable, we endeavor to ignore checkers whose FPR is greater than
80%.

Suppose we have a set of alerts that correspond to a single checker. We
audit a random sample of alerts from this set.

Let:

> N = Total Number of alerts\
> n = Number to be Audited (sample size)\
> TP = Number of True Positives in Sample

Then the sample proportion P is:

> P = n / N

and the sample false positive rate (sFPR) is:

> sFPR = 1 - (TP / n)

The standard error of the estimate (SE) should be computed in one of two
ways, depending on P. If P &lt; 5%, then the formula is:

> SE = (sFPR \* (1 - sFPR) / n) \^ 0.5

If P &gt; 5%, the formula is:

> SE = ((sFPR \* (1 - sFPR) / n) \^ 0.5) \* ((1 - n / N)) \^ 0.5

We can therefore estimate a 95% confidence interval for the actual FPR
based on the sample. The expected value will be the sample false
positive rate (sFPR), but we wish to establish that the actual FPR is
95% likely to be above 80%. If the sFPR is high, then the interval's
upper bound (UB) will be close to 100% and of no interest to us; we need
only verify that the lower bound is 80% or more. The lower bound (LB)
is:

> LB = sFPR - 1.96 \* SSE

To discover the properties of this formula, we constructed an Excel
spreadsheet that let us provide input values for N, n, and TP. We
discovered the following:

If TP is 0 (no true positives were found), then the upper bound and
lower bound will both be 100%, which do not indicate a useful sample
size. Therefore we set TP to be 1. That is, out of our sample, exactly 1
alert was true and all the rest are false.

The UB and LB both depend on N, the total number of alerts. As N
increases, LB decreases. However, as N gets larger, its effects on the
LB diminish. At N=1000, the LB value remains constant (to 0.1%) if N is
set to any value larger than 1000. So N=1000 is a reasonable "arbitrary
large value" figure.

With TP=1 and N=1000, if we set n=14, then the lower bound (LB) is
79.4%. But if n=15, then LB = 80.7%. Since the LB would be higher if
N&lt;1000, we can conclude that LB&gt;80% when TP=1, n&gt;=15 for all N.

In other words, if a single true positive is found, we can still
guarantee (with 95% confidence) that the checker's false positive rate
(FPR) &gt; 80% if our sample size is at least 15. Extrapolating, we
conclude that a sample size of 14 alerts is sufficient to guarantee
FPR&gt;80% if all of the alerts are false. The sample size might be
smaller if the total set of alerts is under 1000.

We therefore discovered the necessary sample sizes for several
additional TP values:

+-----------------------------------+-----------------------------------+
| True Positives (TP)               | Sample (n)                        |
+===================================+===================================+
| 0                                 | 14                                |
+-----------------------------------+-----------------------------------+
| 1 or less                         | 15                                |
+-----------------------------------+-----------------------------------+
| 2 or less                         | 24                                |
+-----------------------------------+-----------------------------------+
| 3 or less                         | 32                                |
+-----------------------------------+-----------------------------------+

That is, if you pick a random sample of 15 alerts out of all the alerts
associated with a checker, and all but one of them are false, you can
mark them as `False` and the remainder as `Ignored`.
