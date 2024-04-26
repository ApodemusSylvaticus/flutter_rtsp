//
//  Generated code. Do not modify.
//  source: archer_protocol.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class OkStatusCode extends $pb.ProtobufEnum {
  static const OkStatusCode UNKNOWN_OK_STATUS = OkStatusCode._(0, _omitEnumNames ? '' : 'UNKNOWN_OK_STATUS');
  static const OkStatusCode SUCCESS = OkStatusCode._(1, _omitEnumNames ? '' : 'SUCCESS');

  static const $core.List<OkStatusCode> values = <OkStatusCode> [
    UNKNOWN_OK_STATUS,
    SUCCESS,
  ];

  static final $core.Map<$core.int, OkStatusCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OkStatusCode? valueOf($core.int value) => _byValue[value];

  const OkStatusCode._($core.int v, $core.String n) : super(v, n);
}

class ErrorStatusCode extends $pb.ProtobufEnum {
  static const ErrorStatusCode UNKNOWN_ERROR_STATUS = ErrorStatusCode._(0, _omitEnumNames ? '' : 'UNKNOWN_ERROR_STATUS');
  static const ErrorStatusCode FAILURE = ErrorStatusCode._(1, _omitEnumNames ? '' : 'FAILURE');
  static const ErrorStatusCode INVALID_DATA = ErrorStatusCode._(2, _omitEnumNames ? '' : 'INVALID_DATA');

  static const $core.List<ErrorStatusCode> values = <ErrorStatusCode> [
    UNKNOWN_ERROR_STATUS,
    FAILURE,
    INVALID_DATA,
  ];

  static final $core.Map<$core.int, ErrorStatusCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ErrorStatusCode? valueOf($core.int value) => _byValue[value];

  const ErrorStatusCode._($core.int v, $core.String n) : super(v, n);
}

class HoldoffType extends $pb.ProtobufEnum {
  static const HoldoffType UNDEFINED = HoldoffType._(0, _omitEnumNames ? '' : 'UNDEFINED');
  static const HoldoffType MIL = HoldoffType._(1, _omitEnumNames ? '' : 'MIL');
  static const HoldoffType MOA = HoldoffType._(2, _omitEnumNames ? '' : 'MOA');
  static const HoldoffType CLICKS = HoldoffType._(3, _omitEnumNames ? '' : 'CLICKS');

  static const $core.List<HoldoffType> values = <HoldoffType> [
    UNDEFINED,
    MIL,
    MOA,
    CLICKS,
  ];

  static final $core.Map<$core.int, HoldoffType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HoldoffType? valueOf($core.int value) => _byValue[value];

  const HoldoffType._($core.int v, $core.String n) : super(v, n);
}

class ColorScheme extends $pb.ProtobufEnum {
  static const ColorScheme UNKNOWN_COLOR_SHEME = ColorScheme._(0, _omitEnumNames ? '' : 'UNKNOWN_COLOR_SHEME');
  static const ColorScheme SEPIA = ColorScheme._(1, _omitEnumNames ? '' : 'SEPIA');
  static const ColorScheme BLACK_HOT = ColorScheme._(2, _omitEnumNames ? '' : 'BLACK_HOT');
  static const ColorScheme WHITE_HOT = ColorScheme._(3, _omitEnumNames ? '' : 'WHITE_HOT');

  static const $core.List<ColorScheme> values = <ColorScheme> [
    UNKNOWN_COLOR_SHEME,
    SEPIA,
    BLACK_HOT,
    WHITE_HOT,
  ];

  static final $core.Map<$core.int, ColorScheme> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ColorScheme? valueOf($core.int value) => _byValue[value];

  const ColorScheme._($core.int v, $core.String n) : super(v, n);
}

class AGCMode extends $pb.ProtobufEnum {
  static const AGCMode UNKNOWN_AGC_MODE = AGCMode._(0, _omitEnumNames ? '' : 'UNKNOWN_AGC_MODE');
  static const AGCMode AUTO_1 = AGCMode._(1, _omitEnumNames ? '' : 'AUTO_1');
  static const AGCMode AUTO_2 = AGCMode._(2, _omitEnumNames ? '' : 'AUTO_2');
  static const AGCMode AUTO_3 = AGCMode._(3, _omitEnumNames ? '' : 'AUTO_3');

  static const $core.List<AGCMode> values = <AGCMode> [
    UNKNOWN_AGC_MODE,
    AUTO_1,
    AUTO_2,
    AUTO_3,
  ];

  static final $core.Map<$core.int, AGCMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AGCMode? valueOf($core.int value) => _byValue[value];

  const AGCMode._($core.int v, $core.String n) : super(v, n);
}

class Zoom extends $pb.ProtobufEnum {
  static const Zoom UNKNOWN_ZOOM_LEVEL = Zoom._(0, _omitEnumNames ? '' : 'UNKNOWN_ZOOM_LEVEL');
  static const Zoom ZOOM_X1 = Zoom._(1, _omitEnumNames ? '' : 'ZOOM_X1');
  static const Zoom ZOOM_X2 = Zoom._(2, _omitEnumNames ? '' : 'ZOOM_X2');
  static const Zoom ZOOM_X3 = Zoom._(3, _omitEnumNames ? '' : 'ZOOM_X3');
  static const Zoom ZOOM_X4 = Zoom._(4, _omitEnumNames ? '' : 'ZOOM_X4');
  static const Zoom ZOOM_X6 = Zoom._(5, _omitEnumNames ? '' : 'ZOOM_X6');

  static const $core.List<Zoom> values = <Zoom> [
    UNKNOWN_ZOOM_LEVEL,
    ZOOM_X1,
    ZOOM_X2,
    ZOOM_X3,
    ZOOM_X4,
    ZOOM_X6,
  ];

  static final $core.Map<$core.int, Zoom> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Zoom? valueOf($core.int value) => _byValue[value];

  const Zoom._($core.int v, $core.String n) : super(v, n);
}

class ButtonEnum extends $pb.ProtobufEnum {
  static const ButtonEnum UNKNOWN_BUTTON = ButtonEnum._(0, _omitEnumNames ? '' : 'UNKNOWN_BUTTON');
  static const ButtonEnum MENU_SHORT = ButtonEnum._(1, _omitEnumNames ? '' : 'MENU_SHORT');
  static const ButtonEnum MENU_LONG = ButtonEnum._(2, _omitEnumNames ? '' : 'MENU_LONG');
  static const ButtonEnum UP_SHORT = ButtonEnum._(3, _omitEnumNames ? '' : 'UP_SHORT');
  static const ButtonEnum UP_LONG = ButtonEnum._(4, _omitEnumNames ? '' : 'UP_LONG');
  static const ButtonEnum DOWN_SHORT = ButtonEnum._(5, _omitEnumNames ? '' : 'DOWN_SHORT');
  static const ButtonEnum DOWN_LONG = ButtonEnum._(6, _omitEnumNames ? '' : 'DOWN_LONG');
  static const ButtonEnum LRF_SHORT = ButtonEnum._(7, _omitEnumNames ? '' : 'LRF_SHORT');
  static const ButtonEnum LRF_LONG = ButtonEnum._(8, _omitEnumNames ? '' : 'LRF_LONG');
  static const ButtonEnum REC_SHORT = ButtonEnum._(9, _omitEnumNames ? '' : 'REC_SHORT');
  static const ButtonEnum REC_LONG = ButtonEnum._(10, _omitEnumNames ? '' : 'REC_LONG');

  static const $core.List<ButtonEnum> values = <ButtonEnum> [
    UNKNOWN_BUTTON,
    MENU_SHORT,
    MENU_LONG,
    UP_SHORT,
    UP_LONG,
    DOWN_SHORT,
    DOWN_LONG,
    LRF_SHORT,
    LRF_LONG,
    REC_SHORT,
    REC_LONG,
  ];

  static final $core.Map<$core.int, ButtonEnum> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ButtonEnum? valueOf($core.int value) => _byValue[value];

  const ButtonEnum._($core.int v, $core.String n) : super(v, n);
}

class CMDDirect extends $pb.ProtobufEnum {
  static const CMDDirect UNKNOWN_CMD_DIRECTION = CMDDirect._(0, _omitEnumNames ? '' : 'UNKNOWN_CMD_DIRECTION');
  static const CMDDirect CALIBRATE_ACCEL_GYRO = CMDDirect._(1, _omitEnumNames ? '' : 'CALIBRATE_ACCEL_GYRO');
  static const CMDDirect LRF_MEASUREMENT = CMDDirect._(2, _omitEnumNames ? '' : 'LRF_MEASUREMENT');
  static const CMDDirect RESET_CM_CLICKS = CMDDirect._(3, _omitEnumNames ? '' : 'RESET_CM_CLICKS');
  static const CMDDirect TRIGGER_FFC = CMDDirect._(4, _omitEnumNames ? '' : 'TRIGGER_FFC');

  static const $core.List<CMDDirect> values = <CMDDirect> [
    UNKNOWN_CMD_DIRECTION,
    CALIBRATE_ACCEL_GYRO,
    LRF_MEASUREMENT,
    RESET_CM_CLICKS,
    TRIGGER_FFC,
  ];

  static final $core.Map<$core.int, CMDDirect> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CMDDirect? valueOf($core.int value) => _byValue[value];

  const CMDDirect._($core.int v, $core.String n) : super(v, n);
}

class DType extends $pb.ProtobufEnum {
  static const DType VALUE = DType._(0, _omitEnumNames ? '' : 'VALUE');
  static const DType INDEX = DType._(1, _omitEnumNames ? '' : 'INDEX');

  static const $core.List<DType> values = <DType> [
    VALUE,
    INDEX,
  ];

  static final $core.Map<$core.int, DType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DType? valueOf($core.int value) => _byValue[value];

  const DType._($core.int v, $core.String n) : super(v, n);
}

class GType extends $pb.ProtobufEnum {
  static const GType G1 = GType._(0, _omitEnumNames ? '' : 'G1');
  static const GType G7 = GType._(1, _omitEnumNames ? '' : 'G7');
  static const GType CUSTOM = GType._(2, _omitEnumNames ? '' : 'CUSTOM');

  static const $core.List<GType> values = <GType> [
    G1,
    G7,
    CUSTOM,
  ];

  static final $core.Map<$core.int, GType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GType? valueOf($core.int value) => _byValue[value];

  const GType._($core.int v, $core.String n) : super(v, n);
}

class TwistDir extends $pb.ProtobufEnum {
  static const TwistDir RIGHT = TwistDir._(0, _omitEnumNames ? '' : 'RIGHT');
  static const TwistDir LEFT = TwistDir._(1, _omitEnumNames ? '' : 'LEFT');

  static const $core.List<TwistDir> values = <TwistDir> [
    RIGHT,
    LEFT,
  ];

  static final $core.Map<$core.int, TwistDir> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TwistDir? valueOf($core.int value) => _byValue[value];

  const TwistDir._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
