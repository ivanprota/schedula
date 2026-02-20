import 'package:flutter/material.dart';
import 'package:schedula/models/business.dart';
import 'package:schedula/pages/activity_settings_page.dart';
import 'package:schedula/services/business_service.dart';
import 'package:schedula/widgets/activity_container.dart';

class MyActivitiesPage extends StatelessWidget {
  final int userId;
  final BusinessService businessService = BusinessService();
  final Function(Widget) onOpenExtraPage;
  final VoidCallback onCloseExtraPage;

  MyActivitiesPage({
    super.key,
    required this.userId,
    required this.onOpenExtraPage,
    required this.onCloseExtraPage,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Caso utente non loggato
    if (userId == -1) {
      return const Center(
        child: Text(
          "Devi effettuare l'accesso per visualizzare le tue attività",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF7F7F7),
      child: FutureBuilder<List<Business>>(
        future: businessService.getOwnedBusinesses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          }

          final businesses = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔥 Se non ci sono attività → mostra messaggio
                if (businesses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      "Non hai ancora attività",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 🔥 Lista attività (anche vuota, ma non produce item)
                Expanded(
                  child: ListView.builder(
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      return ActivityContainer(
                        business: businesses[index],
                        onOpenExtraPage: onOpenExtraPage,
                        onCloseExtraPage: onCloseExtraPage,
                        wasCalledByHomePage: false,
                        wasCalledByActivitiesPage: true,
                        userId: userId,
                      );
                    },
                  ),
                ),

                // 🔥 Pulsante SEMPRE visibile
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onOpenExtraPage(
                        ActivitySettingsPage(
                          onCloseExtraPage: onCloseExtraPage,
                          ownerId: userId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_business, color: Colors.white),
                    label: const Text(
                      "Aggiungi nuova attività",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
