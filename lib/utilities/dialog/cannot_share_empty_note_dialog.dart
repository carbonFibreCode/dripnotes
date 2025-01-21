import 'package:flutter/cupertino.dart';
import 'package:dripnotes/utilities/dialog/showGenericDialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You Cannot share an Empty note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
