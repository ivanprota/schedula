import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentContainer extends StatelessWidget {
  final String activityName;
  final String serviceName;
  final DateTime date;
  final String status;

  final String? extraInfo;   // 👈 AGGIUNTO
  final VoidCallback? onCancel;

  const AppointmentContainer({
    super.key,
    required this.activityName,
    required this.serviceName,
    required this.date,
    required this.status,
    this.extraInfo,          // 👈 AGGIUNTO
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat("dd/MM/yyyy • HH:mm").format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activityName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              serviceName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            if (extraInfo != null) ...[
              const SizedBox(height: 4),
              Text(
                extraInfo!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                Text(
                  status,
                  style: TextStyle(
                    color: status.toLowerCase() == "cancelled"
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (onCancel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    "Cancella",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
