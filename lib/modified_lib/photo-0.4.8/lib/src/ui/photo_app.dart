import 'package:flutter/material.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/provider/config_provider.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/provider/i18n_provider.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/ui/page/photo_main_page.dart';

import 'package:photo_manager/photo_manager.dart';

class PhotoApp extends StatelessWidget {
  final Options options;
  final I18nProvider provider;
  final List<AssetPathEntity> photoList;
  final List<AssetEntity> pickedAssetList;
  const PhotoApp({
    Key key,
    this.options,
    this.provider,
    this.photoList,
    this.pickedAssetList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pickerProvider = PhotoPickerProvider(
      provider: provider,
      options: options,
      pickedAssetList: pickedAssetList,
      child: PhotoMainPage(
        onClose: (List<AssetEntity> value) {
          Navigator.pop(context, value);
        },
        options: options,
        photoList: photoList,
      ),
    );

    return pickerProvider;
  }
}
