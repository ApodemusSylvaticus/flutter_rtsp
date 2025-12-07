// This is a generated file - do not edit.
//
// Generated from archer_protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use okStatusCodeDescriptor instead')
const OkStatusCode$json = {
  '1': 'OkStatusCode',
  '2': [
    {'1': 'UNKNOWN_OK_STATUS', '2': 0},
    {'1': 'SUCCESS', '2': 1},
  ],
};

/// Descriptor for `OkStatusCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List okStatusCodeDescriptor = $convert.base64Decode(
    'CgxPa1N0YXR1c0NvZGUSFQoRVU5LTk9XTl9PS19TVEFUVVMQABILCgdTVUNDRVNTEAE=');

@$core.Deprecated('Use errorStatusCodeDescriptor instead')
const ErrorStatusCode$json = {
  '1': 'ErrorStatusCode',
  '2': [
    {'1': 'UNKNOWN_ERROR_STATUS', '2': 0},
    {'1': 'FAILURE', '2': 1},
    {'1': 'INVALID_DATA', '2': 2},
  ],
};

/// Descriptor for `ErrorStatusCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorStatusCodeDescriptor = $convert.base64Decode(
    'Cg9FcnJvclN0YXR1c0NvZGUSGAoUVU5LTk9XTl9FUlJPUl9TVEFUVVMQABILCgdGQUlMVVJFEA'
    'ESEAoMSU5WQUxJRF9EQVRBEAI=');

@$core.Deprecated('Use holdoffTypeDescriptor instead')
const HoldoffType$json = {
  '1': 'HoldoffType',
  '2': [
    {'1': 'UNDEFINED', '2': 0},
    {'1': 'MIL', '2': 1},
    {'1': 'MOA', '2': 2},
    {'1': 'CLICKS', '2': 3},
  ],
};

/// Descriptor for `HoldoffType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List holdoffTypeDescriptor = $convert.base64Decode(
    'CgtIb2xkb2ZmVHlwZRINCglVTkRFRklORUQQABIHCgNNSUwQARIHCgNNT0EQAhIKCgZDTElDS1'
    'MQAw==');

@$core.Deprecated('Use colorSchemeDescriptor instead')
const ColorScheme$json = {
  '1': 'ColorScheme',
  '2': [
    {'1': 'UNKNOWN_COLOR_SHEME', '2': 0},
    {'1': 'SEPIA', '2': 1},
    {'1': 'BLACK_HOT', '2': 2},
    {'1': 'WHITE_HOT', '2': 3},
  ],
};

/// Descriptor for `ColorScheme`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List colorSchemeDescriptor = $convert.base64Decode(
    'CgtDb2xvclNjaGVtZRIXChNVTktOT1dOX0NPTE9SX1NIRU1FEAASCQoFU0VQSUEQARINCglCTE'
    'FDS19IT1QQAhINCglXSElURV9IT1QQAw==');

@$core.Deprecated('Use aGCModeDescriptor instead')
const AGCMode$json = {
  '1': 'AGCMode',
  '2': [
    {'1': 'UNKNOWN_AGC_MODE', '2': 0},
    {'1': 'AUTO_1', '2': 1},
    {'1': 'AUTO_2', '2': 2},
    {'1': 'AUTO_3', '2': 3},
  ],
};

/// Descriptor for `AGCMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aGCModeDescriptor = $convert.base64Decode(
    'CgdBR0NNb2RlEhQKEFVOS05PV05fQUdDX01PREUQABIKCgZBVVRPXzEQARIKCgZBVVRPXzIQAh'
    'IKCgZBVVRPXzMQAw==');

@$core.Deprecated('Use zoomDescriptor instead')
const Zoom$json = {
  '1': 'Zoom',
  '2': [
    {'1': 'UNKNOWN_ZOOM_LEVEL', '2': 0},
    {'1': 'ZOOM_X1', '2': 1},
    {'1': 'ZOOM_X2', '2': 2},
    {'1': 'ZOOM_X3', '2': 3},
    {'1': 'ZOOM_X4', '2': 4},
    {'1': 'ZOOM_X6', '2': 5},
  ],
};

/// Descriptor for `Zoom`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List zoomDescriptor = $convert.base64Decode(
    'CgRab29tEhYKElVOS05PV05fWk9PTV9MRVZFTBAAEgsKB1pPT01fWDEQARILCgdaT09NX1gyEA'
    'ISCwoHWk9PTV9YMxADEgsKB1pPT01fWDQQBBILCgdaT09NX1g2EAU=');

@$core.Deprecated('Use buttonEnumDescriptor instead')
const ButtonEnum$json = {
  '1': 'ButtonEnum',
  '2': [
    {'1': 'UNKNOWN_BUTTON', '2': 0},
    {'1': 'MENU_SHORT', '2': 1},
    {'1': 'MENU_LONG', '2': 2},
    {'1': 'UP_SHORT', '2': 3},
    {'1': 'UP_LONG', '2': 4},
    {'1': 'DOWN_SHORT', '2': 5},
    {'1': 'DOWN_LONG', '2': 6},
    {'1': 'LRF_SHORT', '2': 7},
    {'1': 'LRF_LONG', '2': 8},
    {'1': 'REC_SHORT', '2': 9},
    {'1': 'REC_LONG', '2': 10},
  ],
};

/// Descriptor for `ButtonEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List buttonEnumDescriptor = $convert.base64Decode(
    'CgpCdXR0b25FbnVtEhIKDlVOS05PV05fQlVUVE9OEAASDgoKTUVOVV9TSE9SVBABEg0KCU1FTl'
    'VfTE9ORxACEgwKCFVQX1NIT1JUEAMSCwoHVVBfTE9ORxAEEg4KCkRPV05fU0hPUlQQBRINCglE'
    'T1dOX0xPTkcQBhINCglMUkZfU0hPUlQQBxIMCghMUkZfTE9ORxAIEg0KCVJFQ19TSE9SVBAJEg'
    'wKCFJFQ19MT05HEAo=');

@$core.Deprecated('Use cMDDirectDescriptor instead')
const CMDDirect$json = {
  '1': 'CMDDirect',
  '2': [
    {'1': 'UNKNOWN_CMD_DIRECTION', '2': 0},
    {'1': 'CALIBRATE_ACCEL_GYRO', '2': 1},
    {'1': 'LRF_MEASUREMENT', '2': 2},
    {'1': 'RESET_CM_CLICKS', '2': 3},
    {'1': 'TRIGGER_FFC', '2': 4},
  ],
};

/// Descriptor for `CMDDirect`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cMDDirectDescriptor = $convert.base64Decode(
    'CglDTUREaXJlY3QSGQoVVU5LTk9XTl9DTURfRElSRUNUSU9OEAASGAoUQ0FMSUJSQVRFX0FDQ0'
    'VMX0dZUk8QARITCg9MUkZfTUVBU1VSRU1FTlQQAhITCg9SRVNFVF9DTV9DTElDS1MQAxIPCgtU'
    'UklHR0VSX0ZGQxAE');

@$core.Deprecated('Use dTypeDescriptor instead')
const DType$json = {
  '1': 'DType',
  '2': [
    {'1': 'VALUE', '2': 0},
    {'1': 'INDEX', '2': 1},
  ],
};

/// Descriptor for `DType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dTypeDescriptor =
    $convert.base64Decode('CgVEVHlwZRIJCgVWQUxVRRAAEgkKBUlOREVYEAE=');

@$core.Deprecated('Use gTypeDescriptor instead')
const GType$json = {
  '1': 'GType',
  '2': [
    {'1': 'G1', '2': 0},
    {'1': 'G7', '2': 1},
    {'1': 'CUSTOM', '2': 2},
  ],
};

/// Descriptor for `GType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List gTypeDescriptor =
    $convert.base64Decode('CgVHVHlwZRIGCgJHMRAAEgYKAkc3EAESCgoGQ1VTVE9NEAI=');

@$core.Deprecated('Use twistDirDescriptor instead')
const TwistDir$json = {
  '1': 'TwistDir',
  '2': [
    {'1': 'RIGHT', '2': 0},
    {'1': 'LEFT', '2': 1},
  ],
};

/// Descriptor for `TwistDir`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List twistDirDescriptor =
    $convert.base64Decode('CghUd2lzdERpchIJCgVSSUdIVBAAEggKBExFRlQQAQ==');

@$core.Deprecated('Use hostPayloadDescriptor instead')
const HostPayload$json = {
  '1': 'HostPayload',
  '2': [
    {
      '1': 'profile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.HostProfile',
      '10': 'profile'
    },
    {
      '1': 'devStatus',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.HostDevStatus',
      '10': 'devStatus'
    },
    {
      '1': 'response',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.CommandResponse',
      '10': 'response'
    },
    {
      '1': 'reticles',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.Reticles',
      '10': 'reticles'
    },
    {
      '1': 'allProfiles',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.FullProfileData',
      '10': 'allProfiles'
    },
  ],
};

/// Descriptor for `HostPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hostPayloadDescriptor = $convert.base64Decode(
    'CgtIb3N0UGF5bG9hZBI2Cgdwcm9maWxlGAEgASgLMhwuYXJjaGVyX3Byb3RvY29sLkhvc3RQcm'
    '9maWxlUgdwcm9maWxlEjwKCWRldlN0YXR1cxgCIAEoCzIeLmFyY2hlcl9wcm90b2NvbC5Ib3N0'
    'RGV2U3RhdHVzUglkZXZTdGF0dXMSPAoIcmVzcG9uc2UYAyABKAsyIC5hcmNoZXJfcHJvdG9jb2'
    'wuQ29tbWFuZFJlc3BvbnNlUghyZXNwb25zZRI1CghyZXRpY2xlcxgEIAEoCzIZLmFyY2hlcl9w'
    'cm90b2NvbC5SZXRpY2xlc1IIcmV0aWNsZXMSQgoLYWxsUHJvZmlsZXMYBSABKAsyIC5hcmNoZX'
    'JfcHJvdG9jb2wuRnVsbFByb2ZpbGVEYXRhUgthbGxQcm9maWxlcw==');

@$core.Deprecated('Use clientPayloadDescriptor instead')
const ClientPayload$json = {
  '1': 'ClientPayload',
  '2': [
    {
      '1': 'devStatus',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.ClientDevStatus',
      '10': 'devStatus'
    },
    {
      '1': 'command',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.Command',
      '10': 'command'
    },
    {
      '1': 'response',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.CommandResponse',
      '10': 'response'
    },
  ],
  '9': [
    {'1': 1, '2': 2},
  ],
  '10': ['profile'],
};

/// Descriptor for `ClientPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientPayloadDescriptor = $convert.base64Decode(
    'Cg1DbGllbnRQYXlsb2FkEj4KCWRldlN0YXR1cxgCIAEoCzIgLmFyY2hlcl9wcm90b2NvbC5DbG'
    'llbnREZXZTdGF0dXNSCWRldlN0YXR1cxIyCgdjb21tYW5kGAMgASgLMhguYXJjaGVyX3Byb3Rv'
    'Y29sLkNvbW1hbmRSB2NvbW1hbmQSPAoIcmVzcG9uc2UYBCABKAsyIC5hcmNoZXJfcHJvdG9jb2'
    'wuQ29tbWFuZFJlc3BvbnNlUghyZXNwb25zZUoECAEQAlIHcHJvZmlsZQ==');

@$core.Deprecated('Use commandResponseDescriptor instead')
const CommandResponse$json = {
  '1': 'CommandResponse',
  '2': [
    {
      '1': 'statusOk',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.StatusOk',
      '9': 0,
      '10': 'statusOk'
    },
    {
      '1': 'statusErr',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.StatusError',
      '9': 0,
      '10': 'statusErr'
    },
  ],
  '8': [
    {'1': 'oneofCommandResponse'},
  ],
};

/// Descriptor for `CommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResponseDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kUmVzcG9uc2USNwoIc3RhdHVzT2sYASABKAsyGS5hcmNoZXJfcHJvdG9jb2wuU3'
    'RhdHVzT2tIAFIIc3RhdHVzT2sSPAoJc3RhdHVzRXJyGAIgASgLMhwuYXJjaGVyX3Byb3RvY29s'
    'LlN0YXR1c0Vycm9ySABSCXN0YXR1c0VyckIWChRvbmVvZkNvbW1hbmRSZXNwb25zZQ==');

@$core.Deprecated('Use commandDescriptor instead')
const Command$json = {
  '1': 'Command',
  '2': [
    {
      '1': 'setZoom',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetZoomLevel',
      '9': 0,
      '10': 'setZoom'
    },
    {
      '1': 'setPallette',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetColorScheme',
      '9': 0,
      '10': 'setPallette'
    },
    {
      '1': 'setAgc',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetAgcMode',
      '9': 0,
      '10': 'setAgc'
    },
    {
      '1': 'setDst',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetDistance',
      '9': 0,
      '10': 'setDst'
    },
    {
      '1': 'setHoldoff',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetHoldoff',
      '9': 0,
      '10': 'setHoldoff'
    },
    {
      '1': 'setZeroing',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetZeroing',
      '9': 0,
      '10': 'setZeroing'
    },
    {
      '1': 'setMagOffset',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetCompassOffset',
      '9': 0,
      '10': 'setMagOffset'
    },
    {
      '1': 'setAirTC',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetAirTemp',
      '9': 0,
      '10': 'setAirTC'
    },
    {
      '1': 'setAirHum',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetAirHumidity',
      '9': 0,
      '10': 'setAirHum'
    },
    {
      '1': 'setAirPress',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetAirPressure',
      '9': 0,
      '10': 'setAirPress'
    },
    {
      '1': 'setPowderTemp',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetPowderTemp',
      '9': 0,
      '10': 'setPowderTemp'
    },
    {
      '1': 'setWind',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.SetWind',
      '9': 0,
      '10': 'setWind'
    },
    {
      '1': 'buttonPress',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.ButtonPress',
      '9': 0,
      '10': 'buttonPress'
    },
    {
      '1': 'cmdTrigger',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.TriggerCmd',
      '9': 0,
      '10': 'cmdTrigger'
    },
    {
      '1': 'getHostDevStatus',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.GetHostDevStatus',
      '9': 0,
      '10': 'getHostDevStatus'
    },
    {
      '1': 'getHostProfile',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.GetHostProfile',
      '9': 0,
      '10': 'getHostProfile'
    },
    {
      '1': 'getAllProfiles',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.GetProfiles',
      '9': 0,
      '10': 'getAllProfiles'
    },
    {
      '1': 'updateAllProfiles',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.UpdateProfiles',
      '9': 0,
      '10': 'updateAllProfiles'
    },
    {
      '1': 'getReticles',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.GetReticles',
      '9': 0,
      '10': 'getReticles'
    },
    {
      '1': 'updateReticles',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.UpdateReticles',
      '9': 0,
      '10': 'updateReticles'
    },
  ],
  '8': [
    {'1': 'oneofCommand'},
  ],
};

/// Descriptor for `Command`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandDescriptor = $convert.base64Decode(
    'CgdDb21tYW5kEjkKB3NldFpvb20YASABKAsyHS5hcmNoZXJfcHJvdG9jb2wuU2V0Wm9vbUxldm'
    'VsSABSB3NldFpvb20SQwoLc2V0UGFsbGV0dGUYAiABKAsyHy5hcmNoZXJfcHJvdG9jb2wuU2V0'
    'Q29sb3JTY2hlbWVIAFILc2V0UGFsbGV0dGUSNQoGc2V0QWdjGAMgASgLMhsuYXJjaGVyX3Byb3'
    'RvY29sLlNldEFnY01vZGVIAFIGc2V0QWdjEjYKBnNldERzdBgEIAEoCzIcLmFyY2hlcl9wcm90'
    'b2NvbC5TZXREaXN0YW5jZUgAUgZzZXREc3QSPQoKc2V0SG9sZG9mZhgFIAEoCzIbLmFyY2hlcl'
    '9wcm90b2NvbC5TZXRIb2xkb2ZmSABSCnNldEhvbGRvZmYSPQoKc2V0WmVyb2luZxgGIAEoCzIb'
    'LmFyY2hlcl9wcm90b2NvbC5TZXRaZXJvaW5nSABSCnNldFplcm9pbmcSRwoMc2V0TWFnT2Zmc2'
    'V0GAcgASgLMiEuYXJjaGVyX3Byb3RvY29sLlNldENvbXBhc3NPZmZzZXRIAFIMc2V0TWFnT2Zm'
    'c2V0EjkKCHNldEFpclRDGAggASgLMhsuYXJjaGVyX3Byb3RvY29sLlNldEFpclRlbXBIAFIIc2'
    'V0QWlyVEMSPwoJc2V0QWlySHVtGAkgASgLMh8uYXJjaGVyX3Byb3RvY29sLlNldEFpckh1bWlk'
    'aXR5SABSCXNldEFpckh1bRJDCgtzZXRBaXJQcmVzcxgKIAEoCzIfLmFyY2hlcl9wcm90b2NvbC'
    '5TZXRBaXJQcmVzc3VyZUgAUgtzZXRBaXJQcmVzcxJGCg1zZXRQb3dkZXJUZW1wGAsgASgLMh4u'
    'YXJjaGVyX3Byb3RvY29sLlNldFBvd2RlclRlbXBIAFINc2V0UG93ZGVyVGVtcBI0CgdzZXRXaW'
    '5kGAwgASgLMhguYXJjaGVyX3Byb3RvY29sLlNldFdpbmRIAFIHc2V0V2luZBJACgtidXR0b25Q'
    'cmVzcxgNIAEoCzIcLmFyY2hlcl9wcm90b2NvbC5CdXR0b25QcmVzc0gAUgtidXR0b25QcmVzcx'
    'I9CgpjbWRUcmlnZ2VyGA4gASgLMhsuYXJjaGVyX3Byb3RvY29sLlRyaWdnZXJDbWRIAFIKY21k'
    'VHJpZ2dlchJPChBnZXRIb3N0RGV2U3RhdHVzGA8gASgLMiEuYXJjaGVyX3Byb3RvY29sLkdldE'
    'hvc3REZXZTdGF0dXNIAFIQZ2V0SG9zdERldlN0YXR1cxJJCg5nZXRIb3N0UHJvZmlsZRgQIAEo'
    'CzIfLmFyY2hlcl9wcm90b2NvbC5HZXRIb3N0UHJvZmlsZUgAUg5nZXRIb3N0UHJvZmlsZRJGCg'
    '5nZXRBbGxQcm9maWxlcxgRIAEoCzIcLmFyY2hlcl9wcm90b2NvbC5HZXRQcm9maWxlc0gAUg5n'
    'ZXRBbGxQcm9maWxlcxJPChF1cGRhdGVBbGxQcm9maWxlcxgSIAEoCzIfLmFyY2hlcl9wcm90b2'
    'NvbC5VcGRhdGVQcm9maWxlc0gAUhF1cGRhdGVBbGxQcm9maWxlcxJACgtnZXRSZXRpY2xlcxgT'
    'IAEoCzIcLmFyY2hlcl9wcm90b2NvbC5HZXRSZXRpY2xlc0gAUgtnZXRSZXRpY2xlcxJJCg51cG'
    'RhdGVSZXRpY2xlcxgUIAEoCzIfLmFyY2hlcl9wcm90b2NvbC5VcGRhdGVSZXRpY2xlc0gAUg51'
    'cGRhdGVSZXRpY2xlc0IOCgxvbmVvZkNvbW1hbmQ=');

@$core.Deprecated('Use getProfilesDescriptor instead')
const GetProfiles$json = {
  '1': 'GetProfiles',
};

/// Descriptor for `GetProfiles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfilesDescriptor =
    $convert.base64Decode('CgtHZXRQcm9maWxlcw==');

@$core.Deprecated('Use getReticlesDescriptor instead')
const GetReticles$json = {
  '1': 'GetReticles',
};

/// Descriptor for `GetReticles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReticlesDescriptor =
    $convert.base64Decode('CgtHZXRSZXRpY2xlcw==');

@$core.Deprecated('Use updateReticlesDescriptor instead')
const UpdateReticles$json = {
  '1': 'UpdateReticles',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.Reticles',
      '10': 'data'
    },
  ],
};

/// Descriptor for `UpdateReticles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateReticlesDescriptor = $convert.base64Decode(
    'Cg5VcGRhdGVSZXRpY2xlcxItCgRkYXRhGAEgASgLMhkuYXJjaGVyX3Byb3RvY29sLlJldGljbG'
    'VzUgRkYXRh');

@$core.Deprecated('Use updateProfilesDescriptor instead')
const UpdateProfiles$json = {
  '1': 'UpdateProfiles',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.FullProfileData',
      '10': 'data'
    },
  ],
};

/// Descriptor for `UpdateProfiles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfilesDescriptor = $convert.base64Decode(
    'Cg5VcGRhdGVQcm9maWxlcxI0CgRkYXRhGAEgASgLMiAuYXJjaGVyX3Byb3RvY29sLkZ1bGxQcm'
    '9maWxlRGF0YVIEZGF0YQ==');

@$core.Deprecated('Use statusOkDescriptor instead')
const StatusOk$json = {
  '1': 'StatusOk',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.OkStatusCode',
      '10': 'code'
    },
  ],
};

/// Descriptor for `StatusOk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusOkDescriptor = $convert.base64Decode(
    'CghTdGF0dXNPaxIxCgRjb2RlGAEgASgOMh0uYXJjaGVyX3Byb3RvY29sLk9rU3RhdHVzQ29kZV'
    'IEY29kZQ==');

@$core.Deprecated('Use statusErrorDescriptor instead')
const StatusError$json = {
  '1': 'StatusError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.ErrorStatusCode',
      '10': 'code'
    },
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `StatusError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusErrorDescriptor = $convert.base64Decode(
    'CgtTdGF0dXNFcnJvchI0CgRjb2RlGAEgASgOMiAuYXJjaGVyX3Byb3RvY29sLkVycm9yU3RhdH'
    'VzQ29kZVIEY29kZRISCgR0ZXh0GAIgASgJUgR0ZXh0');

@$core.Deprecated('Use setZoomLevelDescriptor instead')
const SetZoomLevel$json = {
  '1': 'SetZoomLevel',
  '2': [
    {
      '1': 'zoomLevel',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.Zoom',
      '10': 'zoomLevel'
    },
  ],
};

/// Descriptor for `SetZoomLevel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setZoomLevelDescriptor = $convert.base64Decode(
    'CgxTZXRab29tTGV2ZWwSMwoJem9vbUxldmVsGAEgASgOMhUuYXJjaGVyX3Byb3RvY29sLlpvb2'
    '1SCXpvb21MZXZlbA==');

@$core.Deprecated('Use setColorSchemeDescriptor instead')
const SetColorScheme$json = {
  '1': 'SetColorScheme',
  '2': [
    {
      '1': 'scheme',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.ColorScheme',
      '10': 'scheme'
    },
  ],
};

/// Descriptor for `SetColorScheme`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setColorSchemeDescriptor = $convert.base64Decode(
    'Cg5TZXRDb2xvclNjaGVtZRI0CgZzY2hlbWUYASABKA4yHC5hcmNoZXJfcHJvdG9jb2wuQ29sb3'
    'JTY2hlbWVSBnNjaGVtZQ==');

@$core.Deprecated('Use getHostDevStatusDescriptor instead')
const GetHostDevStatus$json = {
  '1': 'GetHostDevStatus',
};

/// Descriptor for `GetHostDevStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHostDevStatusDescriptor =
    $convert.base64Decode('ChBHZXRIb3N0RGV2U3RhdHVz');

@$core.Deprecated('Use getHostProfileDescriptor instead')
const GetHostProfile$json = {
  '1': 'GetHostProfile',
};

/// Descriptor for `GetHostProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHostProfileDescriptor =
    $convert.base64Decode('Cg5HZXRIb3N0UHJvZmlsZQ==');

@$core.Deprecated('Use setAirTempDescriptor instead')
const SetAirTemp$json = {
  '1': 'SetAirTemp',
  '2': [
    {'1': 'temperature', '3': 1, '4': 1, '5': 5, '10': 'temperature'},
  ],
};

/// Descriptor for `SetAirTemp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAirTempDescriptor = $convert.base64Decode(
    'CgpTZXRBaXJUZW1wEiAKC3RlbXBlcmF0dXJlGAEgASgFUgt0ZW1wZXJhdHVyZQ==');

@$core.Deprecated('Use setPowderTempDescriptor instead')
const SetPowderTemp$json = {
  '1': 'SetPowderTemp',
  '2': [
    {'1': 'temperature', '3': 1, '4': 1, '5': 5, '10': 'temperature'},
  ],
};

/// Descriptor for `SetPowderTemp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPowderTempDescriptor = $convert.base64Decode(
    'Cg1TZXRQb3dkZXJUZW1wEiAKC3RlbXBlcmF0dXJlGAEgASgFUgt0ZW1wZXJhdHVyZQ==');

@$core.Deprecated('Use setAirHumidityDescriptor instead')
const SetAirHumidity$json = {
  '1': 'SetAirHumidity',
  '2': [
    {'1': 'humidity', '3': 1, '4': 1, '5': 5, '10': 'humidity'},
  ],
};

/// Descriptor for `SetAirHumidity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAirHumidityDescriptor = $convert.base64Decode(
    'Cg5TZXRBaXJIdW1pZGl0eRIaCghodW1pZGl0eRgBIAEoBVIIaHVtaWRpdHk=');

@$core.Deprecated('Use setAirPressureDescriptor instead')
const SetAirPressure$json = {
  '1': 'SetAirPressure',
  '2': [
    {'1': 'pressure', '3': 1, '4': 1, '5': 5, '10': 'pressure'},
  ],
};

/// Descriptor for `SetAirPressure`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAirPressureDescriptor = $convert.base64Decode(
    'Cg5TZXRBaXJQcmVzc3VyZRIaCghwcmVzc3VyZRgBIAEoBVIIcHJlc3N1cmU=');

@$core.Deprecated('Use setWindDescriptor instead')
const SetWind$json = {
  '1': 'SetWind',
  '2': [
    {'1': 'direction', '3': 1, '4': 1, '5': 5, '10': 'direction'},
    {'1': 'speed', '3': 2, '4': 1, '5': 5, '10': 'speed'},
  ],
};

/// Descriptor for `SetWind`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setWindDescriptor = $convert.base64Decode(
    'CgdTZXRXaW5kEhwKCWRpcmVjdGlvbhgBIAEoBVIJZGlyZWN0aW9uEhQKBXNwZWVkGAIgASgFUg'
    'VzcGVlZA==');

@$core.Deprecated('Use setDistanceDescriptor instead')
const SetDistance$json = {
  '1': 'SetDistance',
  '2': [
    {'1': 'distance', '3': 1, '4': 1, '5': 5, '10': 'distance'},
  ],
};

/// Descriptor for `SetDistance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDistanceDescriptor = $convert
    .base64Decode('CgtTZXREaXN0YW5jZRIaCghkaXN0YW5jZRgBIAEoBVIIZGlzdGFuY2U=');

@$core.Deprecated('Use setAgcModeDescriptor instead')
const SetAgcMode$json = {
  '1': 'SetAgcMode',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.AGCMode',
      '10': 'mode'
    },
  ],
};

/// Descriptor for `SetAgcMode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAgcModeDescriptor = $convert.base64Decode(
    'CgpTZXRBZ2NNb2RlEiwKBG1vZGUYASABKA4yGC5hcmNoZXJfcHJvdG9jb2wuQUdDTW9kZVIEbW'
    '9kZQ==');

@$core.Deprecated('Use setCompassOffsetDescriptor instead')
const SetCompassOffset$json = {
  '1': 'SetCompassOffset',
  '2': [
    {'1': 'offset', '3': 1, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `SetCompassOffset`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCompassOffsetDescriptor = $convert
    .base64Decode('ChBTZXRDb21wYXNzT2Zmc2V0EhYKBm9mZnNldBgBIAEoBVIGb2Zmc2V0');

@$core.Deprecated('Use setHoldoffDescriptor instead')
const SetHoldoff$json = {
  '1': 'SetHoldoff',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 5, '10': 'y'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.HoldoffType',
      '10': 'type'
    },
  ],
};

/// Descriptor for `SetHoldoff`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setHoldoffDescriptor = $convert.base64Decode(
    'CgpTZXRIb2xkb2ZmEgwKAXgYASABKAVSAXgSDAoBeRgCIAEoBVIBeRIwCgR0eXBlGAMgASgOMh'
    'wuYXJjaGVyX3Byb3RvY29sLkhvbGRvZmZUeXBlUgR0eXBl');

@$core.Deprecated('Use buttonPressDescriptor instead')
const ButtonPress$json = {
  '1': 'ButtonPress',
  '2': [
    {
      '1': 'buttonPressed',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.ButtonEnum',
      '10': 'buttonPressed'
    },
  ],
};

/// Descriptor for `ButtonPress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonPressDescriptor = $convert.base64Decode(
    'CgtCdXR0b25QcmVzcxJBCg1idXR0b25QcmVzc2VkGAEgASgOMhsuYXJjaGVyX3Byb3RvY29sLk'
    'J1dHRvbkVudW1SDWJ1dHRvblByZXNzZWQ=');

@$core.Deprecated('Use triggerCmdDescriptor instead')
const TriggerCmd$json = {
  '1': 'TriggerCmd',
  '2': [
    {
      '1': 'cmd',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.CMDDirect',
      '10': 'cmd'
    },
  ],
};

/// Descriptor for `TriggerCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List triggerCmdDescriptor = $convert.base64Decode(
    'CgpUcmlnZ2VyQ21kEiwKA2NtZBgBIAEoDjIaLmFyY2hlcl9wcm90b2NvbC5DTUREaXJlY3RSA2'
    'NtZA==');

@$core.Deprecated('Use setZeroingDescriptor instead')
const SetZeroing$json = {
  '1': 'SetZeroing',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 5, '10': 'y'},
  ],
};

/// Descriptor for `SetZeroing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setZeroingDescriptor = $convert
    .base64Decode('CgpTZXRaZXJvaW5nEgwKAXgYASABKAVSAXgSDAoBeRgCIAEoBVIBeQ==');

@$core.Deprecated('Use hostDevStatusDescriptor instead')
const HostDevStatus$json = {
  '1': 'HostDevStatus',
  '2': [
    {'1': 'charge', '3': 1, '4': 1, '5': 5, '10': 'charge'},
    {
      '1': 'zoom',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.Zoom',
      '10': 'zoom'
    },
    {'1': 'airTemp', '3': 3, '4': 1, '5': 5, '10': 'airTemp'},
    {'1': 'airHum', '3': 4, '4': 1, '5': 5, '10': 'airHum'},
    {'1': 'airPress', '3': 5, '4': 1, '5': 5, '10': 'airPress'},
    {'1': 'powderTemp', '3': 6, '4': 1, '5': 5, '10': 'powderTemp'},
    {'1': 'windDir', '3': 7, '4': 1, '5': 5, '10': 'windDir'},
    {'1': 'windSpeed', '3': 8, '4': 1, '5': 5, '10': 'windSpeed'},
    {'1': 'pitch', '3': 9, '4': 1, '5': 5, '10': 'pitch'},
    {'1': 'cant', '3': 10, '4': 1, '5': 5, '10': 'cant'},
    {'1': 'distance', '3': 11, '4': 1, '5': 5, '10': 'distance'},
    {'1': 'currentProfile', '3': 12, '4': 1, '5': 5, '10': 'currentProfile'},
    {
      '1': 'colorScheme',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.ColorScheme',
      '10': 'colorScheme'
    },
    {
      '1': 'modAGC',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.AGCMode',
      '10': 'modAGC'
    },
    {
      '1': 'maxZoom',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.Zoom',
      '10': 'maxZoom'
    },
  ],
};

/// Descriptor for `HostDevStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hostDevStatusDescriptor = $convert.base64Decode(
    'Cg1Ib3N0RGV2U3RhdHVzEhYKBmNoYXJnZRgBIAEoBVIGY2hhcmdlEikKBHpvb20YAiABKA4yFS'
    '5hcmNoZXJfcHJvdG9jb2wuWm9vbVIEem9vbRIYCgdhaXJUZW1wGAMgASgFUgdhaXJUZW1wEhYK'
    'BmFpckh1bRgEIAEoBVIGYWlySHVtEhoKCGFpclByZXNzGAUgASgFUghhaXJQcmVzcxIeCgpwb3'
    'dkZXJUZW1wGAYgASgFUgpwb3dkZXJUZW1wEhgKB3dpbmREaXIYByABKAVSB3dpbmREaXISHAoJ'
    'd2luZFNwZWVkGAggASgFUgl3aW5kU3BlZWQSFAoFcGl0Y2gYCSABKAVSBXBpdGNoEhIKBGNhbn'
    'QYCiABKAVSBGNhbnQSGgoIZGlzdGFuY2UYCyABKAVSCGRpc3RhbmNlEiYKDmN1cnJlbnRQcm9m'
    'aWxlGAwgASgFUg5jdXJyZW50UHJvZmlsZRI+Cgtjb2xvclNjaGVtZRgNIAEoDjIcLmFyY2hlcl'
    '9wcm90b2NvbC5Db2xvclNjaGVtZVILY29sb3JTY2hlbWUSMAoGbW9kQUdDGA4gASgOMhguYXJj'
    'aGVyX3Byb3RvY29sLkFHQ01vZGVSBm1vZEFHQxIvCgdtYXhab29tGA8gASgOMhUuYXJjaGVyX3'
    'Byb3RvY29sLlpvb21SB21heFpvb20=');

@$core.Deprecated('Use clientDevStatusDescriptor instead')
const ClientDevStatus$json = {
  '1': 'ClientDevStatus',
};

/// Descriptor for `ClientDevStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDevStatusDescriptor =
    $convert.base64Decode('Cg9DbGllbnREZXZTdGF0dXM=');

@$core.Deprecated('Use coefRowDescriptor instead')
const CoefRow$json = {
  '1': 'CoefRow',
  '2': [
    {'1': 'bc_cd', '3': 1, '4': 1, '5': 5, '10': 'bcCd'},
    {'1': 'mv', '3': 2, '4': 1, '5': 5, '10': 'mv'},
  ],
};

/// Descriptor for `CoefRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coefRowDescriptor = $convert.base64Decode(
    'CgdDb2VmUm93EhMKBWJjX2NkGAEgASgFUgRiY0NkEg4KAm12GAIgASgFUgJtdg==');

@$core.Deprecated('Use swPosDescriptor instead')
const SwPos$json = {
  '1': 'SwPos',
  '2': [
    {'1': 'c_idx', '3': 1, '4': 1, '5': 5, '10': 'cIdx'},
    {'1': 'reticle_idx', '3': 2, '4': 1, '5': 5, '10': 'reticleIdx'},
    {'1': 'zoom', '3': 3, '4': 1, '5': 5, '10': 'zoom'},
    {'1': 'distance', '3': 4, '4': 1, '5': 5, '10': 'distance'},
    {
      '1': 'distance_from',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.DType',
      '10': 'distanceFrom'
    },
  ],
};

/// Descriptor for `SwPos`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List swPosDescriptor = $convert.base64Decode(
    'CgVTd1BvcxITCgVjX2lkeBgBIAEoBVIEY0lkeBIfCgtyZXRpY2xlX2lkeBgCIAEoBVIKcmV0aW'
    'NsZUlkeBISCgR6b29tGAMgASgFUgR6b29tEhoKCGRpc3RhbmNlGAQgASgFUghkaXN0YW5jZRI7'
    'Cg1kaXN0YW5jZV9mcm9tGAUgASgOMhYuYXJjaGVyX3Byb3RvY29sLkRUeXBlUgxkaXN0YW5jZU'
    'Zyb20=');

@$core.Deprecated('Use hostProfileDescriptor instead')
const HostProfile$json = {
  '1': 'HostProfile',
  '2': [
    {'1': 'profile_name', '3': 1, '4': 1, '5': 9, '10': 'profileName'},
    {'1': 'cartridge_name', '3': 2, '4': 1, '5': 9, '10': 'cartridgeName'},
    {'1': 'bullet_name', '3': 3, '4': 1, '5': 9, '10': 'bulletName'},
    {'1': 'short_name_top', '3': 4, '4': 1, '5': 9, '10': 'shortNameTop'},
    {'1': 'short_name_bot', '3': 5, '4': 1, '5': 9, '10': 'shortNameBot'},
    {'1': 'user_note', '3': 6, '4': 1, '5': 9, '10': 'userNote'},
    {'1': 'zero_x', '3': 7, '4': 1, '5': 5, '10': 'zeroX'},
    {'1': 'zero_y', '3': 8, '4': 1, '5': 5, '10': 'zeroY'},
    {'1': 'sc_height', '3': 9, '4': 1, '5': 5, '10': 'scHeight'},
    {'1': 'r_twist', '3': 10, '4': 1, '5': 5, '10': 'rTwist'},
    {
      '1': 'c_muzzle_velocity',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'cMuzzleVelocity'
    },
    {
      '1': 'c_zero_temperature',
      '3': 12,
      '4': 1,
      '5': 5,
      '10': 'cZeroTemperature'
    },
    {'1': 'c_t_coeff', '3': 13, '4': 1, '5': 5, '10': 'cTCoeff'},
    {
      '1': 'c_zero_distance_idx',
      '3': 14,
      '4': 1,
      '5': 5,
      '10': 'cZeroDistanceIdx'
    },
    {
      '1': 'c_zero_air_temperature',
      '3': 15,
      '4': 1,
      '5': 5,
      '10': 'cZeroAirTemperature'
    },
    {
      '1': 'c_zero_air_pressure',
      '3': 16,
      '4': 1,
      '5': 5,
      '10': 'cZeroAirPressure'
    },
    {
      '1': 'c_zero_air_humidity',
      '3': 17,
      '4': 1,
      '5': 5,
      '10': 'cZeroAirHumidity'
    },
    {'1': 'c_zero_w_pitch', '3': 18, '4': 1, '5': 5, '10': 'cZeroWPitch'},
    {
      '1': 'c_zero_p_temperature',
      '3': 19,
      '4': 1,
      '5': 5,
      '10': 'cZeroPTemperature'
    },
    {'1': 'b_diameter', '3': 20, '4': 1, '5': 5, '10': 'bDiameter'},
    {'1': 'b_weight', '3': 21, '4': 1, '5': 5, '10': 'bWeight'},
    {'1': 'b_length', '3': 22, '4': 1, '5': 5, '10': 'bLength'},
    {
      '1': 'twist_dir',
      '3': 23,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.TwistDir',
      '10': 'twistDir'
    },
    {
      '1': 'bc_type',
      '3': 24,
      '4': 1,
      '5': 14,
      '6': '.archer_protocol.GType',
      '10': 'bcType'
    },
    {
      '1': 'switches',
      '3': 25,
      '4': 3,
      '5': 11,
      '6': '.archer_protocol.SwPos',
      '10': 'switches'
    },
    {'1': 'distances', '3': 26, '4': 3, '5': 5, '10': 'distances'},
    {
      '1': 'coef_rows',
      '3': 27,
      '4': 3,
      '5': 11,
      '6': '.archer_protocol.CoefRow',
      '10': 'coefRows'
    },
    {'1': 'caliber', '3': 28, '4': 1, '5': 9, '10': 'caliber'},
    {'1': 'device_uuid', '3': 29, '4': 1, '5': 9, '10': 'deviceUuid'},
  ],
};

/// Descriptor for `HostProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hostProfileDescriptor = $convert.base64Decode(
    'CgtIb3N0UHJvZmlsZRIhCgxwcm9maWxlX25hbWUYASABKAlSC3Byb2ZpbGVOYW1lEiUKDmNhcn'
    'RyaWRnZV9uYW1lGAIgASgJUg1jYXJ0cmlkZ2VOYW1lEh8KC2J1bGxldF9uYW1lGAMgASgJUgpi'
    'dWxsZXROYW1lEiQKDnNob3J0X25hbWVfdG9wGAQgASgJUgxzaG9ydE5hbWVUb3ASJAoOc2hvcn'
    'RfbmFtZV9ib3QYBSABKAlSDHNob3J0TmFtZUJvdBIbCgl1c2VyX25vdGUYBiABKAlSCHVzZXJO'
    'b3RlEhUKBnplcm9feBgHIAEoBVIFemVyb1gSFQoGemVyb195GAggASgFUgV6ZXJvWRIbCglzY1'
    '9oZWlnaHQYCSABKAVSCHNjSGVpZ2h0EhcKB3JfdHdpc3QYCiABKAVSBnJUd2lzdBIqChFjX211'
    'enpsZV92ZWxvY2l0eRgLIAEoBVIPY011enpsZVZlbG9jaXR5EiwKEmNfemVyb190ZW1wZXJhdH'
    'VyZRgMIAEoBVIQY1plcm9UZW1wZXJhdHVyZRIaCgljX3RfY29lZmYYDSABKAVSB2NUQ29lZmYS'
    'LQoTY196ZXJvX2Rpc3RhbmNlX2lkeBgOIAEoBVIQY1plcm9EaXN0YW5jZUlkeBIzChZjX3plcm'
    '9fYWlyX3RlbXBlcmF0dXJlGA8gASgFUhNjWmVyb0FpclRlbXBlcmF0dXJlEi0KE2NfemVyb19h'
    'aXJfcHJlc3N1cmUYECABKAVSEGNaZXJvQWlyUHJlc3N1cmUSLQoTY196ZXJvX2Fpcl9odW1pZG'
    'l0eRgRIAEoBVIQY1plcm9BaXJIdW1pZGl0eRIjCg5jX3plcm9fd19waXRjaBgSIAEoBVILY1pl'
    'cm9XUGl0Y2gSLwoUY196ZXJvX3BfdGVtcGVyYXR1cmUYEyABKAVSEWNaZXJvUFRlbXBlcmF0dX'
    'JlEh0KCmJfZGlhbWV0ZXIYFCABKAVSCWJEaWFtZXRlchIZCghiX3dlaWdodBgVIAEoBVIHYldl'
    'aWdodBIZCghiX2xlbmd0aBgWIAEoBVIHYkxlbmd0aBI2Cgl0d2lzdF9kaXIYFyABKA4yGS5hcm'
    'NoZXJfcHJvdG9jb2wuVHdpc3REaXJSCHR3aXN0RGlyEi8KB2JjX3R5cGUYGCABKA4yFi5hcmNo'
    'ZXJfcHJvdG9jb2wuR1R5cGVSBmJjVHlwZRIyCghzd2l0Y2hlcxgZIAMoCzIWLmFyY2hlcl9wcm'
    '90b2NvbC5Td1Bvc1IIc3dpdGNoZXMSHAoJZGlzdGFuY2VzGBogAygFUglkaXN0YW5jZXMSNQoJ'
    'Y29lZl9yb3dzGBsgAygLMhguYXJjaGVyX3Byb3RvY29sLkNvZWZSb3dSCGNvZWZSb3dzEhgKB2'
    'NhbGliZXIYHCABKAlSB2NhbGliZXISHwoLZGV2aWNlX3V1aWQYHSABKAlSCmRldmljZVV1aWQ=');

@$core.Deprecated('Use profileListDescriptor instead')
const ProfileList$json = {
  '1': 'ProfileList',
  '2': [
    {
      '1': 'profile_desc',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.archer_protocol.ProfileListEntry',
      '10': 'profileDesc'
    },
    {'1': 'activeprofile', '3': 2, '4': 1, '5': 5, '10': 'activeprofile'},
  ],
};

/// Descriptor for `ProfileList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileListDescriptor = $convert.base64Decode(
    'CgtQcm9maWxlTGlzdBJECgxwcm9maWxlX2Rlc2MYASADKAsyIS5hcmNoZXJfcHJvdG9jb2wuUH'
    'JvZmlsZUxpc3RFbnRyeVILcHJvZmlsZURlc2MSJAoNYWN0aXZlcHJvZmlsZRgCIAEoBVINYWN0'
    'aXZlcHJvZmlsZQ==');

@$core.Deprecated('Use profileListEntryDescriptor instead')
const ProfileListEntry$json = {
  '1': 'ProfileListEntry',
  '2': [
    {'1': 'profile_name', '3': 1, '4': 1, '5': 9, '10': 'profileName'},
    {'1': 'cartridge_name', '3': 2, '4': 1, '5': 9, '10': 'cartridgeName'},
    {'1': 'short_name_top', '3': 3, '4': 1, '5': 9, '10': 'shortNameTop'},
    {'1': 'short_name_bot', '3': 4, '4': 1, '5': 9, '10': 'shortNameBot'},
    {'1': 'file_path', '3': 5, '4': 1, '5': 9, '10': 'filePath'},
  ],
};

/// Descriptor for `ProfileListEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileListEntryDescriptor = $convert.base64Decode(
    'ChBQcm9maWxlTGlzdEVudHJ5EiEKDHByb2ZpbGVfbmFtZRgBIAEoCVILcHJvZmlsZU5hbWUSJQ'
    'oOY2FydHJpZGdlX25hbWUYAiABKAlSDWNhcnRyaWRnZU5hbWUSJAoOc2hvcnRfbmFtZV90b3AY'
    'AyABKAlSDHNob3J0TmFtZVRvcBIkCg5zaG9ydF9uYW1lX2JvdBgEIAEoCVIMc2hvcnROYW1lQm'
    '90EhsKCWZpbGVfcGF0aBgFIAEoCVIIZmlsZVBhdGg=');

@$core.Deprecated('Use fullProfileDataDescriptor instead')
const FullProfileData$json = {
  '1': 'FullProfileData',
  '2': [
    {
      '1': 'table',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.ProfileList',
      '10': 'table'
    },
    {
      '1': 'profiles',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.archer_protocol.HostProfile',
      '10': 'profiles'
    },
  ],
};

/// Descriptor for `FullProfileData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fullProfileDataDescriptor = $convert.base64Decode(
    'Cg9GdWxsUHJvZmlsZURhdGESMgoFdGFibGUYASABKAsyHC5hcmNoZXJfcHJvdG9jb2wuUHJvZm'
    'lsZUxpc3RSBXRhYmxlEjgKCHByb2ZpbGVzGAIgAygLMhwuYXJjaGVyX3Byb3RvY29sLkhvc3RQ'
    'cm9maWxlUghwcm9maWxlcw==');

@$core.Deprecated('Use reticleDescriptor instead')
const Reticle$json = {
  '1': 'Reticle',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
    {'1': 'folder_name', '3': 2, '4': 1, '5': 9, '10': 'folderName'},
  ],
};

/// Descriptor for `Reticle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reticleDescriptor = $convert.base64Decode(
    'CgdSZXRpY2xlEhIKBGRhdGEYASABKAxSBGRhdGESHwoLZm9sZGVyX25hbWUYAiABKAlSCmZvbG'
    'Rlck5hbWU=');

@$core.Deprecated('Use reticlesDescriptor instead')
const Reticles$json = {
  '1': 'Reticles',
  '2': [
    {
      '1': 'rets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.archer_protocol.Reticle',
      '10': 'rets'
    },
  ],
};

/// Descriptor for `Reticles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reticlesDescriptor = $convert.base64Decode(
    'CghSZXRpY2xlcxIsCgRyZXRzGAEgAygLMhguYXJjaGVyX3Byb3RvY29sLlJldGljbGVSBHJldH'
    'M=');

@$core.Deprecated('Use payloadDescriptor instead')
const Payload$json = {
  '1': 'Payload',
  '2': [
    {
      '1': 'profile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.archer_protocol.HostProfile',
      '10': 'profile'
    },
  ],
};

/// Descriptor for `Payload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List payloadDescriptor = $convert.base64Decode(
    'CgdQYXlsb2FkEjYKB3Byb2ZpbGUYASABKAsyHC5hcmNoZXJfcHJvdG9jb2wuSG9zdFByb2ZpbG'
    'VSB3Byb2ZpbGU=');
