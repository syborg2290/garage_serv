import 'package:animator/animator.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter/material.dart';

shimmerEffectLoadingProfile(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 10, bottom: 20),
      child: Animator(
        duration: Duration(milliseconds: 1000),
        tween: Tween(begin: 0.95, end: 1.0),
        curve: Curves.easeInCirc,
        cycles: 0,
        builder: (anim) => Transform.scale(
            scale: anim.value,
            child: ContentPlaceholder(
              bgColor: Color(0xffe0e0e0),
              borderRadius: 30.0,
              highlightColor: Colors.grey[200],
              context: context,
              child: Column(children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: <Widget>[
                      ContentPlaceholder.block(
                          height: height * 0.3,
                          width: width,
                          rightSpacing: 10,
                          borderRadius: 20),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.2),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white,
                                width: 10,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ContentPlaceholder.block(
                                width: 140, height: 140, borderRadius: 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.4,
                        height: height * 0.2,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.4,
                        height: height * 0.2,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.4,
                        height: height * 0.2,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.4,
                        height: height * 0.2,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
              ]),
            )),
      ),
    ),
  );
}
