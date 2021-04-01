---
title: 'SCALe : Installing the SCALe Web App on 64-bit XUbuntu 16.04 - Offline'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Installing SCALe](Installing-SCALe.md)
<!-- <legal> -->
<!-- SCALe version r.6.5.5.1.A -->
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

SCALe : Installing the SCALe Web App on 64-bit XUbuntu 16.04 - Offline
=======================================================================

In this scenario, you install the SCALe XUbuntu Offline distribution
onto a XUbuntu machine that has no net access. The SCALe XUbuntu Offline
bundle has no external network requirements; it is entirely
self-contained. The bundle is provided to you as a tarball archive,
referred to below as `<scale-offline-tarball>.tgz`.  Remember to review
the "Documentation Conventions (Using `sudo` or `su`) for Installation
Instructions" section, security notes, and more on the main [Installing SCALe](Installing-SCALe.md)
page.

This distribution is designed for 64-bit XUbuntu distribution. After
creating such a platform, do **not** update it with newer
packages...they will probably cause the install to fail due to obsolete
dependencies.

Security Note
-------------

The SCALe web app is, by nature, a networked application. Other machines
in the system talk to the web app over a network to upload the outputs
and view the alerts. However, because of the sensitive nature of
the data on this machine, it should not be accessible from the Internet.
An Internet connection may be required to configure this machine
initially, using the instructions below. However, we recommend that this
web server, once operational, should be accessible only through an
intranet.

Documentation Conventions (Using `sudo` or `su`) for Installation Instructions
------------------------------------------------------------------------------

This documentation contains many code blocks that explain how to perform
some action. These blocks are written using the Bash shell language.
Because the syntax of different shells can vary, you may need to tweak
the syntax if you use a different shell, such as csh.

Some commands must be run with root privileges. In code blocks, these
commands are prepended with the  `sudo` command. If you get an error
when running `sudo`, then you will need to execute these commands in an
account that has administrator access. Alternatively, you can run these
commands using a root account, in which case you do not need to
prepend `sudo` to the command. If you use a proxy with your local user,
you may need to use it for your `sudo` commands. You can do so with
the -E flag as follows: `sudo -E`

Instructions
-------------

To install SCALe, you must do the following.
  1. [Tips for SCALe performance improvement](Tips-for-SCALe-performance-improvement.md)

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Installing-SCALe.md)
[![](attachments/arrow_up.png)](Welcome.md)
