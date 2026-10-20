import 'l10n/app_localizations.dart';

const checkinReasons = ['tired', 'bored', 'auto', 'notif'];

String reasonLabel(AppLocalizations l, String id) {
  switch (id) {
    case 'tired':
      return l.ciTired;
    case 'bored':
      return l.ciBored;
    case 'auto':
      return l.ciAuto;
    default:
      return l.ciNotif;
  }
}

String reasonReply(AppLocalizations l, String id) {
  switch (id) {
    case 'tired':
      return l.ciReplyTired;
    case 'bored':
      return l.ciReplyBored;
    case 'auto':
      return l.ciReplyAuto;
    default:
      return l.ciReplyNotif;
  }
}