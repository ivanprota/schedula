import 'package:flutter/material.dart';
import 'package:schedula/models/appointment.dart';
import 'package:schedula/services/appointment_service.dart';
import 'package:schedula/widgets/appointment_container.dart';

class MyBookingsPage extends StatefulWidget {
  final int userId;

  const MyBookingsPage({
    super.key,
    required this.userId,
  });

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AppointmentService appointmentService = AppointmentService();

  late Future<List<Appointment>> futureUserBookings;
  late Future<List<Appointment>> futureOwnerBookings;

  int get ownerId => widget.userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    futureUserBookings =
        appointmentService.getAppointmentsForUser(widget.userId);

    futureOwnerBookings =
        appointmentService.getAppointmentsForOwner(ownerId);
  }

  void refreshUserBookings() {
    setState(() {
      futureUserBookings =
          appointmentService.getAppointmentsForUser(widget.userId);
    });
  }

  void refreshOwnerBookings() {
    setState(() {
      futureOwnerBookings =
          appointmentService.getAppointmentsForOwner(ownerId);
    });
  }

  /// 🔥 Utility per classificare le date
  String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) return "Oggi";
    if (difference == 1) return "Domani";
    if (difference <= 7) return "Questa settimana";
    return "Più avanti";
  }

  /// 🔥 Widget per prenotazioni ricevute (raggruppate per giorno)
  Widget _buildReceivedBookings(List<Appointment> appointments) {
    // Ordina dalla più vicina alla più lontana
    appointments.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));

    // Raggruppa
    final Map<String, List<Appointment>> groups = {};

    for (var a in appointments) {
      final label = groupLabel(a.getDateTime());
      groups.putIfAbsent(label, () => []);
      groups[label]!.add(a);
    }

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo: "Oggi", "Domani", ...
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                entry.key,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ...entry.value.map((a) {
              return AppointmentContainer(
                activityName: a.service.business.name,
                serviceName: a.service.name,
                date: a.getDateTime(),
                status: a.status.toString().split('.').last,
                extraInfo:
                    "${a.user?.firstName ?? ''} ${a.user?.lastName ?? ''}".trim(),
                onCancel: null, // Non si annullano ricevute
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  /// 🔥 Widget riutilizzabile per la tab Effettuate
  Widget _buildMadeBookings(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(
          child: Text("Nessuna prenotazione.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final a = appointments[index];

        return AppointmentContainer(
          activityName: a.service.business.name,
          serviceName: a.service.name,
          date: a.getDateTime(),
          status: a.status.toString().split('.').last,
          onCancel: () async {
            final confirm = await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Conferma"),
                content:
                    const Text("Vuoi davvero cancellare questa prenotazione?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Sì")),
                ],
              ),
            );

            if (confirm == true) {
              await appointmentService.cancelAppointment(a.id);
              refreshUserBookings();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prenotazioni"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: const [
            Tab(text: "Effettuate"),
            Tab(text: "Ricevute"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // ------------------- EFFETTUATE -------------------
          FutureBuilder<List<Appointment>>(
            future: futureUserBookings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child:
                        Text("Errore: ${snapshot.error}", textAlign: TextAlign.center));
              }

              return _buildMadeBookings(snapshot.data ?? []);
            },
          ),

          // ------------------- RICEVUTE -------------------
          FutureBuilder<List<Appointment>>(
            future: futureOwnerBookings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child:
                        Text("Errore: ${snapshot.error}", textAlign: TextAlign.center));
              }

              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(
                    child: Text("Nessuna prenotazione ricevuta.",
                        style: TextStyle(fontSize: 18)));
              }

              return _buildReceivedBookings(data);
            },
          ),
        ],
      ),
    );
  }
}
