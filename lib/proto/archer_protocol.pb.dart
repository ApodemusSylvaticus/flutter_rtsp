// This is a generated file - do not edit.
//
// Generated from archer_protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'archer_protocol.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'archer_protocol.pbenum.dart';

class HostPayload extends $pb.GeneratedMessage {
  factory HostPayload({
    HostProfile? profile,
    HostDevStatus? devStatus,
    CommandResponse? response,
    Reticles? reticles,
    FullProfileData? allProfiles,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    if (devStatus != null) result.devStatus = devStatus;
    if (response != null) result.response = response;
    if (reticles != null) result.reticles = reticles;
    if (allProfiles != null) result.allProfiles = allProfiles;
    return result;
  }

  HostPayload._();

  factory HostPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HostPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HostPayload',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<HostProfile>(1, _omitFieldNames ? '' : 'profile',
        subBuilder: HostProfile.create)
    ..aOM<HostDevStatus>(2, _omitFieldNames ? '' : 'devStatus',
        protoName: 'devStatus', subBuilder: HostDevStatus.create)
    ..aOM<CommandResponse>(3, _omitFieldNames ? '' : 'response',
        subBuilder: CommandResponse.create)
    ..aOM<Reticles>(4, _omitFieldNames ? '' : 'reticles',
        subBuilder: Reticles.create)
    ..aOM<FullProfileData>(5, _omitFieldNames ? '' : 'allProfiles',
        protoName: 'allProfiles', subBuilder: FullProfileData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostPayload copyWith(void Function(HostPayload) updates) =>
      super.copyWith((message) => updates(message as HostPayload))
          as HostPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HostPayload create() => HostPayload._();
  @$core.override
  HostPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HostPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HostPayload>(create);
  static HostPayload? _defaultInstance;

  @$pb.TagNumber(1)
  HostProfile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(HostProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  HostProfile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  HostDevStatus get devStatus => $_getN(1);
  @$pb.TagNumber(2)
  set devStatus(HostDevStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDevStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearDevStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  HostDevStatus ensureDevStatus() => $_ensure(1);

  @$pb.TagNumber(3)
  CommandResponse get response => $_getN(2);
  @$pb.TagNumber(3)
  set response(CommandResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResponse() => $_has(2);
  @$pb.TagNumber(3)
  void clearResponse() => $_clearField(3);
  @$pb.TagNumber(3)
  CommandResponse ensureResponse() => $_ensure(2);

  @$pb.TagNumber(4)
  Reticles get reticles => $_getN(3);
  @$pb.TagNumber(4)
  set reticles(Reticles value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasReticles() => $_has(3);
  @$pb.TagNumber(4)
  void clearReticles() => $_clearField(4);
  @$pb.TagNumber(4)
  Reticles ensureReticles() => $_ensure(3);

  @$pb.TagNumber(5)
  FullProfileData get allProfiles => $_getN(4);
  @$pb.TagNumber(5)
  set allProfiles(FullProfileData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAllProfiles() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllProfiles() => $_clearField(5);
  @$pb.TagNumber(5)
  FullProfileData ensureAllProfiles() => $_ensure(4);
}

class ClientPayload extends $pb.GeneratedMessage {
  factory ClientPayload({
    ClientDevStatus? devStatus,
    Command? command,
    CommandResponse? response,
  }) {
    final result = create();
    if (devStatus != null) result.devStatus = devStatus;
    if (command != null) result.command = command;
    if (response != null) result.response = response;
    return result;
  }

  ClientPayload._();

  factory ClientPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientPayload',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<ClientDevStatus>(2, _omitFieldNames ? '' : 'devStatus',
        protoName: 'devStatus', subBuilder: ClientDevStatus.create)
    ..aOM<Command>(3, _omitFieldNames ? '' : 'command',
        subBuilder: Command.create)
    ..aOM<CommandResponse>(4, _omitFieldNames ? '' : 'response',
        subBuilder: CommandResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientPayload copyWith(void Function(ClientPayload) updates) =>
      super.copyWith((message) => updates(message as ClientPayload))
          as ClientPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientPayload create() => ClientPayload._();
  @$core.override
  ClientPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientPayload>(create);
  static ClientPayload? _defaultInstance;

  @$pb.TagNumber(2)
  ClientDevStatus get devStatus => $_getN(0);
  @$pb.TagNumber(2)
  set devStatus(ClientDevStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDevStatus() => $_has(0);
  @$pb.TagNumber(2)
  void clearDevStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  ClientDevStatus ensureDevStatus() => $_ensure(0);

  @$pb.TagNumber(3)
  Command get command => $_getN(1);
  @$pb.TagNumber(3)
  set command(Command value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCommand() => $_has(1);
  @$pb.TagNumber(3)
  void clearCommand() => $_clearField(3);
  @$pb.TagNumber(3)
  Command ensureCommand() => $_ensure(1);

  @$pb.TagNumber(4)
  CommandResponse get response => $_getN(2);
  @$pb.TagNumber(4)
  set response(CommandResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasResponse() => $_has(2);
  @$pb.TagNumber(4)
  void clearResponse() => $_clearField(4);
  @$pb.TagNumber(4)
  CommandResponse ensureResponse() => $_ensure(2);
}

enum CommandResponse_OneofCommandResponse { statusOk, statusErr, notSet }

class CommandResponse extends $pb.GeneratedMessage {
  factory CommandResponse({
    StatusOk? statusOk,
    StatusError? statusErr,
  }) {
    final result = create();
    if (statusOk != null) result.statusOk = statusOk;
    if (statusErr != null) result.statusErr = statusErr;
    return result;
  }

  CommandResponse._();

  factory CommandResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CommandResponse_OneofCommandResponse>
      _CommandResponse_OneofCommandResponseByTag = {
    1: CommandResponse_OneofCommandResponse.statusOk,
    2: CommandResponse_OneofCommandResponse.statusErr,
    0: CommandResponse_OneofCommandResponse.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<StatusOk>(1, _omitFieldNames ? '' : 'statusOk',
        protoName: 'statusOk', subBuilder: StatusOk.create)
    ..aOM<StatusError>(2, _omitFieldNames ? '' : 'statusErr',
        protoName: 'statusErr', subBuilder: StatusError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResponse copyWith(void Function(CommandResponse) updates) =>
      super.copyWith((message) => updates(message as CommandResponse))
          as CommandResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandResponse create() => CommandResponse._();
  @$core.override
  CommandResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandResponse>(create);
  static CommandResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  CommandResponse_OneofCommandResponse whichOneofCommandResponse() =>
      _CommandResponse_OneofCommandResponseByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearOneofCommandResponse() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  StatusOk get statusOk => $_getN(0);
  @$pb.TagNumber(1)
  set statusOk(StatusOk value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatusOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusOk() => $_clearField(1);
  @$pb.TagNumber(1)
  StatusOk ensureStatusOk() => $_ensure(0);

  @$pb.TagNumber(2)
  StatusError get statusErr => $_getN(1);
  @$pb.TagNumber(2)
  set statusErr(StatusError value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatusErr() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatusErr() => $_clearField(2);
  @$pb.TagNumber(2)
  StatusError ensureStatusErr() => $_ensure(1);
}

enum Command_OneofCommand {
  setZoom,
  setPallette,
  setAgc,
  setDst,
  setHoldoff,
  setZeroing,
  setMagOffset,
  setAirTC,
  setAirHum,
  setAirPress,
  setPowderTemp,
  setWind,
  buttonPress,
  cmdTrigger,
  getHostDevStatus,
  getHostProfile,
  getAllProfiles,
  updateAllProfiles,
  getReticles,
  updateReticles,
  notSet
}

class Command extends $pb.GeneratedMessage {
  factory Command({
    SetZoomLevel? setZoom,
    SetColorScheme? setPallette,
    SetAgcMode? setAgc,
    SetDistance? setDst,
    SetHoldoff? setHoldoff,
    SetZeroing? setZeroing,
    SetCompassOffset? setMagOffset,
    SetAirTemp? setAirTC,
    SetAirHumidity? setAirHum,
    SetAirPressure? setAirPress,
    SetPowderTemp? setPowderTemp,
    SetWind? setWind,
    ButtonPress? buttonPress,
    TriggerCmd? cmdTrigger,
    GetHostDevStatus? getHostDevStatus,
    GetHostProfile? getHostProfile,
    GetProfiles? getAllProfiles,
    UpdateProfiles? updateAllProfiles,
    GetReticles? getReticles,
    UpdateReticles? updateReticles,
  }) {
    final result = create();
    if (setZoom != null) result.setZoom = setZoom;
    if (setPallette != null) result.setPallette = setPallette;
    if (setAgc != null) result.setAgc = setAgc;
    if (setDst != null) result.setDst = setDst;
    if (setHoldoff != null) result.setHoldoff = setHoldoff;
    if (setZeroing != null) result.setZeroing = setZeroing;
    if (setMagOffset != null) result.setMagOffset = setMagOffset;
    if (setAirTC != null) result.setAirTC = setAirTC;
    if (setAirHum != null) result.setAirHum = setAirHum;
    if (setAirPress != null) result.setAirPress = setAirPress;
    if (setPowderTemp != null) result.setPowderTemp = setPowderTemp;
    if (setWind != null) result.setWind = setWind;
    if (buttonPress != null) result.buttonPress = buttonPress;
    if (cmdTrigger != null) result.cmdTrigger = cmdTrigger;
    if (getHostDevStatus != null) result.getHostDevStatus = getHostDevStatus;
    if (getHostProfile != null) result.getHostProfile = getHostProfile;
    if (getAllProfiles != null) result.getAllProfiles = getAllProfiles;
    if (updateAllProfiles != null) result.updateAllProfiles = updateAllProfiles;
    if (getReticles != null) result.getReticles = getReticles;
    if (updateReticles != null) result.updateReticles = updateReticles;
    return result;
  }

  Command._();

  factory Command.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Command.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Command_OneofCommand>
      _Command_OneofCommandByTag = {
    1: Command_OneofCommand.setZoom,
    2: Command_OneofCommand.setPallette,
    3: Command_OneofCommand.setAgc,
    4: Command_OneofCommand.setDst,
    5: Command_OneofCommand.setHoldoff,
    6: Command_OneofCommand.setZeroing,
    7: Command_OneofCommand.setMagOffset,
    8: Command_OneofCommand.setAirTC,
    9: Command_OneofCommand.setAirHum,
    10: Command_OneofCommand.setAirPress,
    11: Command_OneofCommand.setPowderTemp,
    12: Command_OneofCommand.setWind,
    13: Command_OneofCommand.buttonPress,
    14: Command_OneofCommand.cmdTrigger,
    15: Command_OneofCommand.getHostDevStatus,
    16: Command_OneofCommand.getHostProfile,
    17: Command_OneofCommand.getAllProfiles,
    18: Command_OneofCommand.updateAllProfiles,
    19: Command_OneofCommand.getReticles,
    20: Command_OneofCommand.updateReticles,
    0: Command_OneofCommand.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Command',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..oo(0,
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    ..aOM<SetZoomLevel>(1, _omitFieldNames ? '' : 'setZoom',
        protoName: 'setZoom', subBuilder: SetZoomLevel.create)
    ..aOM<SetColorScheme>(2, _omitFieldNames ? '' : 'setPallette',
        protoName: 'setPallette', subBuilder: SetColorScheme.create)
    ..aOM<SetAgcMode>(3, _omitFieldNames ? '' : 'setAgc',
        protoName: 'setAgc', subBuilder: SetAgcMode.create)
    ..aOM<SetDistance>(4, _omitFieldNames ? '' : 'setDst',
        protoName: 'setDst', subBuilder: SetDistance.create)
    ..aOM<SetHoldoff>(5, _omitFieldNames ? '' : 'setHoldoff',
        protoName: 'setHoldoff', subBuilder: SetHoldoff.create)
    ..aOM<SetZeroing>(6, _omitFieldNames ? '' : 'setZeroing',
        protoName: 'setZeroing', subBuilder: SetZeroing.create)
    ..aOM<SetCompassOffset>(7, _omitFieldNames ? '' : 'setMagOffset',
        protoName: 'setMagOffset', subBuilder: SetCompassOffset.create)
    ..aOM<SetAirTemp>(8, _omitFieldNames ? '' : 'setAirTC',
        protoName: 'setAirTC', subBuilder: SetAirTemp.create)
    ..aOM<SetAirHumidity>(9, _omitFieldNames ? '' : 'setAirHum',
        protoName: 'setAirHum', subBuilder: SetAirHumidity.create)
    ..aOM<SetAirPressure>(10, _omitFieldNames ? '' : 'setAirPress',
        protoName: 'setAirPress', subBuilder: SetAirPressure.create)
    ..aOM<SetPowderTemp>(11, _omitFieldNames ? '' : 'setPowderTemp',
        protoName: 'setPowderTemp', subBuilder: SetPowderTemp.create)
    ..aOM<SetWind>(12, _omitFieldNames ? '' : 'setWind',
        protoName: 'setWind', subBuilder: SetWind.create)
    ..aOM<ButtonPress>(13, _omitFieldNames ? '' : 'buttonPress',
        protoName: 'buttonPress', subBuilder: ButtonPress.create)
    ..aOM<TriggerCmd>(14, _omitFieldNames ? '' : 'cmdTrigger',
        protoName: 'cmdTrigger', subBuilder: TriggerCmd.create)
    ..aOM<GetHostDevStatus>(15, _omitFieldNames ? '' : 'getHostDevStatus',
        protoName: 'getHostDevStatus', subBuilder: GetHostDevStatus.create)
    ..aOM<GetHostProfile>(16, _omitFieldNames ? '' : 'getHostProfile',
        protoName: 'getHostProfile', subBuilder: GetHostProfile.create)
    ..aOM<GetProfiles>(17, _omitFieldNames ? '' : 'getAllProfiles',
        protoName: 'getAllProfiles', subBuilder: GetProfiles.create)
    ..aOM<UpdateProfiles>(18, _omitFieldNames ? '' : 'updateAllProfiles',
        protoName: 'updateAllProfiles', subBuilder: UpdateProfiles.create)
    ..aOM<GetReticles>(19, _omitFieldNames ? '' : 'getReticles',
        protoName: 'getReticles', subBuilder: GetReticles.create)
    ..aOM<UpdateReticles>(20, _omitFieldNames ? '' : 'updateReticles',
        protoName: 'updateReticles', subBuilder: UpdateReticles.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command copyWith(void Function(Command) updates) =>
      super.copyWith((message) => updates(message as Command)) as Command;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Command create() => Command._();
  @$core.override
  Command createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Command getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Command>(create);
  static Command? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  Command_OneofCommand whichOneofCommand() =>
      _Command_OneofCommandByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  void clearOneofCommand() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetZoomLevel get setZoom => $_getN(0);
  @$pb.TagNumber(1)
  set setZoom(SetZoomLevel value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSetZoom() => $_has(0);
  @$pb.TagNumber(1)
  void clearSetZoom() => $_clearField(1);
  @$pb.TagNumber(1)
  SetZoomLevel ensureSetZoom() => $_ensure(0);

  @$pb.TagNumber(2)
  SetColorScheme get setPallette => $_getN(1);
  @$pb.TagNumber(2)
  set setPallette(SetColorScheme value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSetPallette() => $_has(1);
  @$pb.TagNumber(2)
  void clearSetPallette() => $_clearField(2);
  @$pb.TagNumber(2)
  SetColorScheme ensureSetPallette() => $_ensure(1);

  @$pb.TagNumber(3)
  SetAgcMode get setAgc => $_getN(2);
  @$pb.TagNumber(3)
  set setAgc(SetAgcMode value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSetAgc() => $_has(2);
  @$pb.TagNumber(3)
  void clearSetAgc() => $_clearField(3);
  @$pb.TagNumber(3)
  SetAgcMode ensureSetAgc() => $_ensure(2);

  @$pb.TagNumber(4)
  SetDistance get setDst => $_getN(3);
  @$pb.TagNumber(4)
  set setDst(SetDistance value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSetDst() => $_has(3);
  @$pb.TagNumber(4)
  void clearSetDst() => $_clearField(4);
  @$pb.TagNumber(4)
  SetDistance ensureSetDst() => $_ensure(3);

  @$pb.TagNumber(5)
  SetHoldoff get setHoldoff => $_getN(4);
  @$pb.TagNumber(5)
  set setHoldoff(SetHoldoff value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSetHoldoff() => $_has(4);
  @$pb.TagNumber(5)
  void clearSetHoldoff() => $_clearField(5);
  @$pb.TagNumber(5)
  SetHoldoff ensureSetHoldoff() => $_ensure(4);

  @$pb.TagNumber(6)
  SetZeroing get setZeroing => $_getN(5);
  @$pb.TagNumber(6)
  set setZeroing(SetZeroing value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSetZeroing() => $_has(5);
  @$pb.TagNumber(6)
  void clearSetZeroing() => $_clearField(6);
  @$pb.TagNumber(6)
  SetZeroing ensureSetZeroing() => $_ensure(5);

  @$pb.TagNumber(7)
  SetCompassOffset get setMagOffset => $_getN(6);
  @$pb.TagNumber(7)
  set setMagOffset(SetCompassOffset value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasSetMagOffset() => $_has(6);
  @$pb.TagNumber(7)
  void clearSetMagOffset() => $_clearField(7);
  @$pb.TagNumber(7)
  SetCompassOffset ensureSetMagOffset() => $_ensure(6);

  @$pb.TagNumber(8)
  SetAirTemp get setAirTC => $_getN(7);
  @$pb.TagNumber(8)
  set setAirTC(SetAirTemp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasSetAirTC() => $_has(7);
  @$pb.TagNumber(8)
  void clearSetAirTC() => $_clearField(8);
  @$pb.TagNumber(8)
  SetAirTemp ensureSetAirTC() => $_ensure(7);

  @$pb.TagNumber(9)
  SetAirHumidity get setAirHum => $_getN(8);
  @$pb.TagNumber(9)
  set setAirHum(SetAirHumidity value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSetAirHum() => $_has(8);
  @$pb.TagNumber(9)
  void clearSetAirHum() => $_clearField(9);
  @$pb.TagNumber(9)
  SetAirHumidity ensureSetAirHum() => $_ensure(8);

  @$pb.TagNumber(10)
  SetAirPressure get setAirPress => $_getN(9);
  @$pb.TagNumber(10)
  set setAirPress(SetAirPressure value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSetAirPress() => $_has(9);
  @$pb.TagNumber(10)
  void clearSetAirPress() => $_clearField(10);
  @$pb.TagNumber(10)
  SetAirPressure ensureSetAirPress() => $_ensure(9);

  @$pb.TagNumber(11)
  SetPowderTemp get setPowderTemp => $_getN(10);
  @$pb.TagNumber(11)
  set setPowderTemp(SetPowderTemp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSetPowderTemp() => $_has(10);
  @$pb.TagNumber(11)
  void clearSetPowderTemp() => $_clearField(11);
  @$pb.TagNumber(11)
  SetPowderTemp ensureSetPowderTemp() => $_ensure(10);

  @$pb.TagNumber(12)
  SetWind get setWind => $_getN(11);
  @$pb.TagNumber(12)
  set setWind(SetWind value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSetWind() => $_has(11);
  @$pb.TagNumber(12)
  void clearSetWind() => $_clearField(12);
  @$pb.TagNumber(12)
  SetWind ensureSetWind() => $_ensure(11);

  @$pb.TagNumber(13)
  ButtonPress get buttonPress => $_getN(12);
  @$pb.TagNumber(13)
  set buttonPress(ButtonPress value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasButtonPress() => $_has(12);
  @$pb.TagNumber(13)
  void clearButtonPress() => $_clearField(13);
  @$pb.TagNumber(13)
  ButtonPress ensureButtonPress() => $_ensure(12);

  @$pb.TagNumber(14)
  TriggerCmd get cmdTrigger => $_getN(13);
  @$pb.TagNumber(14)
  set cmdTrigger(TriggerCmd value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCmdTrigger() => $_has(13);
  @$pb.TagNumber(14)
  void clearCmdTrigger() => $_clearField(14);
  @$pb.TagNumber(14)
  TriggerCmd ensureCmdTrigger() => $_ensure(13);

  @$pb.TagNumber(15)
  GetHostDevStatus get getHostDevStatus => $_getN(14);
  @$pb.TagNumber(15)
  set getHostDevStatus(GetHostDevStatus value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasGetHostDevStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearGetHostDevStatus() => $_clearField(15);
  @$pb.TagNumber(15)
  GetHostDevStatus ensureGetHostDevStatus() => $_ensure(14);

  @$pb.TagNumber(16)
  GetHostProfile get getHostProfile => $_getN(15);
  @$pb.TagNumber(16)
  set getHostProfile(GetHostProfile value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasGetHostProfile() => $_has(15);
  @$pb.TagNumber(16)
  void clearGetHostProfile() => $_clearField(16);
  @$pb.TagNumber(16)
  GetHostProfile ensureGetHostProfile() => $_ensure(15);

  @$pb.TagNumber(17)
  GetProfiles get getAllProfiles => $_getN(16);
  @$pb.TagNumber(17)
  set getAllProfiles(GetProfiles value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasGetAllProfiles() => $_has(16);
  @$pb.TagNumber(17)
  void clearGetAllProfiles() => $_clearField(17);
  @$pb.TagNumber(17)
  GetProfiles ensureGetAllProfiles() => $_ensure(16);

  @$pb.TagNumber(18)
  UpdateProfiles get updateAllProfiles => $_getN(17);
  @$pb.TagNumber(18)
  set updateAllProfiles(UpdateProfiles value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasUpdateAllProfiles() => $_has(17);
  @$pb.TagNumber(18)
  void clearUpdateAllProfiles() => $_clearField(18);
  @$pb.TagNumber(18)
  UpdateProfiles ensureUpdateAllProfiles() => $_ensure(17);

  @$pb.TagNumber(19)
  GetReticles get getReticles => $_getN(18);
  @$pb.TagNumber(19)
  set getReticles(GetReticles value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasGetReticles() => $_has(18);
  @$pb.TagNumber(19)
  void clearGetReticles() => $_clearField(19);
  @$pb.TagNumber(19)
  GetReticles ensureGetReticles() => $_ensure(18);

  @$pb.TagNumber(20)
  UpdateReticles get updateReticles => $_getN(19);
  @$pb.TagNumber(20)
  set updateReticles(UpdateReticles value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasUpdateReticles() => $_has(19);
  @$pb.TagNumber(20)
  void clearUpdateReticles() => $_clearField(20);
  @$pb.TagNumber(20)
  UpdateReticles ensureUpdateReticles() => $_ensure(19);
}

class GetProfiles extends $pb.GeneratedMessage {
  factory GetProfiles() => create();

  GetProfiles._();

  factory GetProfiles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProfiles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProfiles',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfiles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfiles copyWith(void Function(GetProfiles) updates) =>
      super.copyWith((message) => updates(message as GetProfiles))
          as GetProfiles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfiles create() => GetProfiles._();
  @$core.override
  GetProfiles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProfiles getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProfiles>(create);
  static GetProfiles? _defaultInstance;
}

class GetReticles extends $pb.GeneratedMessage {
  factory GetReticles() => create();

  GetReticles._();

  factory GetReticles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReticles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReticles',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReticles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReticles copyWith(void Function(GetReticles) updates) =>
      super.copyWith((message) => updates(message as GetReticles))
          as GetReticles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReticles create() => GetReticles._();
  @$core.override
  GetReticles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReticles getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReticles>(create);
  static GetReticles? _defaultInstance;
}

class UpdateReticles extends $pb.GeneratedMessage {
  factory UpdateReticles({
    Reticles? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  UpdateReticles._();

  factory UpdateReticles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateReticles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateReticles',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<Reticles>(1, _omitFieldNames ? '' : 'data',
        subBuilder: Reticles.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateReticles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateReticles copyWith(void Function(UpdateReticles) updates) =>
      super.copyWith((message) => updates(message as UpdateReticles))
          as UpdateReticles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateReticles create() => UpdateReticles._();
  @$core.override
  UpdateReticles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateReticles getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateReticles>(create);
  static UpdateReticles? _defaultInstance;

  @$pb.TagNumber(1)
  Reticles get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(Reticles value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  Reticles ensureData() => $_ensure(0);
}

class UpdateProfiles extends $pb.GeneratedMessage {
  factory UpdateProfiles({
    FullProfileData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  UpdateProfiles._();

  factory UpdateProfiles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateProfiles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProfiles',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<FullProfileData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FullProfileData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfiles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfiles copyWith(void Function(UpdateProfiles) updates) =>
      super.copyWith((message) => updates(message as UpdateProfiles))
          as UpdateProfiles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfiles create() => UpdateProfiles._();
  @$core.override
  UpdateProfiles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateProfiles getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProfiles>(create);
  static UpdateProfiles? _defaultInstance;

  @$pb.TagNumber(1)
  FullProfileData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FullProfileData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FullProfileData ensureData() => $_ensure(0);
}

class StatusOk extends $pb.GeneratedMessage {
  factory StatusOk({
    OkStatusCode? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  StatusOk._();

  factory StatusOk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatusOk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusOk',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<OkStatusCode>(1, _omitFieldNames ? '' : 'code',
        enumValues: OkStatusCode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusOk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusOk copyWith(void Function(StatusOk) updates) =>
      super.copyWith((message) => updates(message as StatusOk)) as StatusOk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusOk create() => StatusOk._();
  @$core.override
  StatusOk createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatusOk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusOk>(create);
  static StatusOk? _defaultInstance;

  @$pb.TagNumber(1)
  OkStatusCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(OkStatusCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class StatusError extends $pb.GeneratedMessage {
  factory StatusError({
    ErrorStatusCode? code,
    $core.String? text,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (text != null) result.text = text;
    return result;
  }

  StatusError._();

  factory StatusError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatusError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<ErrorStatusCode>(1, _omitFieldNames ? '' : 'code',
        enumValues: ErrorStatusCode.values)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusError copyWith(void Function(StatusError) updates) =>
      super.copyWith((message) => updates(message as StatusError))
          as StatusError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusError create() => StatusError._();
  @$core.override
  StatusError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatusError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatusError>(create);
  static StatusError? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorStatusCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(ErrorStatusCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
}

class SetZoomLevel extends $pb.GeneratedMessage {
  factory SetZoomLevel({
    Zoom? zoomLevel,
  }) {
    final result = create();
    if (zoomLevel != null) result.zoomLevel = zoomLevel;
    return result;
  }

  SetZoomLevel._();

  factory SetZoomLevel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetZoomLevel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetZoomLevel',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<Zoom>(1, _omitFieldNames ? '' : 'zoomLevel',
        protoName: 'zoomLevel', enumValues: Zoom.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetZoomLevel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetZoomLevel copyWith(void Function(SetZoomLevel) updates) =>
      super.copyWith((message) => updates(message as SetZoomLevel))
          as SetZoomLevel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetZoomLevel create() => SetZoomLevel._();
  @$core.override
  SetZoomLevel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetZoomLevel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetZoomLevel>(create);
  static SetZoomLevel? _defaultInstance;

  @$pb.TagNumber(1)
  Zoom get zoomLevel => $_getN(0);
  @$pb.TagNumber(1)
  set zoomLevel(Zoom value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasZoomLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoomLevel() => $_clearField(1);
}

class SetColorScheme extends $pb.GeneratedMessage {
  factory SetColorScheme({
    ColorScheme? scheme,
  }) {
    final result = create();
    if (scheme != null) result.scheme = scheme;
    return result;
  }

  SetColorScheme._();

  factory SetColorScheme.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetColorScheme.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetColorScheme',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<ColorScheme>(1, _omitFieldNames ? '' : 'scheme',
        enumValues: ColorScheme.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetColorScheme clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetColorScheme copyWith(void Function(SetColorScheme) updates) =>
      super.copyWith((message) => updates(message as SetColorScheme))
          as SetColorScheme;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetColorScheme create() => SetColorScheme._();
  @$core.override
  SetColorScheme createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetColorScheme getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetColorScheme>(create);
  static SetColorScheme? _defaultInstance;

  @$pb.TagNumber(1)
  ColorScheme get scheme => $_getN(0);
  @$pb.TagNumber(1)
  set scheme(ColorScheme value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasScheme() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheme() => $_clearField(1);
}

class GetHostDevStatus extends $pb.GeneratedMessage {
  factory GetHostDevStatus() => create();

  GetHostDevStatus._();

  factory GetHostDevStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHostDevStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHostDevStatus',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHostDevStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHostDevStatus copyWith(void Function(GetHostDevStatus) updates) =>
      super.copyWith((message) => updates(message as GetHostDevStatus))
          as GetHostDevStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHostDevStatus create() => GetHostDevStatus._();
  @$core.override
  GetHostDevStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHostDevStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHostDevStatus>(create);
  static GetHostDevStatus? _defaultInstance;
}

class GetHostProfile extends $pb.GeneratedMessage {
  factory GetHostProfile() => create();

  GetHostProfile._();

  factory GetHostProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHostProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHostProfile',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHostProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHostProfile copyWith(void Function(GetHostProfile) updates) =>
      super.copyWith((message) => updates(message as GetHostProfile))
          as GetHostProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHostProfile create() => GetHostProfile._();
  @$core.override
  GetHostProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHostProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHostProfile>(create);
  static GetHostProfile? _defaultInstance;
}

class SetAirTemp extends $pb.GeneratedMessage {
  factory SetAirTemp({
    $core.int? temperature,
  }) {
    final result = create();
    if (temperature != null) result.temperature = temperature;
    return result;
  }

  SetAirTemp._();

  factory SetAirTemp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAirTemp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAirTemp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'temperature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirTemp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirTemp copyWith(void Function(SetAirTemp) updates) =>
      super.copyWith((message) => updates(message as SetAirTemp)) as SetAirTemp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAirTemp create() => SetAirTemp._();
  @$core.override
  SetAirTemp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAirTemp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAirTemp>(create);
  static SetAirTemp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get temperature => $_getIZ(0);
  @$pb.TagNumber(1)
  set temperature($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperature() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperature() => $_clearField(1);
}

class SetPowderTemp extends $pb.GeneratedMessage {
  factory SetPowderTemp({
    $core.int? temperature,
  }) {
    final result = create();
    if (temperature != null) result.temperature = temperature;
    return result;
  }

  SetPowderTemp._();

  factory SetPowderTemp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPowderTemp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPowderTemp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'temperature')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPowderTemp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPowderTemp copyWith(void Function(SetPowderTemp) updates) =>
      super.copyWith((message) => updates(message as SetPowderTemp))
          as SetPowderTemp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPowderTemp create() => SetPowderTemp._();
  @$core.override
  SetPowderTemp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPowderTemp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPowderTemp>(create);
  static SetPowderTemp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get temperature => $_getIZ(0);
  @$pb.TagNumber(1)
  set temperature($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperature() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperature() => $_clearField(1);
}

class SetAirHumidity extends $pb.GeneratedMessage {
  factory SetAirHumidity({
    $core.int? humidity,
  }) {
    final result = create();
    if (humidity != null) result.humidity = humidity;
    return result;
  }

  SetAirHumidity._();

  factory SetAirHumidity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAirHumidity.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAirHumidity',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'humidity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirHumidity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirHumidity copyWith(void Function(SetAirHumidity) updates) =>
      super.copyWith((message) => updates(message as SetAirHumidity))
          as SetAirHumidity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAirHumidity create() => SetAirHumidity._();
  @$core.override
  SetAirHumidity createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAirHumidity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAirHumidity>(create);
  static SetAirHumidity? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get humidity => $_getIZ(0);
  @$pb.TagNumber(1)
  set humidity($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHumidity() => $_has(0);
  @$pb.TagNumber(1)
  void clearHumidity() => $_clearField(1);
}

class SetAirPressure extends $pb.GeneratedMessage {
  factory SetAirPressure({
    $core.int? pressure,
  }) {
    final result = create();
    if (pressure != null) result.pressure = pressure;
    return result;
  }

  SetAirPressure._();

  factory SetAirPressure.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAirPressure.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAirPressure',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pressure')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirPressure clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAirPressure copyWith(void Function(SetAirPressure) updates) =>
      super.copyWith((message) => updates(message as SetAirPressure))
          as SetAirPressure;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAirPressure create() => SetAirPressure._();
  @$core.override
  SetAirPressure createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAirPressure getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAirPressure>(create);
  static SetAirPressure? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pressure => $_getIZ(0);
  @$pb.TagNumber(1)
  set pressure($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPressure() => $_has(0);
  @$pb.TagNumber(1)
  void clearPressure() => $_clearField(1);
}

class SetWind extends $pb.GeneratedMessage {
  factory SetWind({
    $core.int? direction,
    $core.int? speed,
  }) {
    final result = create();
    if (direction != null) result.direction = direction;
    if (speed != null) result.speed = speed;
    return result;
  }

  SetWind._();

  factory SetWind.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetWind.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetWind',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'direction')
    ..aI(2, _omitFieldNames ? '' : 'speed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWind clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetWind copyWith(void Function(SetWind) updates) =>
      super.copyWith((message) => updates(message as SetWind)) as SetWind;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetWind create() => SetWind._();
  @$core.override
  SetWind createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetWind getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetWind>(create);
  static SetWind? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get direction => $_getIZ(0);
  @$pb.TagNumber(1)
  set direction($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDirection() => $_has(0);
  @$pb.TagNumber(1)
  void clearDirection() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get speed => $_getIZ(1);
  @$pb.TagNumber(2)
  set speed($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpeed() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpeed() => $_clearField(2);
}

class SetDistance extends $pb.GeneratedMessage {
  factory SetDistance({
    $core.int? distance,
  }) {
    final result = create();
    if (distance != null) result.distance = distance;
    return result;
  }

  SetDistance._();

  factory SetDistance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetDistance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetDistance',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'distance')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDistance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDistance copyWith(void Function(SetDistance) updates) =>
      super.copyWith((message) => updates(message as SetDistance))
          as SetDistance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetDistance create() => SetDistance._();
  @$core.override
  SetDistance createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetDistance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetDistance>(create);
  static SetDistance? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get distance => $_getIZ(0);
  @$pb.TagNumber(1)
  set distance($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDistance() => $_has(0);
  @$pb.TagNumber(1)
  void clearDistance() => $_clearField(1);
}

class SetAgcMode extends $pb.GeneratedMessage {
  factory SetAgcMode({
    AGCMode? mode,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    return result;
  }

  SetAgcMode._();

  factory SetAgcMode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAgcMode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAgcMode',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<AGCMode>(1, _omitFieldNames ? '' : 'mode', enumValues: AGCMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAgcMode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAgcMode copyWith(void Function(SetAgcMode) updates) =>
      super.copyWith((message) => updates(message as SetAgcMode)) as SetAgcMode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAgcMode create() => SetAgcMode._();
  @$core.override
  SetAgcMode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAgcMode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAgcMode>(create);
  static SetAgcMode? _defaultInstance;

  @$pb.TagNumber(1)
  AGCMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(AGCMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class SetCompassOffset extends $pb.GeneratedMessage {
  factory SetCompassOffset({
    $core.int? offset,
  }) {
    final result = create();
    if (offset != null) result.offset = offset;
    return result;
  }

  SetCompassOffset._();

  factory SetCompassOffset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCompassOffset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCompassOffset',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCompassOffset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCompassOffset copyWith(void Function(SetCompassOffset) updates) =>
      super.copyWith((message) => updates(message as SetCompassOffset))
          as SetCompassOffset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCompassOffset create() => SetCompassOffset._();
  @$core.override
  SetCompassOffset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCompassOffset getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCompassOffset>(create);
  static SetCompassOffset? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get offset => $_getIZ(0);
  @$pb.TagNumber(1)
  set offset($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOffset() => $_has(0);
  @$pb.TagNumber(1)
  void clearOffset() => $_clearField(1);
}

class SetHoldoff extends $pb.GeneratedMessage {
  factory SetHoldoff({
    $core.int? x,
    $core.int? y,
    HoldoffType? type,
  }) {
    final result = create();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (type != null) result.type = type;
    return result;
  }

  SetHoldoff._();

  factory SetHoldoff.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetHoldoff.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetHoldoff',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'x')
    ..aI(2, _omitFieldNames ? '' : 'y')
    ..aE<HoldoffType>(3, _omitFieldNames ? '' : 'type',
        enumValues: HoldoffType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetHoldoff clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetHoldoff copyWith(void Function(SetHoldoff) updates) =>
      super.copyWith((message) => updates(message as SetHoldoff)) as SetHoldoff;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetHoldoff create() => SetHoldoff._();
  @$core.override
  SetHoldoff createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetHoldoff getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetHoldoff>(create);
  static SetHoldoff? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get y => $_getIZ(1);
  @$pb.TagNumber(2)
  set y($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);

  @$pb.TagNumber(3)
  HoldoffType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(HoldoffType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);
}

class ButtonPress extends $pb.GeneratedMessage {
  factory ButtonPress({
    ButtonEnum? buttonPressed,
  }) {
    final result = create();
    if (buttonPressed != null) result.buttonPressed = buttonPressed;
    return result;
  }

  ButtonPress._();

  factory ButtonPress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ButtonPress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ButtonPress',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<ButtonEnum>(1, _omitFieldNames ? '' : 'buttonPressed',
        protoName: 'buttonPressed', enumValues: ButtonEnum.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonPress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonPress copyWith(void Function(ButtonPress) updates) =>
      super.copyWith((message) => updates(message as ButtonPress))
          as ButtonPress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ButtonPress create() => ButtonPress._();
  @$core.override
  ButtonPress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ButtonPress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ButtonPress>(create);
  static ButtonPress? _defaultInstance;

  @$pb.TagNumber(1)
  ButtonEnum get buttonPressed => $_getN(0);
  @$pb.TagNumber(1)
  set buttonPressed(ButtonEnum value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasButtonPressed() => $_has(0);
  @$pb.TagNumber(1)
  void clearButtonPressed() => $_clearField(1);
}

class TriggerCmd extends $pb.GeneratedMessage {
  factory TriggerCmd({
    CMDDirect? cmd,
  }) {
    final result = create();
    if (cmd != null) result.cmd = cmd;
    return result;
  }

  TriggerCmd._();

  factory TriggerCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TriggerCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TriggerCmd',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aE<CMDDirect>(1, _omitFieldNames ? '' : 'cmd',
        enumValues: CMDDirect.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerCmd copyWith(void Function(TriggerCmd) updates) =>
      super.copyWith((message) => updates(message as TriggerCmd)) as TriggerCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TriggerCmd create() => TriggerCmd._();
  @$core.override
  TriggerCmd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TriggerCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TriggerCmd>(create);
  static TriggerCmd? _defaultInstance;

  @$pb.TagNumber(1)
  CMDDirect get cmd => $_getN(0);
  @$pb.TagNumber(1)
  set cmd(CMDDirect value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => $_clearField(1);
}

class SetZeroing extends $pb.GeneratedMessage {
  factory SetZeroing({
    $core.int? x,
    $core.int? y,
  }) {
    final result = create();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  SetZeroing._();

  factory SetZeroing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetZeroing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetZeroing',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'x')
    ..aI(2, _omitFieldNames ? '' : 'y')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetZeroing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetZeroing copyWith(void Function(SetZeroing) updates) =>
      super.copyWith((message) => updates(message as SetZeroing)) as SetZeroing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetZeroing create() => SetZeroing._();
  @$core.override
  SetZeroing createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetZeroing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetZeroing>(create);
  static SetZeroing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get y => $_getIZ(1);
  @$pb.TagNumber(2)
  set y($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class HostDevStatus extends $pb.GeneratedMessage {
  factory HostDevStatus({
    $core.int? charge,
    Zoom? zoom,
    $core.int? airTemp,
    $core.int? airHum,
    $core.int? airPress,
    $core.int? powderTemp,
    $core.int? windDir,
    $core.int? windSpeed,
    $core.int? pitch,
    $core.int? cant,
    $core.int? distance,
    $core.int? currentProfile,
    ColorScheme? colorScheme,
    AGCMode? modAGC,
    Zoom? maxZoom,
  }) {
    final result = create();
    if (charge != null) result.charge = charge;
    if (zoom != null) result.zoom = zoom;
    if (airTemp != null) result.airTemp = airTemp;
    if (airHum != null) result.airHum = airHum;
    if (airPress != null) result.airPress = airPress;
    if (powderTemp != null) result.powderTemp = powderTemp;
    if (windDir != null) result.windDir = windDir;
    if (windSpeed != null) result.windSpeed = windSpeed;
    if (pitch != null) result.pitch = pitch;
    if (cant != null) result.cant = cant;
    if (distance != null) result.distance = distance;
    if (currentProfile != null) result.currentProfile = currentProfile;
    if (colorScheme != null) result.colorScheme = colorScheme;
    if (modAGC != null) result.modAGC = modAGC;
    if (maxZoom != null) result.maxZoom = maxZoom;
    return result;
  }

  HostDevStatus._();

  factory HostDevStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HostDevStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HostDevStatus',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'charge')
    ..aE<Zoom>(2, _omitFieldNames ? '' : 'zoom', enumValues: Zoom.values)
    ..aI(3, _omitFieldNames ? '' : 'airTemp', protoName: 'airTemp')
    ..aI(4, _omitFieldNames ? '' : 'airHum', protoName: 'airHum')
    ..aI(5, _omitFieldNames ? '' : 'airPress', protoName: 'airPress')
    ..aI(6, _omitFieldNames ? '' : 'powderTemp', protoName: 'powderTemp')
    ..aI(7, _omitFieldNames ? '' : 'windDir', protoName: 'windDir')
    ..aI(8, _omitFieldNames ? '' : 'windSpeed', protoName: 'windSpeed')
    ..aI(9, _omitFieldNames ? '' : 'pitch')
    ..aI(10, _omitFieldNames ? '' : 'cant')
    ..aI(11, _omitFieldNames ? '' : 'distance')
    ..aI(12, _omitFieldNames ? '' : 'currentProfile',
        protoName: 'currentProfile')
    ..aE<ColorScheme>(13, _omitFieldNames ? '' : 'colorScheme',
        protoName: 'colorScheme', enumValues: ColorScheme.values)
    ..aE<AGCMode>(14, _omitFieldNames ? '' : 'modAGC',
        protoName: 'modAGC', enumValues: AGCMode.values)
    ..aE<Zoom>(15, _omitFieldNames ? '' : 'maxZoom',
        protoName: 'maxZoom', enumValues: Zoom.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostDevStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostDevStatus copyWith(void Function(HostDevStatus) updates) =>
      super.copyWith((message) => updates(message as HostDevStatus))
          as HostDevStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HostDevStatus create() => HostDevStatus._();
  @$core.override
  HostDevStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HostDevStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HostDevStatus>(create);
  static HostDevStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get charge => $_getIZ(0);
  @$pb.TagNumber(1)
  set charge($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCharge() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharge() => $_clearField(1);

  @$pb.TagNumber(2)
  Zoom get zoom => $_getN(1);
  @$pb.TagNumber(2)
  set zoom(Zoom value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasZoom() => $_has(1);
  @$pb.TagNumber(2)
  void clearZoom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get airTemp => $_getIZ(2);
  @$pb.TagNumber(3)
  set airTemp($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAirTemp() => $_has(2);
  @$pb.TagNumber(3)
  void clearAirTemp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get airHum => $_getIZ(3);
  @$pb.TagNumber(4)
  set airHum($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAirHum() => $_has(3);
  @$pb.TagNumber(4)
  void clearAirHum() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get airPress => $_getIZ(4);
  @$pb.TagNumber(5)
  set airPress($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAirPress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAirPress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get powderTemp => $_getIZ(5);
  @$pb.TagNumber(6)
  set powderTemp($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPowderTemp() => $_has(5);
  @$pb.TagNumber(6)
  void clearPowderTemp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get windDir => $_getIZ(6);
  @$pb.TagNumber(7)
  set windDir($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWindDir() => $_has(6);
  @$pb.TagNumber(7)
  void clearWindDir() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get windSpeed => $_getIZ(7);
  @$pb.TagNumber(8)
  set windSpeed($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWindSpeed() => $_has(7);
  @$pb.TagNumber(8)
  void clearWindSpeed() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get pitch => $_getIZ(8);
  @$pb.TagNumber(9)
  set pitch($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPitch() => $_has(8);
  @$pb.TagNumber(9)
  void clearPitch() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get cant => $_getIZ(9);
  @$pb.TagNumber(10)
  set cant($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCant() => $_has(9);
  @$pb.TagNumber(10)
  void clearCant() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get distance => $_getIZ(10);
  @$pb.TagNumber(11)
  set distance($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDistance() => $_has(10);
  @$pb.TagNumber(11)
  void clearDistance() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get currentProfile => $_getIZ(11);
  @$pb.TagNumber(12)
  set currentProfile($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCurrentProfile() => $_has(11);
  @$pb.TagNumber(12)
  void clearCurrentProfile() => $_clearField(12);

  @$pb.TagNumber(13)
  ColorScheme get colorScheme => $_getN(12);
  @$pb.TagNumber(13)
  set colorScheme(ColorScheme value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasColorScheme() => $_has(12);
  @$pb.TagNumber(13)
  void clearColorScheme() => $_clearField(13);

  @$pb.TagNumber(14)
  AGCMode get modAGC => $_getN(13);
  @$pb.TagNumber(14)
  set modAGC(AGCMode value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasModAGC() => $_has(13);
  @$pb.TagNumber(14)
  void clearModAGC() => $_clearField(14);

  @$pb.TagNumber(15)
  Zoom get maxZoom => $_getN(14);
  @$pb.TagNumber(15)
  set maxZoom(Zoom value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasMaxZoom() => $_has(14);
  @$pb.TagNumber(15)
  void clearMaxZoom() => $_clearField(15);
}

class ClientDevStatus extends $pb.GeneratedMessage {
  factory ClientDevStatus() => create();

  ClientDevStatus._();

  factory ClientDevStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientDevStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDevStatus',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDevStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDevStatus copyWith(void Function(ClientDevStatus) updates) =>
      super.copyWith((message) => updates(message as ClientDevStatus))
          as ClientDevStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDevStatus create() => ClientDevStatus._();
  @$core.override
  ClientDevStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientDevStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDevStatus>(create);
  static ClientDevStatus? _defaultInstance;
}

class CoefRow extends $pb.GeneratedMessage {
  factory CoefRow({
    $core.int? bcCd,
    $core.int? mv,
  }) {
    final result = create();
    if (bcCd != null) result.bcCd = bcCd;
    if (mv != null) result.mv = mv;
    return result;
  }

  CoefRow._();

  factory CoefRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CoefRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CoefRow',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'bcCd')
    ..aI(2, _omitFieldNames ? '' : 'mv')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoefRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoefRow copyWith(void Function(CoefRow) updates) =>
      super.copyWith((message) => updates(message as CoefRow)) as CoefRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoefRow create() => CoefRow._();
  @$core.override
  CoefRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CoefRow getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoefRow>(create);
  static CoefRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get bcCd => $_getIZ(0);
  @$pb.TagNumber(1)
  set bcCd($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBcCd() => $_has(0);
  @$pb.TagNumber(1)
  void clearBcCd() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get mv => $_getIZ(1);
  @$pb.TagNumber(2)
  set mv($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMv() => $_has(1);
  @$pb.TagNumber(2)
  void clearMv() => $_clearField(2);
}

class SwPos extends $pb.GeneratedMessage {
  factory SwPos({
    $core.int? cIdx,
    $core.int? reticleIdx,
    $core.int? zoom,
    $core.int? distance,
    DType? distanceFrom,
  }) {
    final result = create();
    if (cIdx != null) result.cIdx = cIdx;
    if (reticleIdx != null) result.reticleIdx = reticleIdx;
    if (zoom != null) result.zoom = zoom;
    if (distance != null) result.distance = distance;
    if (distanceFrom != null) result.distanceFrom = distanceFrom;
    return result;
  }

  SwPos._();

  factory SwPos.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SwPos.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SwPos',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'cIdx')
    ..aI(2, _omitFieldNames ? '' : 'reticleIdx')
    ..aI(3, _omitFieldNames ? '' : 'zoom')
    ..aI(4, _omitFieldNames ? '' : 'distance')
    ..aE<DType>(5, _omitFieldNames ? '' : 'distanceFrom',
        enumValues: DType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwPos clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwPos copyWith(void Function(SwPos) updates) =>
      super.copyWith((message) => updates(message as SwPos)) as SwPos;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SwPos create() => SwPos._();
  @$core.override
  SwPos createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SwPos getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwPos>(create);
  static SwPos? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cIdx => $_getIZ(0);
  @$pb.TagNumber(1)
  set cIdx($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCIdx() => $_has(0);
  @$pb.TagNumber(1)
  void clearCIdx() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get reticleIdx => $_getIZ(1);
  @$pb.TagNumber(2)
  set reticleIdx($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReticleIdx() => $_has(1);
  @$pb.TagNumber(2)
  void clearReticleIdx() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get zoom => $_getIZ(2);
  @$pb.TagNumber(3)
  set zoom($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoom() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get distance => $_getIZ(3);
  @$pb.TagNumber(4)
  set distance($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDistance() => $_has(3);
  @$pb.TagNumber(4)
  void clearDistance() => $_clearField(4);

  @$pb.TagNumber(5)
  DType get distanceFrom => $_getN(4);
  @$pb.TagNumber(5)
  set distanceFrom(DType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDistanceFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearDistanceFrom() => $_clearField(5);
}

class HostProfile extends $pb.GeneratedMessage {
  factory HostProfile({
    $core.String? profileName,
    $core.String? cartridgeName,
    $core.String? bulletName,
    $core.String? shortNameTop,
    $core.String? shortNameBot,
    $core.String? userNote,
    $core.int? zeroX,
    $core.int? zeroY,
    $core.int? scHeight,
    $core.int? rTwist,
    $core.int? cMuzzleVelocity,
    $core.int? cZeroTemperature,
    $core.int? cTCoeff,
    $core.int? cZeroDistanceIdx,
    $core.int? cZeroAirTemperature,
    $core.int? cZeroAirPressure,
    $core.int? cZeroAirHumidity,
    $core.int? cZeroWPitch,
    $core.int? cZeroPTemperature,
    $core.int? bDiameter,
    $core.int? bWeight,
    $core.int? bLength,
    TwistDir? twistDir,
    GType? bcType,
    $core.Iterable<SwPos>? switches,
    $core.Iterable<$core.int>? distances,
    $core.Iterable<CoefRow>? coefRows,
    $core.String? caliber,
    $core.String? deviceUuid,
  }) {
    final result = create();
    if (profileName != null) result.profileName = profileName;
    if (cartridgeName != null) result.cartridgeName = cartridgeName;
    if (bulletName != null) result.bulletName = bulletName;
    if (shortNameTop != null) result.shortNameTop = shortNameTop;
    if (shortNameBot != null) result.shortNameBot = shortNameBot;
    if (userNote != null) result.userNote = userNote;
    if (zeroX != null) result.zeroX = zeroX;
    if (zeroY != null) result.zeroY = zeroY;
    if (scHeight != null) result.scHeight = scHeight;
    if (rTwist != null) result.rTwist = rTwist;
    if (cMuzzleVelocity != null) result.cMuzzleVelocity = cMuzzleVelocity;
    if (cZeroTemperature != null) result.cZeroTemperature = cZeroTemperature;
    if (cTCoeff != null) result.cTCoeff = cTCoeff;
    if (cZeroDistanceIdx != null) result.cZeroDistanceIdx = cZeroDistanceIdx;
    if (cZeroAirTemperature != null)
      result.cZeroAirTemperature = cZeroAirTemperature;
    if (cZeroAirPressure != null) result.cZeroAirPressure = cZeroAirPressure;
    if (cZeroAirHumidity != null) result.cZeroAirHumidity = cZeroAirHumidity;
    if (cZeroWPitch != null) result.cZeroWPitch = cZeroWPitch;
    if (cZeroPTemperature != null) result.cZeroPTemperature = cZeroPTemperature;
    if (bDiameter != null) result.bDiameter = bDiameter;
    if (bWeight != null) result.bWeight = bWeight;
    if (bLength != null) result.bLength = bLength;
    if (twistDir != null) result.twistDir = twistDir;
    if (bcType != null) result.bcType = bcType;
    if (switches != null) result.switches.addAll(switches);
    if (distances != null) result.distances.addAll(distances);
    if (coefRows != null) result.coefRows.addAll(coefRows);
    if (caliber != null) result.caliber = caliber;
    if (deviceUuid != null) result.deviceUuid = deviceUuid;
    return result;
  }

  HostProfile._();

  factory HostProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HostProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HostProfile',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'profileName')
    ..aOS(2, _omitFieldNames ? '' : 'cartridgeName')
    ..aOS(3, _omitFieldNames ? '' : 'bulletName')
    ..aOS(4, _omitFieldNames ? '' : 'shortNameTop')
    ..aOS(5, _omitFieldNames ? '' : 'shortNameBot')
    ..aOS(6, _omitFieldNames ? '' : 'userNote')
    ..aI(7, _omitFieldNames ? '' : 'zeroX')
    ..aI(8, _omitFieldNames ? '' : 'zeroY')
    ..aI(9, _omitFieldNames ? '' : 'scHeight')
    ..aI(10, _omitFieldNames ? '' : 'rTwist')
    ..aI(11, _omitFieldNames ? '' : 'cMuzzleVelocity')
    ..aI(12, _omitFieldNames ? '' : 'cZeroTemperature')
    ..aI(13, _omitFieldNames ? '' : 'cTCoeff')
    ..aI(14, _omitFieldNames ? '' : 'cZeroDistanceIdx')
    ..aI(15, _omitFieldNames ? '' : 'cZeroAirTemperature')
    ..aI(16, _omitFieldNames ? '' : 'cZeroAirPressure')
    ..aI(17, _omitFieldNames ? '' : 'cZeroAirHumidity')
    ..aI(18, _omitFieldNames ? '' : 'cZeroWPitch')
    ..aI(19, _omitFieldNames ? '' : 'cZeroPTemperature')
    ..aI(20, _omitFieldNames ? '' : 'bDiameter')
    ..aI(21, _omitFieldNames ? '' : 'bWeight')
    ..aI(22, _omitFieldNames ? '' : 'bLength')
    ..aE<TwistDir>(23, _omitFieldNames ? '' : 'twistDir',
        enumValues: TwistDir.values)
    ..aE<GType>(24, _omitFieldNames ? '' : 'bcType', enumValues: GType.values)
    ..pPM<SwPos>(25, _omitFieldNames ? '' : 'switches',
        subBuilder: SwPos.create)
    ..p<$core.int>(26, _omitFieldNames ? '' : 'distances', $pb.PbFieldType.K3)
    ..pPM<CoefRow>(27, _omitFieldNames ? '' : 'coefRows',
        subBuilder: CoefRow.create)
    ..aOS(28, _omitFieldNames ? '' : 'caliber')
    ..aOS(29, _omitFieldNames ? '' : 'deviceUuid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HostProfile copyWith(void Function(HostProfile) updates) =>
      super.copyWith((message) => updates(message as HostProfile))
          as HostProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HostProfile create() => HostProfile._();
  @$core.override
  HostProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HostProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HostProfile>(create);
  static HostProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get profileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set profileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProfileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cartridgeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set cartridgeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCartridgeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCartridgeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bulletName => $_getSZ(2);
  @$pb.TagNumber(3)
  set bulletName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBulletName() => $_has(2);
  @$pb.TagNumber(3)
  void clearBulletName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get shortNameTop => $_getSZ(3);
  @$pb.TagNumber(4)
  set shortNameTop($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShortNameTop() => $_has(3);
  @$pb.TagNumber(4)
  void clearShortNameTop() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get shortNameBot => $_getSZ(4);
  @$pb.TagNumber(5)
  set shortNameBot($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShortNameBot() => $_has(4);
  @$pb.TagNumber(5)
  void clearShortNameBot() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get userNote => $_getSZ(5);
  @$pb.TagNumber(6)
  set userNote($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserNote() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get zeroX => $_getIZ(6);
  @$pb.TagNumber(7)
  set zeroX($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasZeroX() => $_has(6);
  @$pb.TagNumber(7)
  void clearZeroX() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get zeroY => $_getIZ(7);
  @$pb.TagNumber(8)
  set zeroY($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasZeroY() => $_has(7);
  @$pb.TagNumber(8)
  void clearZeroY() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get scHeight => $_getIZ(8);
  @$pb.TagNumber(9)
  set scHeight($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasScHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearScHeight() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get rTwist => $_getIZ(9);
  @$pb.TagNumber(10)
  set rTwist($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRTwist() => $_has(9);
  @$pb.TagNumber(10)
  void clearRTwist() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get cMuzzleVelocity => $_getIZ(10);
  @$pb.TagNumber(11)
  set cMuzzleVelocity($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCMuzzleVelocity() => $_has(10);
  @$pb.TagNumber(11)
  void clearCMuzzleVelocity() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get cZeroTemperature => $_getIZ(11);
  @$pb.TagNumber(12)
  set cZeroTemperature($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCZeroTemperature() => $_has(11);
  @$pb.TagNumber(12)
  void clearCZeroTemperature() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get cTCoeff => $_getIZ(12);
  @$pb.TagNumber(13)
  set cTCoeff($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCTCoeff() => $_has(12);
  @$pb.TagNumber(13)
  void clearCTCoeff() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get cZeroDistanceIdx => $_getIZ(13);
  @$pb.TagNumber(14)
  set cZeroDistanceIdx($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCZeroDistanceIdx() => $_has(13);
  @$pb.TagNumber(14)
  void clearCZeroDistanceIdx() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get cZeroAirTemperature => $_getIZ(14);
  @$pb.TagNumber(15)
  set cZeroAirTemperature($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCZeroAirTemperature() => $_has(14);
  @$pb.TagNumber(15)
  void clearCZeroAirTemperature() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get cZeroAirPressure => $_getIZ(15);
  @$pb.TagNumber(16)
  set cZeroAirPressure($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasCZeroAirPressure() => $_has(15);
  @$pb.TagNumber(16)
  void clearCZeroAirPressure() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get cZeroAirHumidity => $_getIZ(16);
  @$pb.TagNumber(17)
  set cZeroAirHumidity($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCZeroAirHumidity() => $_has(16);
  @$pb.TagNumber(17)
  void clearCZeroAirHumidity() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get cZeroWPitch => $_getIZ(17);
  @$pb.TagNumber(18)
  set cZeroWPitch($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCZeroWPitch() => $_has(17);
  @$pb.TagNumber(18)
  void clearCZeroWPitch() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get cZeroPTemperature => $_getIZ(18);
  @$pb.TagNumber(19)
  set cZeroPTemperature($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCZeroPTemperature() => $_has(18);
  @$pb.TagNumber(19)
  void clearCZeroPTemperature() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.int get bDiameter => $_getIZ(19);
  @$pb.TagNumber(20)
  set bDiameter($core.int value) => $_setSignedInt32(19, value);
  @$pb.TagNumber(20)
  $core.bool hasBDiameter() => $_has(19);
  @$pb.TagNumber(20)
  void clearBDiameter() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get bWeight => $_getIZ(20);
  @$pb.TagNumber(21)
  set bWeight($core.int value) => $_setSignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasBWeight() => $_has(20);
  @$pb.TagNumber(21)
  void clearBWeight() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.int get bLength => $_getIZ(21);
  @$pb.TagNumber(22)
  set bLength($core.int value) => $_setSignedInt32(21, value);
  @$pb.TagNumber(22)
  $core.bool hasBLength() => $_has(21);
  @$pb.TagNumber(22)
  void clearBLength() => $_clearField(22);

  @$pb.TagNumber(23)
  TwistDir get twistDir => $_getN(22);
  @$pb.TagNumber(23)
  set twistDir(TwistDir value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasTwistDir() => $_has(22);
  @$pb.TagNumber(23)
  void clearTwistDir() => $_clearField(23);

  @$pb.TagNumber(24)
  GType get bcType => $_getN(23);
  @$pb.TagNumber(24)
  set bcType(GType value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasBcType() => $_has(23);
  @$pb.TagNumber(24)
  void clearBcType() => $_clearField(24);

  @$pb.TagNumber(25)
  $pb.PbList<SwPos> get switches => $_getList(24);

  @$pb.TagNumber(26)
  $pb.PbList<$core.int> get distances => $_getList(25);

  @$pb.TagNumber(27)
  $pb.PbList<CoefRow> get coefRows => $_getList(26);

  @$pb.TagNumber(28)
  $core.String get caliber => $_getSZ(27);
  @$pb.TagNumber(28)
  set caliber($core.String value) => $_setString(27, value);
  @$pb.TagNumber(28)
  $core.bool hasCaliber() => $_has(27);
  @$pb.TagNumber(28)
  void clearCaliber() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get deviceUuid => $_getSZ(28);
  @$pb.TagNumber(29)
  set deviceUuid($core.String value) => $_setString(28, value);
  @$pb.TagNumber(29)
  $core.bool hasDeviceUuid() => $_has(28);
  @$pb.TagNumber(29)
  void clearDeviceUuid() => $_clearField(29);
}

class ProfileList extends $pb.GeneratedMessage {
  factory ProfileList({
    $core.Iterable<ProfileListEntry>? profileDesc,
    $core.int? activeprofile,
  }) {
    final result = create();
    if (profileDesc != null) result.profileDesc.addAll(profileDesc);
    if (activeprofile != null) result.activeprofile = activeprofile;
    return result;
  }

  ProfileList._();

  factory ProfileList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProfileList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProfileList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..pPM<ProfileListEntry>(1, _omitFieldNames ? '' : 'profileDesc',
        subBuilder: ProfileListEntry.create)
    ..aI(2, _omitFieldNames ? '' : 'activeprofile')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileList copyWith(void Function(ProfileList) updates) =>
      super.copyWith((message) => updates(message as ProfileList))
          as ProfileList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileList create() => ProfileList._();
  @$core.override
  ProfileList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProfileList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProfileList>(create);
  static ProfileList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProfileListEntry> get profileDesc => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get activeprofile => $_getIZ(1);
  @$pb.TagNumber(2)
  set activeprofile($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveprofile() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveprofile() => $_clearField(2);
}

class ProfileListEntry extends $pb.GeneratedMessage {
  factory ProfileListEntry({
    $core.String? profileName,
    $core.String? cartridgeName,
    $core.String? shortNameTop,
    $core.String? shortNameBot,
    $core.String? filePath,
  }) {
    final result = create();
    if (profileName != null) result.profileName = profileName;
    if (cartridgeName != null) result.cartridgeName = cartridgeName;
    if (shortNameTop != null) result.shortNameTop = shortNameTop;
    if (shortNameBot != null) result.shortNameBot = shortNameBot;
    if (filePath != null) result.filePath = filePath;
    return result;
  }

  ProfileListEntry._();

  factory ProfileListEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProfileListEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProfileListEntry',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'profileName')
    ..aOS(2, _omitFieldNames ? '' : 'cartridgeName')
    ..aOS(3, _omitFieldNames ? '' : 'shortNameTop')
    ..aOS(4, _omitFieldNames ? '' : 'shortNameBot')
    ..aOS(5, _omitFieldNames ? '' : 'filePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileListEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileListEntry copyWith(void Function(ProfileListEntry) updates) =>
      super.copyWith((message) => updates(message as ProfileListEntry))
          as ProfileListEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileListEntry create() => ProfileListEntry._();
  @$core.override
  ProfileListEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProfileListEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProfileListEntry>(create);
  static ProfileListEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get profileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set profileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProfileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cartridgeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set cartridgeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCartridgeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCartridgeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get shortNameTop => $_getSZ(2);
  @$pb.TagNumber(3)
  set shortNameTop($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasShortNameTop() => $_has(2);
  @$pb.TagNumber(3)
  void clearShortNameTop() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get shortNameBot => $_getSZ(3);
  @$pb.TagNumber(4)
  set shortNameBot($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShortNameBot() => $_has(3);
  @$pb.TagNumber(4)
  void clearShortNameBot() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filePath => $_getSZ(4);
  @$pb.TagNumber(5)
  set filePath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilePath() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilePath() => $_clearField(5);
}

class FullProfileData extends $pb.GeneratedMessage {
  factory FullProfileData({
    ProfileList? table,
    $core.Iterable<HostProfile>? profiles,
  }) {
    final result = create();
    if (table != null) result.table = table;
    if (profiles != null) result.profiles.addAll(profiles);
    return result;
  }

  FullProfileData._();

  factory FullProfileData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FullProfileData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FullProfileData',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<ProfileList>(1, _omitFieldNames ? '' : 'table',
        subBuilder: ProfileList.create)
    ..pPM<HostProfile>(2, _omitFieldNames ? '' : 'profiles',
        subBuilder: HostProfile.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FullProfileData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FullProfileData copyWith(void Function(FullProfileData) updates) =>
      super.copyWith((message) => updates(message as FullProfileData))
          as FullProfileData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FullProfileData create() => FullProfileData._();
  @$core.override
  FullProfileData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FullProfileData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FullProfileData>(create);
  static FullProfileData? _defaultInstance;

  @$pb.TagNumber(1)
  ProfileList get table => $_getN(0);
  @$pb.TagNumber(1)
  set table(ProfileList value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTable() => $_has(0);
  @$pb.TagNumber(1)
  void clearTable() => $_clearField(1);
  @$pb.TagNumber(1)
  ProfileList ensureTable() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<HostProfile> get profiles => $_getList(1);
}

class Reticle extends $pb.GeneratedMessage {
  factory Reticle({
    $core.List<$core.int>? data,
    $core.String? folderName,
  }) {
    final result = create();
    if (data != null) result.data = data;
    if (folderName != null) result.folderName = folderName;
    return result;
  }

  Reticle._();

  factory Reticle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Reticle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reticle',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'folderName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reticle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reticle copyWith(void Function(Reticle) updates) =>
      super.copyWith((message) => updates(message as Reticle)) as Reticle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reticle create() => Reticle._();
  @$core.override
  Reticle createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Reticle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reticle>(create);
  static Reticle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get folderName => $_getSZ(1);
  @$pb.TagNumber(2)
  set folderName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFolderName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFolderName() => $_clearField(2);
}

class Reticles extends $pb.GeneratedMessage {
  factory Reticles({
    $core.Iterable<Reticle>? rets,
  }) {
    final result = create();
    if (rets != null) result.rets.addAll(rets);
    return result;
  }

  Reticles._();

  factory Reticles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Reticles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reticles',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..pPM<Reticle>(1, _omitFieldNames ? '' : 'rets', subBuilder: Reticle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reticles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reticles copyWith(void Function(Reticles) updates) =>
      super.copyWith((message) => updates(message as Reticles)) as Reticles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reticles create() => Reticles._();
  @$core.override
  Reticles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Reticles getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reticles>(create);
  static Reticles? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Reticle> get rets => $_getList(0);
}

class Payload extends $pb.GeneratedMessage {
  factory Payload({
    HostProfile? profile,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    return result;
  }

  Payload._();

  factory Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Payload',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'archer_protocol'),
      createEmptyInstance: create)
    ..aOM<HostProfile>(1, _omitFieldNames ? '' : 'profile',
        subBuilder: HostProfile.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload copyWith(void Function(Payload) updates) =>
      super.copyWith((message) => updates(message as Payload)) as Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Payload create() => Payload._();
  @$core.override
  Payload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Payload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Payload>(create);
  static Payload? _defaultInstance;

  @$pb.TagNumber(1)
  HostProfile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(HostProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  HostProfile ensureProfile() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
