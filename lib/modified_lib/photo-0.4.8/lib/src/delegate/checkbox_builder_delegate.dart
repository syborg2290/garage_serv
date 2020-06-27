import 'package:flutter/material.dart' hide CheckboxListTile;
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/provider/i18n_provider.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/ui/widget/check_tile_copy.dart';

abstract class CheckBoxBuilderDelegate {
  Widget buildCheckBox(
    BuildContext context,
    bool checked,
    int index,
    Options options,
    I18nProvider i18nProvider,
  );
}

class DefaultCheckBoxBuilderDelegate extends CheckBoxBuilderDelegate {
  Color activeColor;
  Color unselectedColor;
  Color checkColor;

  DefaultCheckBoxBuilderDelegate({
    this.activeColor = Colors.white,
    this.unselectedColor = Colors.black,
    this.checkColor = Colors.black,
  });

  @override
  Widget buildCheckBox(
    BuildContext context,
    bool checked,
    int index,
    Options options,
    I18nProvider i18nProvider,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: unselectedColor),
      child: Container(
        decoration: new BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: new BorderRadius.all(
              Radius.circular(30.0),
            )),
        child: CheckboxListTile(
          value: checked,
          onChanged: (bool check) {},
          activeColor: activeColor,
          checkColor: checkColor,
          title: Text(
            i18nProvider.getSelectedOptionsText(options),
            textAlign: TextAlign.end,
            style: TextStyle(color: options.textColor),
          ),
        ),
      ),
    );
  }
}

class RadioCheckBoxBuilderDelegate extends CheckBoxBuilderDelegate {
  Color activeColor;
  Color unselectedColor;

  RadioCheckBoxBuilderDelegate({
    this.activeColor = Colors.white,
    this.unselectedColor = Colors.white,
  });

  @override
  Widget buildCheckBox(
    BuildContext context,
    bool checked,
    int index,
    Options options,
    I18nProvider i18nProvider,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: unselectedColor),
      child: RadioListTile<bool>(
        value: true,
        onChanged: (bool check) {},
        activeColor: activeColor,
        title: Text(
          i18nProvider.getSelectedOptionsText(options),
          textAlign: TextAlign.end,
          style: TextStyle(color: options.textColor, fontSize: 14.0),
        ),
        groupValue: checked,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
