library;

import 'process_tunnel_state.dart';
import 'process_protocol_state.dart';
import 'process_notification_messages.dart';

mixin ProcessNotifications
    implements
        ProcessTunnelState,
        ProcessProtocolState,
        ProcessNotificationMessages {}
