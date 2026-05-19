import 'package:flutter/material.dart';

import '../modeles/date_heure.dart';
import '../modeles/notification_membre.dart';

class WidgetNotif extends StatelessWidget {
  const WidgetNotif({super.key, required this.notification});

  final NotificationMembre notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (notification.type) {
      'like' => Icons.star_rounded,
      'commentaire' => Icons.mode_comment_outlined,
      'post' => Icons.article_outlined,
      _ => Icons.notifications_outlined,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            notification.lue
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primaryContainer,
        child: Icon(
          icon,
          color:
              notification.lue
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        notification.message,
        style: TextStyle(
          fontWeight: notification.lue ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Text(DateHeure.relative(notification.dateCreation)),
    );
  }
}
