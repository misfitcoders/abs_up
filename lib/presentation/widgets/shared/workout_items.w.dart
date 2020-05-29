import 'package:abs_up/services/workout.s.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/workout.dart';
import '../../../domain/models/workout_item.dart';
import '../../theme/colors.t.dart';
import 'snackbars.w.dart';
import 'swipable_actions.w.dart';
import 'workout_items_body.w.dart';

/// Consumes: WorkoutService
class WorkoutItemWidget extends StatelessWidget {
  final WorkoutItem workoutItem;
  const WorkoutItemWidget({
    Key key,
    @required this.workoutItem,
  }) : super(key: key);

  void removeItem(
          ScaffoldState scaffold, WorkoutItem workoutItem, Workout workout) =>
      workout.removeItem(workoutItem).then((_) => scaffold.showSnackBar(
          AppSnackbars.removedWorkoutItem(workoutItem.exercise.name)));
  @override
  Widget build(BuildContext context) {
    final WorkoutService workoutService = Provider.of<WorkoutService>(context);
    return Dismissible(
      key: Key(workoutItem.exercise.key.toString()),
      background: SwipableActions.background(
          AppColors.brandeis, Icons.favorite, 'replace\nexercise'),
      secondaryBackground: SwipableActions.secondaryBackground(
          Colors.red, Icons.delete, 'remove from\nworkout'),
      onDismissed: (direction) => removeItem(
          Scaffold.of(context), workoutItem, workoutService.currentWorkout),
      // TODO implement the swippable action to replace the exercise of a workout item
      // confirmDismiss: (direction) async { return true;},
      child: WorkoutItemBody(
          workoutItem: workoutItem, workout: workoutService.currentWorkout),
    );
  }
}