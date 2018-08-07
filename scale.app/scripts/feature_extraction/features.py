# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import json
import types


class Category(object):
    Diagnostic = "Diagnostic"


class Tool(object):
    Coverity = "coverity"
    Fortify = "fortify"
    PCLint = "pclint"
    GCC = "gcc"
    VisualStudioCodeAnalysis = "msvs"


class FeatureName(object):
    LineStart = "LineStart"
    LineEnd = "LineEnd"
    ColStart = "ColStart"
    ColEnd = "ColEnd"
    FilePath = "Path"
    Message = "Message"
    Checker = "Checker"
    Category = "Category"
    Tool = "Tool"
    FunctionOrMethod = "FunctionOrMethod"
    Class = "Class"
    Namespace = "Namespace"
    FortifyKingdom = "FortifyKingdom"
    FortifyClassId = "FortifyClassID"
    FortifyClassType = "FortifyClassType"
    FortifyClassSubType = "FortifyClassSubType"
    FortifyAnalyzerName = "FortifyAnalyzerName"
    FortifyDefaultSeverity = "FortifyDefaultSeverity"
    FortifyInstanceId = "FortifyInstanceId"
    FortifyInstanceInfo = "FortifyInstanceInfo"
    FortifyInstanceSeverity = "FortifyInstanceSeverity"
    FortifyConfidence = "FortifyConfidence"


class Feature(object):

    def __init__(self, name=None, ftype=None, value=None, is_sensitive=None):
        self.name = name
        self.type = ftype
        self.value = value
        self.is_sensitive = is_sensitive

    def __str__(self, *args, **kwargs):
        return self.__repr__()

    def __repr__(self, *args, **kwargs):
        return "Feature({0},{1},{2},{3})".format(self.name, self.type, self.value, self.is_sensitive)


class StringFeature(Feature):

    def __init__(self, name, value, size=None, is_sensitive=False):
        super(StringFeature, self).__init__()
        self.name = name
        try:
            if value is None:
                self.value = None
            else:
                self.value = str(value)
        except:
            self.value = None
        self.type = types.StringType
        self.size = size
        self.is_sensitive = is_sensitive


class IntFeature(Feature):

    def __init__(self, name, value, is_sensitive=False):
        super(IntFeature, self).__init__()
        self.name = name
        try:
            self.value = int(value)
        except:
            self.value = None
        self.type = types.IntType
        self.is_sensitive = is_sensitive


class FloatFeature(Feature):

    def __init__(self, name, value, is_sensitive=False):
        super(FloatFeature, self).__init__()
        self.name = name
        try:
            self.value = float(value)
        except:
            self.value = None
        self.type = types.FloatType
        self.is_sensitive = is_sensitive


class CheckerFeature(StringFeature):

    def __init__(self, value):
        super(CheckerFeature, self).__init__(
            name=FeatureName.Checker,
            value=value,
            size=128)


class ToolFeature(StringFeature):

    def __init__(self, value):
        super(ToolFeature, self).__init__(
            name=FeatureName.Tool,
            value=value,
            size=64)


class CategoryFeature(StringFeature):

    def __init__(self, value):
        super(CategoryFeature, self).__init__(
            name=FeatureName.Category,
            value=value,
            size=64)


class LineStartFeature(IntFeature):

    def __init__(self, value):
        super(LineStartFeature, self).__init__(
            name=FeatureName.LineStart,
            value=value)


class LineEndFeature(IntFeature):

    def __init__(self, value):
        super(LineEndFeature, self).__init__(
            name=FeatureName.LineEnd,
            value=value)


class ColStartFeature(IntFeature):

    def __init__(self, value):
        super(ColStartFeature, self).__init__(
            name=FeatureName.ColStart,
            value=value)


class ColEndFeature(IntFeature):

    def __init__(self, value):
        super(ColEndFeature, self).__init__(
            name=FeatureName.ColEnd,
            value=value)


class MessageFeature(StringFeature):

    def __init__(self, value):
        super(MessageFeature, self).__init__(
            name=FeatureName.Message,
            value=value,
            is_sensitive=True)


class FilePathFeature(StringFeature):

    def __init__(self, value):
        super(FilePathFeature, self).__init__(
            name=FeatureName.FilePath,
            value=value,
            is_sensitive=True)


class FunctionOrMethodFeature(StringFeature):

    def __init__(self, value):
        super(FunctionOrMethodFeature, self).__init__(
            name=FeatureName.FunctionOrMethod,
            value=value,
            is_sensitive=True,
            size=128)


class ClassFeature(StringFeature):

    def __init__(self, value):
        super(ClassFeature, self).__init__(
            name=FeatureName.Class,
            value=value,
            is_sensitive=True,
            size=128)


class NamespaceFeature(StringFeature):

    def __init__(self, value):
        super(NamespaceFeature, self).__init__(
            name=FeatureName.Namespace,
            value=value,
            is_sensitive=True,
            size=128)


class FortifyKingdomFeature(StringFeature):

    def __init__(self, value):
        super(FortifyKingdomFeature, self).__init__(
            name=FeatureName.FortifyKingdom,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyClassIdFeature(StringFeature):

    def __init__(self, value):
        super(FortifyClassIdFeature, self).__init__(
            name=FeatureName.FortifyClassId,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyClassTypeFeature(StringFeature):

    def __init__(self, value):
        super(FortifyClassTypeFeature, self).__init__(
            name=FeatureName.FortifyClassType,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyClassSubTypeFeature(StringFeature):

    def __init__(self, value):
        super(FortifyClassSubTypeFeature, self).__init__(
            name=FeatureName.FortifyClassSubType,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyAnalyzerNameFeature(StringFeature):

    def __init__(self, value):
        super(FortifyAnalyzerNameFeature, self).__init__(
            name=FeatureName.FortifyAnalyzerName,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyInstanceIdFeature(StringFeature):

    def __init__(self, value):
        super(FortifyInstanceIdFeature, self).__init__(
            name=FeatureName.FortifyInstanceId,
            value=value,
            is_sensitive=False,
            size=128)


class FortifyDefaultSeverityFeature(FloatFeature):

    def __init__(self, value):
        super(FortifyDefaultSeverityFeature, self).__init__(
            name=FeatureName.FortifyDefaultSeverity,
            value=value)


class FortifyInstanceSeverityFeature(FloatFeature):

    def __init__(self, value):
        super(FortifyInstanceSeverityFeature, self).__init__(
            name=FeatureName.FortifyInstanceSeverity,
            value=value)


class FortifyConfidenceFeature(FloatFeature):

    def __init__(self, value):
        super(FortifyConfidenceFeature, self).__init__(
            name=FeatureName.FortifyConfidence,
            value=value)


class Measurement(object):

    def __init__(self):
        self.features = []
        self.submeasurements = []

    def add_feature(self, feature):
        self.features.append(feature)

    def add_sub_measurement(self, measurement):
        self.submeasurements.append(measurement)

    def feature_dict(self):
        result = dict()
        for feature in self.features:
            result[feature.name] = feature

        result["__sub"] = []
        for sm in self.submeasurements:
            result["__sub"].append(sm.feature_dict())

        return result

    def feature_value_dict(self):
        result = dict()
        for feature in self.features:
            result[feature.name] = feature.value

        result["__sub"] = []
        for sm in self.submeasurements:
            result["__sub"].append(sm.feature_value_dict())

        return result


class Diagnostic(Measurement):

    def __init__(self, tool=None):
        super(Diagnostic, self).__init__()
        self.add_feature(CategoryFeature(Category.Diagnostic))
        if tool is not None:
            self.add_feature(ToolFeature(tool))
