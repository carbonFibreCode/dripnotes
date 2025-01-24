import 'package:dripnotes/utilities/dialog/showGenericDialog.dart';
import 'package:flutter/cupertino.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'Sent you a password reset link, please check your Email for more information',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
