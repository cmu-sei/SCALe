# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import parse_coverity
import parse_fortify
import parse_pclint
import parse_gcc
from features import Tool

extractors = {
    Tool.Coverity: {
        "json_v2": parse_coverity.coverity_json_v2_parser
    },
    Tool.Fortify: {
        "dev_xml": parse_fortify.fortify_dev_xml_parser,
        "fvdl": parse_fortify.fortify_fvdl_parser
    },
    Tool.PCLint: {
        "custom": parse_pclint.pclint_custom_parser
    },
    Tool.GCC: {
        "warnings": parse_gcc.gcc_warning_parser
    }
}
