import 'package:flutter/material.dart';

import '../modeles/donnees.dart';
import '../modeles/notif.dart';

class WidgetNotif extends StatelessWidget {
  const WidgetNotif({super.key, required this.notification, this.onTap});

  final NotificationMembre notification;
  final VoidCallback? onTap;

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
      onTap: onTap,
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
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}
