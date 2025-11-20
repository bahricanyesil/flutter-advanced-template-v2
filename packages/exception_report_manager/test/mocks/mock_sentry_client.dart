// ignore_for_file: avoid-dynamic

import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final class MockSentryClient with Mock implements SentryClient {
  List<CaptureEventCall> captureEventCalls = <CaptureEventCall>[];
  List<CaptureExceptionCall> captureExceptionCalls = <CaptureExceptionCall>[];
  List<CaptureMessageCall> captureMessageCalls = <CaptureMessageCall>[];
  List<CaptureEnvelopeCall> captureEnvelopeCalls = <CaptureEnvelopeCall>[];
  List<CaptureTransactionCall> captureTransactionCalls =
      <CaptureTransactionCall>[];
  List<SentryFeedback> userFeedbackCalls = <SentryFeedback>[];
  int closeCalls = 0;

  @override
  Future<SentryId> captureEvent(
    SentryEvent event, {
    Scope? scope,
    dynamic stackTrace,
    dynamic hint,
  }) async {
    captureEventCalls.add(
      CaptureEventCall(
        event,
        scope,
        stackTrace,
        hint,
      ),
    );
    return event.eventId;
  }

  @override
  Future<SentryId> captureMessage(
    String? formatted, {
    SentryLevel? level = SentryLevel.info,
    String? template,
    List<dynamic>? params,
    Scope? scope,
    dynamic hint,
  }) async {
    captureMessageCalls.add(
      CaptureMessageCall(
        formatted,
        level,
        template,
        params,
        scope,
        hint,
      ),
    );
    return SentryId.newId();
  }

  @override
  Future<SentryId> captureEnvelope(SentryEnvelope envelope) async {
    captureEnvelopeCalls.add(CaptureEnvelopeCall(envelope));
    return envelope.header.eventId ?? SentryId.newId();
  }

  @override
  Future<SentryId> captureFeedback(
    SentryFeedback userFeedback, {
    Hint? hint,
    Scope? scope,
  }) async {
    userFeedbackCalls.add(userFeedback);
    return userFeedback.associatedEventId ?? SentryId.newId();
  }

  @override
  void close() {
    closeCalls = closeCalls + 1;
  }

  @override
  Future<SentryId> captureTransaction(
    SentryTransaction transaction, {
    Hint? hint,
    Scope? scope,
    SentryTraceContextHeader? traceContext,
  }) async {
    captureTransactionCalls
        .add(CaptureTransactionCall(transaction, traceContext));
    return transaction.eventId;
  }
}

class CaptureEventCall {
  CaptureEventCall(
    this.event,
    this.scope,
    this.stackTrace,
    this.hint,
  );
  final SentryEvent event;
  final Scope? scope;
  final dynamic stackTrace;
  final dynamic hint;
}

class CaptureExceptionCall {
  CaptureExceptionCall(
    this.throwable,
    this.stackTrace,
    this.scope,
    this.hint,
  );
  final dynamic throwable;
  final dynamic stackTrace;
  final Scope? scope;
  final dynamic hint;
}

class CaptureMessageCall {
  CaptureMessageCall(
    this.formatted,
    this.level,
    this.template,
    this.params,
    this.scope,
    this.hint,
  );
  final String? formatted;
  final SentryLevel? level;
  final String? template;
  final List<dynamic>? params;
  final Scope? scope;
  final dynamic hint;
}

class CaptureEnvelopeCall {
  CaptureEnvelopeCall(this.envelope);
  final SentryEnvelope envelope;
}

class CaptureTransactionCall {
  CaptureTransactionCall(this.transaction, this.traceContext);
  final SentryTransaction transaction;
  final SentryTraceContextHeader? traceContext;
}

mixin NoSuchMethodProvider {
  @override
  void noSuchMethod(Invocation invocation) {
    // ignore: unnecessary_statements
    'Method ${invocation.memberName} was called '
        'with arguments ${invocation.positionalArguments}';
  }
}
