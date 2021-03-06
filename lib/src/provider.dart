///  Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of flutter_callkit_voximplant;

/// Signature for callbacks reporting when the provider begins.
///
/// Used in [FCXProvider].
typedef void FCXProviderDidBegin();

/// Signature for callbacks reporting when the provider is reset.
///
/// Used in [FCXProvider].
typedef void FCXProviderDidReset();

/// Signature for callbacks reporting when a transaction
/// is executed by a call controller.
///
/// Return value: true if the transaction was handled; otherwise false.
///
/// Most subscribers should not need to provide an implementation
/// for this method. However, a subscriber can implement this method
/// to customize how transactions are handled.
///
/// This method returns true to indicate that the custom implementation
/// handled the transaction and returns false to have the provider execute
/// the transaction normally—as if the subscriber did not implement this method.
///
/// For example, given a transaction consisting of a
/// [FCXSetHeldCallAction] object and a [FCXSetGroupCallAction] object,
/// the subscriber may override this method to inject a 30 second wait
/// and play hold music to the caller.
///
/// Used in [FCXProvider].
typedef bool FCXExecuteTransaction(FCXTransaction transaction);

/// Signature for callbacks reporting when the provider
/// performs the specified start call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformStartCallAction(FCXStartCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified answer call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformAnswerCallAction(FCXAnswerCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified end call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformEndCallAction(FCXEndCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified set held call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformSetHeldCallAction(FCXSetHeldCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified set muted call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformSetMutedCallAction(FCXSetMutedCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified set group call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformSetGroupCallAction(FCXSetGroupCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified play DTMF (dual tone multifrequency) call action.
///
/// Used in [FCXProvider].
typedef void FCXPerformPlayDTMFCallAction(FCXPlayDTMFCallAction action);

/// Signature for callbacks reporting when the provider
/// performs the specified action times out.
///
/// Depending on the action, a timeout may also force the call to end.
/// An action that has already timed out should not be fulfilled
/// or failed by the provider delegate.
///
/// Used in [FCXProvider].
typedef void FCXTimedOutPerformingAction(FCXAction action);

/// Signature for callbacks reporting when the provider’s
/// audio session is activated.
///
/// Used in [FCXProvider].
typedef void FCXProviderDidActivateAudioSession();

/// Signature for callbacks reporting when the provider’s
/// audio session is deactivated.
///
/// Used in [FCXProvider].
typedef void FCXProviderDidDeactivateAudioSession();

/// Reasons for a call to end, as reported by the [FCXProvider.reportCallEnded].
///
/// Used in [FCXProvider.reportCallEnded].
enum FCXCallEndedReason {
  /// An error occurred while trying to service the call.
  failed,

  /// The remote party explicitly ended the call.
  remoteEnded,

  /// The call never started connecting and was never
  /// explicitly ended (e.g. outgoing/incoming call timeout).
  unanswered,

  /// The call was answered on another device.
  answeredElsewhere,

  /// The call was declined on another device.
  declinedElsewhere
}

/// Dart representation of CXProvider from iOS CallKit Framework.
///
/// A [FCXProvider] object is responsible for reporting out-of-band
/// notifications that occur to the system.
///
/// A VoIP app should create only one instance of [FCXProvider] and store it
/// for use globally.
///
/// A [FCXProvider] object is initialized with a [FCXProviderConfiguration]
/// object to specify the behavior and capabilities of calls.
///
/// Each provider has callbacks to respond to events, such as the call starting,
/// the call being put on hold, or the provider’s audio session being activated.
///
/// A [FCXProvider] object is ready to use after initialized and
/// configured using [configure].
///
/// [FCXProvider] is not intended for subclassing.
class FCXProvider {
  /// Callback for getting notified when the provider begins.
  FCXProviderDidBegin providerDidBegin;

  /// Callback for getting notified when the provider is reset.
  FCXProviderDidReset providerDidReset;

  /// Callback for getting notified when a transaction
  /// is executed by a call controller.
  FCXExecuteTransaction executeTransaction;

  /// Callback for getting notified when the provider
  /// performs the specified start call action.
  FCXPerformStartCallAction performStartCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified answer call action.
  FCXPerformAnswerCallAction performAnswerCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified end call action.
  FCXPerformEndCallAction performEndCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified set held call action.
  FCXPerformSetHeldCallAction performSetHeldCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified set muted call action.
  FCXPerformSetMutedCallAction performSetMutedCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified set group call action.
  FCXPerformSetGroupCallAction performSetGroupCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified play DTMF (dual tone multifrequency)
  /// call action.
  FCXPerformPlayDTMFCallAction performPlayDTMFCallAction;

  /// Callback for getting notified when the provider
  /// performs the specified action times out.
  FCXTimedOutPerformingAction timedOutPerformingAction;

  /// Callback for getting notified when the provider’s
  /// audio session is activated.
  FCXProviderDidActivateAudioSession providerDidActivateAudioSession;

  /// Callback for getting notified when the provider’s
  /// audio session is deactivated.
  FCXProviderDidDeactivateAudioSession providerDidDeactivateAudioSession;

  /// The configuration of the provider.
  /// To change the configuration use [FCXProvider.configure].
  FCXProviderConfiguration get configuration => _configuration;
  FCXProviderConfiguration _configuration;

  /// Configure provider with the specified configuration.
  Future<void> configure(FCXProviderConfiguration configuration) async {
    try {
      await _methodChannel.invokeMethod(
        '$_PROVIDER.configure',
        configuration._toMap(),
      );
      _configuration = configuration;
      _FCXLog._i('${runtimeType.toString()}.configure');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Returns all transactions that are not yet completed.
  Future<List<FCXTransaction>> getPendingTransactions() async {
    try {
      var data = await _methodChannel.invokeListMethod<Map>(
        '$_PROVIDER.getPendingTransactions',
      );
      _FCXLog._i('${runtimeType.toString()}.getPendingTransactions');
      return data.map((f) => FCXTransaction._fromMap(f)).toList();
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Report a new incoming call to the system.
  ///
  /// If CallKit error received,
  /// the incoming call has been disallowed by the system and
  /// will not be displayed, so the provider should not proceed with the call.
  ///
  /// [uuid] is the unique identifier of the call.
  ///
  /// [update] is the information for the call.
  Future<void> reportNewIncomingCall(String uuid, FCXCallUpdate update) async {
    try {
      await _methodChannel.invokeMethod(
        '$_PROVIDER.reportNewIncomingCall',
        {'uuid': uuid, 'callUpdate': update?._toMap()},
      );
      _FCXLog._i('${runtimeType.toString()}.reportNewIncomingCall');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Reports to the provider that an active call updated its information.
  ///
  /// [uuid] is the unique identifier of the call.
  ///
  /// [update] is the updated information.
  Future<void> reportCallUpdated(String uuid, FCXCallUpdate update) async {
    try {
      await _methodChannel.invokeMethod(
        '$_PROVIDER.reportCallUpdated',
        {'uuid': uuid, 'callUpdate': update?._toMap()},
      );
      _FCXLog._i('${runtimeType.toString()}.reportCall');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Reports to the provider that a call with the specified identifier
  /// ended at a given date for a particular reason.
  ///
  /// [uuid] is the unique identifier of the call.
  ///
  /// [dateEnded] is the time at which the call ended.
  /// If null, the current time is used.
  ///
  /// [endedReason] is the reason that the call ended.
  Future<void> reportCallEnded(
    String uuid,
    DateTime dateEnded,
    FCXCallEndedReason endedReason,
  ) async {
    try {
      await _methodChannel.invokeMethod('$_PROVIDER.reportCallEnded', {
        'uuid': uuid,
        'dateEnded': dateEnded?.toIso8601String(),
        'endedReason': endedReason?.index ?? FCXCallEndedReason.failed,
      });
      _FCXLog._i('${runtimeType.toString()}.reportCallEnded');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Reports to the provider that an outgoing call with the specified unique
  /// identifier started connecting at a particular time.
  ///
  /// [uuid] is the unique identifier of the call.
  ///
  /// [dateStartedConnecting] is the time at which the call started connecting.
  /// If null, the current time is used.
  Future<void> reportOutgoingCall(
    String uuid,
    DateTime dateStartedConnecting,
  ) async {
    try {
      await _methodChannel.invokeMethod('$_PROVIDER.reportOutgoingCall', {
        'uuid': uuid,
        'dateStartedConnecting': dateStartedConnecting?.toIso8601String(),
      });
      _FCXLog._i('${runtimeType.toString()}.reportOutgoingCall');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Reports to the provider that an outgoing call with the specified unique
  /// identifier finished connecting at a particular time.
  ///
  /// [uuid] is the unique identifier of the call.
  ///
  /// [dateConnected] is the time at which the call connected.
  /// If null, the current time is used.
  ///
  /// A call is considered connected when
  /// both caller and callee can start communicating.
  Future<void> reportOutgoingCallConnected(
    String uuid,
    DateTime dateConnected,
  ) async {
    try {
      await _methodChannel.invokeMethod(
        '$_PROVIDER.reportOutgoingCallConnected',
        {'uuid': uuid, 'dateConnected': dateConnected?.toIso8601String()},
      );
      _FCXLog._i('${runtimeType.toString()}.reportOutgoingCallConnected');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  /// Invalidates the provider and completes all active calls with an error.
  ///
  /// After invalidation, no additional messages are sent to callbacks.
  ///
  /// The provider must be invalidated before it is deallocated.
  Future<void> invalidate() async {
    try {
      await _methodChannel.invokeMethod('$_PROVIDER.invalidate');
      _FCXLog._i('${runtimeType.toString()}.invalidate');
    } on PlatformException catch (e) {
      var exception = FCXException(e.code, e.message);
      _FCXLog._e(exception);
      throw exception;
    }
  }

  factory FCXProvider() => _cache ?? FCXProvider._internal();
  static FCXProvider _cache;

  FCXProvider._internal() {
    EventChannel('plugins.voximplant.com/provider_events')
        .receiveBroadcastStream()
        .listen(_eventListener);
    _cache = this;
  }

  void _eventListener(dynamic event) async {
    final Map<dynamic, dynamic> map = event;
    final String eventName = map['event'];

    _FCXLog._i('${runtimeType.toString()}.$eventName');

    if (eventName == 'providerDidBegin') {
      if (providerDidBegin != null) {
        providerDidBegin();
      }
    } else if (eventName == 'providerDidReset') {
      if (providerDidReset != null) {
        providerDidReset();
      }
    } else if (eventName == 'timedOutPerformingAction') {
      if (timedOutPerformingAction != null) {
        final FCXAction action =
            _FCXActionMapDecodable._makeAction(map['action']);
        timedOutPerformingAction(action);
      }
    } else if (eventName == 'didActivateAudioSession') {
      if (providerDidActivateAudioSession != null) {
        providerDidActivateAudioSession();
      }
    } else if (eventName == 'didDeactivateAudioSession') {
      if (providerDidDeactivateAudioSession != null) {
        providerDidDeactivateAudioSession();
      }
    } else if (eventName == 'executeTransaction') {
      FCXTransaction transaction = FCXTransaction._fromMap(map['transaction']);
      if (executeTransaction == null || !executeTransaction(transaction)) {
        _passActions(transaction);
      }
    }
  }

  Future<void> _passActions(FCXTransaction transaction) async {
    List<FCXAction> actions = await transaction.getActions();
    actions.forEach((a) {
      _FCXLog._i('${runtimeType.toString()}.${a.runtimeType.toString()}');
      if (a is FCXStartCallAction && performStartCallAction != null)
        performStartCallAction(a);
      else if (a is FCXAnswerCallAction && performAnswerCallAction != null)
        performAnswerCallAction(a);
      else if (a is FCXEndCallAction && performEndCallAction != null)
        performEndCallAction(a);
      else if (a is FCXSetHeldCallAction && performSetHeldCallAction != null)
        performSetHeldCallAction(a);
      else if (a is FCXSetMutedCallAction && performSetMutedCallAction != null)
        performSetMutedCallAction(a);
      else if (a is FCXSetGroupCallAction && performSetGroupCallAction != null)
        performSetGroupCallAction(a);
      else if (a is FCXPlayDTMFCallAction && performPlayDTMFCallAction != null)
        performPlayDTMFCallAction(a);
      else {
        FCXException exception = FCXException('Wrong action type',
            'cant apply action ${a.runtimeType.toString()} ${a.uuid}');
        _FCXLog._e(exception);
        throw exception;
      }
    });
  }
}
