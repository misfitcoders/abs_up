import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/text.dart';
import 'equipment_row.dart';
import 'wrappers.dart';

/// Renders Exercise List Item Body Content
Widget savedWorkoutItem(Map<String, dynamic> workout) => listItemWrapper(
      GestureDetector(
        onTap: () => print(workout['key']),
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
          color: Colors.transparent,
          key: Key('contentItem:${workout['key']}'),
          child: Row(
            children: <Widget>[
              //= Saved workout content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //= Workout Name
                    RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: workout['name'],
                          style: AppTextStyles.savedWorkoutTitle
                              .copyWith(fontFamily: 'Montserrat'),
                        )),

                    //= Workout Equipment
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: equipmentRowContent(
                          activeEquipment: ['none'],
                          iconSize: 28,
                          baseColor: AppColors.greyLight,
                          activeColor: AppColors.rudy),
                    ),

                    //= Workout intensity & difficulty
                    Row(
                      // TODO Implement exercise item intensity level indicator
                      children: <Widget>[
                        Text('intensity'.toUpperCase(),
                            style: AppTextStyles.listItemBottomInfo.copyWith(
                                fontSize: 10, color: AppColors.greyDark)),
                        Text('difficulty'.toUpperCase(),
                            style: AppTextStyles.listItemBottomInfo.copyWith(
                                fontSize: 10, color: AppColors.greyDark)),
                      ],
                    ),
                  ],
                ),
              ),
              //= Workout time
              Container(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('08:30',
                        style: AppTextStyles.savedWorkoutTitle
                            .copyWith(fontWeight: FontWeight.w800)),
                    Container(
                      child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: '1 mont ago',
                              style: AppTextStyles.savedWorkoutTitle.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.rudy))),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );