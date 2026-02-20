import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:schedula/models/business.dart';
import 'package:schedula/models/business_service.dart';
import 'package:schedula/models/appointment.dart';

import 'package:schedula/services/service_service.dart';
import 'package:schedula/services/appointment_service.dart';

class BookingPage extends StatefulWidget {
  final Business business;
  final VoidCallback onCloseExtraPage;
  final int userId;

  const BookingPage({
    super.key,
    required this.business,
    required this.onCloseExtraPage,
    required this.userId
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ServiceService serviceService = ServiceService();
  final AppointmentService appointmentService = AppointmentService();

  List<BusinessService> services = [];
  BusinessService? selectedService;

  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  List<DateTime> availableSlots = [];

  bool isLoadingServices = true;
  bool isLoadingSlots = false;
  String? servicesError;
  String? slotsError;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final data =
          await serviceService.getServicesOfBusiness(widget.business.id);
      setState(() {
        services = data;
        isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        isLoadingServices = false;
        servicesError = "Errore nel caricamento dei servizi: $e";
      });
    }
  }

  Future<void> _loadSlots() async {
    if (selectedDate == null || selectedService == null) return;

    setState(() {
      isLoadingSlots = true;
      slotsError = null;
      availableSlots = [];
    });

    try {
      final List<Appointment> appointments =
          await appointmentService.getAppointmentsForBusiness(
        widget.business.id,
        selectedDate!,
      );

      // Converto le prenotazioni in DateTime completi (data + ora)
      final List<DateTime> occupiedTimes = appointments.map((a) {
        // a.date = "2025-03-10", a.time = "10:30:00"
        return DateTime.parse("${a.date}T${a.time}");
      }).toList();

      final List<DateTime> slots = [];

      // Orario di lavoro temporaneo: 09:00 - 18:00
      DateTime start = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        9,
        0,
      );

      final DateTime end = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        18,
        0,
      );

      // Durata servizio (fallback 30 min se null)
      final int duration =
          selectedService!.durationMinutes ?? 30; // durata standard se null

      while (start.isBefore(end)) {
        final DateTime slotEnd = start.add(Duration(minutes: duration));

        // Controllo sovrapposizioni con le prenotazioni esistenti
        final bool overlaps = occupiedTimes.any((occupied) {
          final DateTime occEnd =
              occupied.add(Duration(minutes: duration)); // semplificazione
          return start.isBefore(occEnd) && slotEnd.isAfter(occupied);
        });

        if (!overlaps) {
          slots.add(start);
        }

        // Slot successivo a catena
        start = start.add(Duration(minutes: duration));
      }

      setState(() {
        availableSlots = slots;
        isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSlots = false;
        slotsError = "Errore nel caricamento degli orari: $e";
      });
    }
  }

  Future<void> _confirmBooking(DateTime slot) async {
    try {
      await appointmentService.createAppointment(
        businessId: widget.business.id,
        serviceId: selectedService!.id,
        date: selectedDate!,
        time: slot,
        userId: widget.userId
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Prenotazione effettuata"),
          content: Text(
            "Hai prenotato ${selectedService!.name} per il "
            "${selectedDate!.day.toString().padLeft(2, '0')}/"
            "${selectedDate!.month.toString().padLeft(2, '0')}/"
            "${selectedDate!.year} alle "
            "${slot.hour.toString().padLeft(2, '0')}:"
            "${slot.minute.toString().padLeft(2, '0')}.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCloseExtraPage();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Errore"),
          content: Text("Non è stato possibile completare la prenotazione: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onCloseExtraPage,
        ),
        title: Text(business.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FOTO ATTIVITÀ
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              business.photoUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // INFORMAZIONI BASE
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  business.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SCELTA SERVIZIO
          const Text(
            "Scegli un servizio",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (isLoadingServices)
            const Center(child: CircularProgressIndicator())
          else if (servicesError != null)
            Text(
              servicesError!,
              style: const TextStyle(color: Colors.red),
            )
          else
            DropdownButtonFormField<BusinessService>(
              value: selectedService,
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                  selectedDate = null;
                  availableSlots = [];
                });
              },
              items: services
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        "${s.name} (${(s.durationMinutes ?? 30)} min)",
                      ),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // CALENDARIO
          const Text(
            "Scegli una data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          IgnorePointer(
            ignoring: selectedService == null,
            child: Opacity(
              opacity: selectedService == null ? 0.4 : 1.0,
              child: TableCalendar(
                focusedDay: focusedDay,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) =>
                    selectedDate != null && isSameDay(day, selectedDate!),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDate = selected;
                    focusedDay = focused;
                  });
                  _loadSlots();
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ORARI DISPONIBILI
          const Text(
            "Orari disponibili",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (slotsError != null)
            Text(
              slotsError!,
              style: const TextStyle(color: Colors.red),
            )
          else if (isLoadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (selectedService == null || selectedDate == null)
            const Text("Seleziona prima un servizio e una data.")
          else if (availableSlots.isEmpty)
            const Text("Nessun orario disponibile per questa data.")
          else
            Column(
              children: availableSlots.map((slot) {
                final String formatted =
                    "${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}";

                return Card(
                  child: ListTile(
                    title: Text(formatted),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmBooking(slot),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
