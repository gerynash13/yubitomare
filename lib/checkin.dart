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

const planActions = ['charge', 'water', 'focus', 'tiny'];

String planActionLabel(AppLocalizations l, String id) {
  switch (id) {
    case 'charge':
      return l.planActCharge;
    case 'water':
      return l.planActWater;
    case 'focus':
      return l.planActFocus;
    default:
      return l.planActTiny;
  }
}

String planSentence(AppLocalizations l, String app, String actionId) =>
    l.planSentence(app, planActionLabel(l, actionId));