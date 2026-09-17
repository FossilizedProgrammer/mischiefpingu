library;

mixin ProcessNotificationMessages {
  String? get pendingPortConflictMessage;
  set pendingPortConflictMessage(String? v);
  void setPortConflictMessage(String message);
  void clearPortConflictMessage();

  String? get pendingBinaryMissingMessage;
  set pendingBinaryMissingMessage(String? v);
  void setBinaryMissingMessage(String message);
  void clearBinaryMissingMessage();

  String? get pendingSadNotification;
  set pendingSadNotification(String? v);
  DateTime? get pendingSadTimestamp;
  set pendingSadTimestamp(DateTime? v);
  void setSadNotification(String tunnelName);
  void clearSadNotification();

  String? get pendingHappyNotification;
  set pendingHappyNotification(String? v);
  DateTime? get pendingHappyTimestamp;
  set pendingHappyTimestamp(DateTime? v);
  void setHappyNotification(String tunnelName);
  void clearHappyNotification();
}
