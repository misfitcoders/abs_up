import 'package:hive/hive.dart';

import 'exercise.dart';

part 'workout_item.g.dart';

@HiveType(typeId: 3, adapterName: 'WorkoutItemAdapter')
class WorkoutItem extends HiveObject {
  @HiveField(0)
  final Exercise exercise;
  @HiveField(1)
  int order;
  @HiveField(2)
  final int duration;
  @HiveField(3)
  double weight;
  @HiveField(4)
  int progress;

  WorkoutItem(
      {this.exercise,
      this.order,
      this.duration,
      this.weight = 0,
      this.progress = 0});
}