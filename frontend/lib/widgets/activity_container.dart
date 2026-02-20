import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:schedula/models/business.dart';
import 'package:schedula/pages/activity_settings_page.dart';
import 'package:schedula/pages/booking_page.dart';

class ActivityContainer extends StatelessWidget {
  final Business business;
  final Function(Widget) onOpenExtraPage;
  final VoidCallback onCloseExtraPage;
  final bool wasCalledByHomePage;
  final bool wasCalledByActivitiesPage;
  final int userId;

  const ActivityContainer({
    super.key,
    required this.business,
    required this.onOpenExtraPage,
    required this.onCloseExtraPage,
    required this.wasCalledByHomePage,
    required this.wasCalledByActivitiesPage,
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (wasCalledByHomePage) {
            onOpenExtraPage(
              BookingPage(
                business: business, 
                onCloseExtraPage: onCloseExtraPage,
                userId: userId,
              ),
            );
          } else {
            onOpenExtraPage(
              ActivitySettingsPage(
                business: business,
                onCloseExtraPage: onCloseExtraPage,
                ownerId: userId,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: business.photoUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          business.address,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}   
