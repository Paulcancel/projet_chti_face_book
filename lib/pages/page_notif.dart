import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

import '../modeles/membre.dart';
import '../modeles/notif.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/widget_vide.dart';
import '../widgets/widget_notif.dart';
import 'page_detail_post.dart';

class PageNotif extends StatelessWidget {
  const PageNotif({
    super.key,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
  });

  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationMembre>>(
      stream: firestoreService.notificationsForUser(membreConnecte.id),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <NotificationMembre>[];
        if (notifications.isEmpty) {
          return const EmptyBody(
            icon: Icons.notifications_outlined,
            message: Jargon.aucuneNotification,
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
                  label: const Text("J'ai tout vu"),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return WidgetNotif(
                    notification: notification,
                    onTap:
                        notification.postId == null
                            ? null
                            : () => _ouvrirPost(context, notification),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ouvrirPost(
    BuildContext context,
    NotificationMembre notification,
  ) async {
    firestoreService.marquerNotificationLue(notification.id);

    final postId = notification.postId;
    if (postId == null) {
      return;
    }

    final post = await firestoreService.postParId(postId);
    if (!context.mounted) {
      return;
    }

    if (post == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cette racontache n'existe plus.")),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PageDetailPost(
              post: post,
              membreConnecte: membreConnecte,
              firestoreService: firestoreService,
              storageService: storageService,
            ),
      ),
    );
  }
}
