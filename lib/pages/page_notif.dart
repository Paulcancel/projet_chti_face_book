import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../modeles/notification_membre.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/empty_body.dart';
import '../widgets/widget_notif.dart';

class PageNotif extends StatelessWidget {
  const PageNotif({
    super.key,
    required this.membreConnecte,
    required this.firestoreService,
  });

  final Membre membreConnecte;
  final ServiceFirestore firestoreService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationMembre>>(
      stream: firestoreService.notificationsForUser(membreConnecte.id),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <NotificationMembre>[];
        if (notifications.isEmpty) {
          return const EmptyBody(
            icon: Icons.notifications_outlined,
            message: 'Aucune notification.',
          );
        }

        return Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextButton.icon(
                  onPressed: () {
                    firestoreService.marquerNotificationsLues(
                      membreConnecte.id,
                    );
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Tout marquer comme lu'),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return WidgetNotif(notification: notifications[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
