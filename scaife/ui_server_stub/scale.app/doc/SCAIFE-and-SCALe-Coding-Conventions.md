---
title: 'SCALe : SCAIFE and SCALe Coding Conventions'
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

SCAIFE : SCAIFE and SCALe Coding Conventions
===========================================

This section documents the coding conventions and style guide that we
have decided to use when coding SCALe and SCAIFE.

### Code Documentation

The top of every text file should have top-level code comments saying
generally what the file is for. These comments are for developers who
might want to modify the file.

Remember to add blank line after code comments, then legal markings
(``<legal></legal>``), then another blank line before the start of the
code.

A script is any file that can be invoked from from a shell. Scripts
have some additional constraints:

 * There should be 'manual' documentation which provides an overview
   of what the script does. This belongs in the [Back-End Script
   Design](Back-End-Script-Design.md) page. This documentation should
   be useful for developers and non-developers alike. For all the scripts,
   target this documentation to be comprehensible by non-developers, who
   may need to run the script but aren't interested in how it works or could
   be modified.

 * The script should provide its own 'help' documentation, which
   provides a quick reference for what arguments the script takes as
   input, and what it produces as output. This documentation could be
   provided by a script upon any invocation, or when fed invalid
   arguments, or when requested, perhaps via a ``-h`` or ``--help``
   argument. This documentation should live near the top of the
   script, perhaps in a usage() function or global variable.

   For Python scripts specifically (new scripts or scripts you edit):
   - Make sure (add if needed) that there is a "``--help``" use statement
   which includes the info in the code comments, PLUS info about each
   of the input parameters (This is most easily accomplished using
   Python's argparse library).
   - Python  test scripts should invoke pytest.main().
   Documentation on using pytest are here: https://docs.pytest.org/en/stable/.

 * If you add a new function, unless
   super-simple and immediately obvious, add a comment above it
   specifying what it does. Please do same if you modify a function
   that doesn't already have an appropriate function comment.

 * Note: If a module is not intended to be invoked as a script for
   normal usage, or is a script that takes no arguments, the overview of
   the module as described in the top comments is sufficient
   documentation. In these cases there is no need to add a "--help"
   command line argument and associated help text.
   
### Python3 versus Python2
SCALe code, which is located in `scale.app` directory and below, still uses the old Python version 2 (here, called Python2). 
The rest of SCAIFE uses Python version 3 (here, called Python3). There might currently exist
rare exceptions where non-SCALe code in SCAIFE uses Python2 or SCALe code uses Python3.

 * Even within SCALe code, try to comply as much as possible with Python3 requirements, 
 where the code will also work in python2. Most print statements can be changed to work 
 for both python3 and python2 (often simply by adding parentheses), and developers 
 should do that.
 * We plan to upgrade SCALe to Python3. We have already put in considerable effort to 
 make much of the current SCALe code compatible with Python3, but it will take more 
 work to complete.
 * If you absolutely must use Python2 outside of the `scale.app` repository, there 
 should be a very strong justification. In that case, the user must be notified of 
 this unusual requirement. The use-statement should include that fact with the 
 following text: "This script must be run with python2, different than the 
 default for scripts in the {{rapidclass_scripts}} path." Also, the overview of 
 what the script does in {{Back-End-Script-Design.md}} must specify that it 
 uses Python2.

### Non-Scriptable Conventions

Bash is a fine shell for interactive work, but do not run bash in any
script. Some smaller platforms use Dash or some other minimal
shell. For maximum portability run `/bin/sh` instead of Bash. The Bourne
shell (`/bin/sh`) is available on all POSIX-compliant platforms, and is
just as suitable as Bash for running shell scripts.

### Copyright Conventions

Each source file (minus excepted filetypes discussed below) should have legal tags:
`<legal></legal>`

When SCALe is bundled for release, these tags are changed to contain legal information, including a copyright and distribution markings. The legal information is contained in the `ABOUT` file.

The legal information should appear after the top-level comments, but before any code or data. A single blank line separates the legal information from the code/data.

#### Filetype Exceptions

We don't have to add the legal text to filetypes where adding the text would make it non-functional.
Among others, filetype exceptions include:

- .ORG
- .CSV
- .JSON
- .sqlite3

### Debugging Output in SCAIFE

During development it is common to use `print()` statements in order to determine whether things are working as expected or to diagnose a failure. Printing to `sys.stdout` does not produce output in the system log output during normal operations -- however, `sys.stdout` *is* captured and displayed during tox tests in the event of a failed test (as is `sys.stderr` but that will not be displayed grouped together in the output for the entire failed test). Note that printing from within the tox tests, as opposed to the controller code, appears immediately as the tests run.

Within the controller code, therefore, it's useful to have debugging messages print to `sys.stderr` during runtime operations in order for the information to appear in the system log. During tox tests, however, it's useful for debugging messages to be printed to `sys.stdout`.

Each of the SCAIFE modules, except for registration, have a `controllers/helper_controller.py` file. In these files a `print()` function is defined as well as a module variable `PRINT_TO_CONSOLE`. The controllers can then import this print function (overriding system `print()`)  like so:

```
from .helper_controller import print
```

With that, if `PRINT_TO_CONSOLE` is set to `True` inside the helper controller then print statements will go to `sys.stderr`. If it is set to `False` they will go to `sys.stdout`. If any particular print statement explicitly specifies a `file` destination parameter then that decision is respected and remains unaltered.


### SCAIFE Design Decisions not in Formal API

This section documents SCAIFE development design decisions which developers need to know about, which aren't documented in the formal SCAIFE APIs. This documentation is important so developers can avoid violating architectural design decisions they aren't aware of.

These design decisions include: 

* Only authors of SCAIFE packages are allowed to delete those SCAIFE packages from the SCAIFE DataHub.
* Only authors of SCAIFE projects are allowed to delete those SCAIFE projects from the SCAIFE DataHub.


### SCAIFE API (openapi) multipart/form-data

There are numerous issues that crop up using swagger/openapi
specifications and their implementation with the connexion module. In
particular, issues arise when attempting to upload file data while at the
same time submitting other metadata parameters.

After much experimentation, here is a way that works. The solution below
requires `connexion` >= 2.6.0.

Since plain string fields work, combined queries can be made to work
with a little extra effort using JSON, and this is how the `edit_tool()`
specification is done for the DataHub. First, the relevant part of the
specification in `swagger.yaml`:

```
   requestBody:
     content:
       multipart/form-data:
         schema:
           x-body-name: parameters_besides_files
           type: object
             name:
               type: string
             some_file:
               type: string
               format: binary
             another_file:
               type: string
               format: binary
             address:
               type: object
               properties:
                 street:
                   type: string
                 city:
                   type: string
             other_info:
               type: object
               properties:
                 acceptable_flavors:
                   type: list
                   items:
                     type: string
                 favorite_flavor:
                   type: string
         encoding:
           address:
             contentType: application/json
```

In the client code (or in the test code), the query parameters (not the
file parameters) should be manually encoded as JSON:

```
   fpath1 = '/path/to/interesting_file1.csv'
   fpath2 = '/path/to/interesting_file2.csv'
   with open(os.path.join(fpath1, 'rb') as fh:
     some_file_bytes1 = BytesIO(fh.read())
   with open(os.path.join(fpath2, 'rb') as fh:
     some_file_bytes2 = BytesIO(fh.read())
   some_file_data = (some_file_bytes1, fpath1)
   another_file_data = (some_file_bytes2, fpath2)
   address = dict(
       street = "a street address",
       city = "Metropolis",
   )
   other_info = dict(
       acceptable_flavors = ["butterscotch", "almond"],
       favorite_flavor = "almond",
   )
   # assemble the payload
   data = dict(
     # Any object parameter (there can be multiple object parameters)
     # needs to be JSON-encoded and referenced in the encoding
     # stanza of the YAML specification.
     name = "Juanita Guttierez",
     some_file = some_file_data,
     another_file = another_file_data,
     address = json.dumps(address),       # <-- like this
     other_info = json.dumps(other_info), # <-- and this
   )
   response = self.client.open(url, method='POST',
     data=data,
     headers=valid_headers,
     content_type='multipart/form-data')
```

Each query parameter will then individually be an unpacked structure
when the controller action receives it.

Any plain string fields or file fields will be passed to the controller
as top-level named parameters. Any of the individually JSON-encoded
fields, however, will be inside the parameter named the same as whatever
was specified for `x-body-name` -- in this example, `json_params`. So in
the controller:

```
   def query_handler(x_auth_token, \
           json_params=None, name=None, some_file=None, another_file=None):
```

In this example, the `json_params` value will be a dict with the keys
`address` and `other_info`, each containing their respective unpacked
structures.

#### Rationale

It's important to realize that `connexion` *does not* natively support
multipart functionality as the openapi 3 specification indicates that it
should. It is partially supported. In particular, file uploads
combined with other JSON payloads will not work the way that openapi
says it should in the following examples.

Also, trying any of this with multipart/mixed will not work with
`connexion`.

So this is theoretically supposed to work, and you don't have to encode
anything with JSON in the query data field. But it does not work with
`connexion`:

```
  requestBody:
    content:
      multipart/form-data:
        schema:
          type: object
            name:              # This is fine
              type: string
            address:           # This breaks
              type: object
              properties:
                street:
                  type: string
                city:
                  type: string
            some_file:         # This is fine
              type: string
              format: binary
```

Specifying two different response types doesn't work either, with
`connexion`. Even if this did work, it would require two queries to
complete the full operation. Below does not work:

```
  requestBody:
    content:
      multipart/form-data:
        schema:
          type: object
            name:
              type: string
            some_file:  # This sort of works, but json is a no-go
              type: string
              format: binary
      application/json:
        schema:
          type: object
            label:
              type: string
            address:
              type: object
              properties:
                street:
                  type: string
                city:
                  type: string
```
