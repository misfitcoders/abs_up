import 'package:flutter/material.dart';

import '../../domain/models/exercise.dart';
import '../theme/colors.t.dart';
import '../theme/text.t.dart';
import 'exercise_details_body.w.dart';

class ExerciseDetailsPageView extends StatelessWidget {
  final Exercise exercise;
  final PageController pageController;

  const ExerciseDetailsPageView(this.exercise,
      {Key key, @required this.pageController})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        children: <Widget>[
          //= Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.greyDark,
                  ),
                  onPressed: () => Navigator.pop(context)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: exercise.name.toUpperCase(),
                        style: AppTextStyles.listItemTitle.copyWith(
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              IconButton(
                  icon:
                      const Icon(Icons.filter_none, color: AppColors.greyDark),
                  onPressed: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease))
            ],
          ),
          //= Content
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            color: AppColors.greyLightest,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: ExerciseDetailsBody(exercise)),
              ],
            ),
          ))
        ],
      ),
    );
  }
}