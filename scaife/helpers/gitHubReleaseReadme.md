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

# Information About the SCAIFE-SCALe Public Release (includes SCALe)

This release is for public distribution. In creating the release,
parts of SCAIFE were removed since the entire system is not publicly
releasable at this time. SCALe was developed as a separable module for
the SCAIFE system instantiation and used as the UI module within the
system. This release does not have the full set of five SCAIFE API
(.yaml) files described below, however the SCAIFE API .yaml files are
published on GitHub at https://github.com/cmu-sei/SCAIFE-API. Use
these files when instructions say to view the API in
swagger-editor. The tech manual with some additional instructions
beyond the SCAIFE/SCALe HTML manual (mentioned below) can be helpful
with getting started in SCALe. More specifically, the 'Partial Access'
method found here:
`https://resources.sei.cmu.edu/asset_files/UsersGuide/2020_012_001_644362.docx`
describes how to start SCALe as a UI module in SCAIFE when the other
servers are not available.

# SCAIFE/SCALe HTML manual

Much use, system design, and development information is provided in
the included SCAIFE/SCALe HTML manual. To view it, in your web browser
open this file location (first starting at SCAIFE home page, second
starting at SCALe home page):

* `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html`
* `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`


# SCAIFE APIs

This repository contains Swagger and non-Swagger files supporting the
SCAIFE API, instantiation of the API, and further development of the
API and instantiations of it. Additional instructions on instantiating
the APIs can be found here:
https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=644354.

The directory 'scaife/helpers' contains helper scripts useful to
developers and testers during code development.

The file 'scaife/ABOUT' provides product and version information for a
particular SCAIFE system release. This is a release of code and a
system that instantiates the SCAIFE UI module's API. The SCAIFE system
version is not necessarily the same as the API for a particular SCAIFE
module. Each of the four non-SCALe SCAIFE modules has an API version
that is specified in its swagger/swagger.yaml file in a line
specifying 'version', as in the following line: version: '1.2.2'

The API definitions are available in the following 15 files (5
different `*_server_sub` directories) in the full SCAIFE system:

```
scaife/*_server_stub/swagger_server/swagger/swagger.yaml
scaife/*_server_stub/swagger_server/swagger/swagger.json
scaife/*_server_stub/swagger_server/templates/index.html
```

# Additional Info

## SCAIFE Presentation

More details about SCAIFE have been presented to the DoD National
Nuclear Security Administration (NNSA) Software Assurance Community of
Practice (SwA CoP). The presentation slides are location at:
https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=645790. A
lot of content about SCAIFE, SCALe and other related topics are
available here:
https://resources.sei.cmu.edu/library/author.cfm?authorid=31216.
