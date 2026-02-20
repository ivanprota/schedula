enum AppointmentsStatus {
  BOOKED,
  CANCELLED,
  COMPLETED,
}

AppointmentsStatus statusFromString(String value) {
  return AppointmentsStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value);
}

String statusToString(AppointmentsStatus status) {
  return status.toString().split('.').last;
}

// Nota: necessario split.last in quanto quando accediamo ad un elemento dell'enum questo 
//lo abbiamo nella forma AppointmentsStatus.qualcosa