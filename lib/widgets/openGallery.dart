import 'package:flutter/material.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/photo.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/delegate/badge_delegate.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/delegate/checkbox_builder_delegate.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/delegate/loading_delegate.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/delegate/sort_delegate.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/provider/i18n_provider.dart';
import 'package:garage/utils/palette.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<AssetEntity>> openGalleryWindow(
    BuildContext context, int selectCount, PickType pickType) async {
  List<AssetEntity> imgList = await PhotoPicker.pickAsset(
    context: context,
    themeColor: Palette.appColor,
    padding: 2.0,
    dividerColor: Colors.black,
    disableColor: Colors.grey.shade300,
    itemRadio: 0.98,
    maxSelected: selectCount,
    provider: ENProvider(),
    rowCount: 2,
    textColor: Colors.black,
    thumbSize: 250,
    sortDelegate: SortDelegate.common,
    checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
      activeColor: Colors.black,
      unselectedColor: Colors.black,
      checkColor: Colors.blue,
    ),
    loadingDelegate: DefaultLoadingDelegate(),
    badgeDelegate: const DurationBadgeDelegate(),
    pickType: pickType,
  );

  return imgList;
}
