import 'dart:math';

import 'package:data_setup/domain/models/exercise.dart';
import 'package:data_setup/domain/models/workout.dart';
import 'package:data_setup/domain/models/workout_item.dart';
import 'package:data_setup/domain/models/workout_settings.dart';
import 'package:data_setup/domain/repositories/data_values.dart';
import 'package:data_setup/domain/repositories/i_user_settings_facade.dart';
import 'package:hive/hive.dart';

import 'i_hive_facade.dart';

class IWorkoutFacade {
  static Box workoutSettingsBox = IHiveFacade.workoutSettingsBox;
  static Box<Workout> workoutsBox = IHiveFacade.workoutsBox;
  static Box<Exercise> exercisesBox = IHiveFacade.exercisesBox;

  static const List<String> availableTargets = [
    'Core',
    'Lower',
    'Upper',
    'Rect',
    'Obliques',
    // TODO implement what to do with Kegel exercises (for now dey won't be included in the distirbution)
    // 'Kegel'
  ];

  //: Getters _________________________________________________
  /// Returns the current workout settings
  static WorkoutSettings get workoutSettings =>
      workoutSettingsBox.get(DataValues.workoutSettingsKey);

  /// Returns a rough amount exercises to include by the length set in settings
  int get roughtExerciseAmount => IWorkoutFacade.workoutSettings.length <= 1
      ? 9
      : IWorkoutFacade.workoutSettings.length == 2 ? 18 : 20;

  //: Main methods ___________________________________________
  /// defaultWorkout initializer
  static Future<void> initWorkoutSettings() async {
    if (workoutSettingsBox.containsKey(DataValues.workoutSettingsKey)) return;

    await workoutSettingsBox.put(
        DataValues.workoutSettingsKey, WorkoutSettings());
    await workoutsBox.put(
        DataValues.currentWorkoutKey, Workout(name: 'Workout'));
  }

  /// Generates a new workout based on current settings
  static Workout generateWorkout() {
    final WorkoutSettings settings =
        workoutSettingsBox.get(DataValues.workoutSettingsKey);

    //= filter exercises
    Iterable<Exercise> availableExercises = exercisesBox.values.where(
        (exercise) =>
            intensityFilter(exercise.intensity, settings.intensity) &&
            difficultyFilter(exercise.difficulty, settings.difficulty) &&
            exercise.impact == settings.impact &&
            settings.equipment.contains(exercise.equipment.toLowerCase()) &&
            exercise.tag != ExerciseTag.blacklisted.index);

    //= distribute exercises
    final Map<String, List<Exercise>> distributedExercises =
        distributeByTargets(availableExercises.toList());
    //= randomize by targets
    List<Exercise> randomizedExercises =
        randomizeExercises(distributedExercises);
    //= sort randomized exercises by intensity
    randomizedExercises
        .sort((exA, exB) => exA.intensity.compareTo(exB.intensity));

    //= build exerciseItems
    List<WorkoutItem> exerciseItems = [];
    int total = 0;
    for (final exercise in randomizedExercises) {
      int duration = 0;
      duration = getWorkoutItemDuration(exercise.intensity, settings.length);
      exerciseItems.add(WorkoutItem(exercise: exercise, duration: duration));
      total += duration;
      if (total > IWorkoutFacade.minWorkoutLength) break;
    }

    //= add rest items
    List<WorkoutItem> workoutItems =
        addRestItems(exerciseItems, settings.intensity, settings.length);

    //= set order of items and return final items
    Iterable.generate(workoutItems.length, (x) => x + 1).forEach(
        (iterationNumber) =>
            workoutItems[iterationNumber - 1].order = iterationNumber);

    return Workout(items: workoutItems);
  }

  /// Generates a new workout based on current settings
  /// and saves it into the currentWorkout key of the workouts box
  static Future<void> generateCurrentWorkout() async =>
      await workoutsBox.put(DataValues.currentWorkoutKey, generateWorkout());

  //: Helper Methods_____________________________________________

  /// Get minimum workout duration by settings length
  static int get minWorkoutLength {
    switch (IWorkoutFacade.workoutSettings.length) {
      case 1:
        return DataValues.minimumDurationShortLength;
      case 2:
        return DataValues.minimumDurationMediumLength;
      case 3:
        return DataValues.minimumDurationLongLength;
    }
    return DataValues.minimumDurationDefault;
  }

  /// Workout item duration matrix
  static int getWorkoutItemDuration(int intensity, int settingsLength) {
    const int short = DataValues.workoutItemDurationShort;
    const int medium = DataValues.workoutItemDurationMedium;
    const int long = DataValues.workoutItemDurationLong;

    switch (settingsLength) {
      case 1:
        if (intensity == 1) return medium;
        return short;
        break;
      case 2:
        if (intensity <= 2) return long;
        if (intensity == 3) return medium;
        return short;
        break;
      case 3:
        if (intensity <= 3) return long;
        return medium;
        break;
      default:
        return short;
    }
  }

  /// Distributes available exercises into lists based in their targets
  static Map<String, List<Exercise>> distributeByTargets(
          List<Exercise> availableExercises) =>
      Map.fromIterable(availableTargets,
          key: (target) => target,
          value: (target) => availableExercises
              .where((exercise) => exercise.target == target)
              .toList());

  /// Returns random exercises from a list of distributed exercises
  static List<Exercise> randomizeExercises(
      Map<String, List<Exercise>> distributedExercises) {
    List<Exercise> randomizedExercises = [];

    int currentIndex = 0;

    // consinuously iterate thru all available targets
    Iterator<String> targetIterator = availableTargets.iterator;
    while (currentIndex <= IWorkoutFacade().roughtExerciseAmount) {
      if (targetIterator.current == null) targetIterator.moveNext();
      if (distributedExercises[targetIterator.current].length <= 0) continue;

      // shuffle the targeted list
      distributedExercises[targetIterator.current].shuffle();
      // extract the last exercise and add it to the returned list
      randomizedExercises
          .add(distributedExercises[targetIterator.current].removeLast());
      if (!targetIterator.moveNext())
        targetIterator = availableTargets.iterator;
      currentIndex++;
    }
    return randomizedExercises;
  }

  /// Returns the exercise items with rest items included
  static List<WorkoutItem> addRestItems(List<WorkoutItem> exerciseItems,
      int settingsIntensity, int settingsLength) {
    //= base duration of rest items
    const int baseInterval = 15;

    //= set rest interval duration
    final int interval = settingsIntensity != 4
        ? baseInterval * settingsIntensity
        : settingsLength == 2
            ? baseInterval * 3
            : settingsLength == 3 ? baseInterval * 2 : 0;
    //= set frequency of rest intervals
    final int frequency = settingsIntensity != 4
        ? settingsLength
        : settingsLength - 1; //this yields: 1 = 0, 2 = 1, 3 = 2

    //= length 1 intensity 1 has no rest intervals thus returns the same
    if (frequency == 0) return exerciseItems;

    List<WorkoutItem> exerciseAndRestItems = [...exerciseItems];

    final int workBlock =
        (exerciseItems.length / (frequency + 1)).floorToDouble().toInt();

    Iterable.generate(frequency, (x) => x + 1).forEach((iterationNumber) {
      final int index = exerciseItems.length - (workBlock * iterationNumber);
      //-> print('insert at $index');
      exerciseAndRestItems.insert(
          index,
          WorkoutItem(
              exercise: IHiveFacade.exercisesBox.values
                  .where((exercise) => exercise.name == 'Rest')
                  .first,
              duration: interval));
    });

    return exerciseAndRestItems;
  }

  /// Intensity filter for exercise availability at generating a workout
  static bool intensityFilter(int exerciseIntensity, int settingsIntensity) {
    switch (settingsIntensity) {
      case 1:
        return exerciseIntensity <= 3;
      case 2:
        return exerciseIntensity <= 3;
      case 3:
        return exerciseIntensity <= 4;
      case 4:
        return exerciseIntensity >= 2 && exerciseIntensity <= 4;
      default:
        return false;
    }
  }

  /// Intensity filter for exercise availability at generating a workout
  static bool difficultyFilter(int exerciseDifficulty, int settingsDifficulty) {
    switch (settingsDifficulty) {
      case 1:
        return exerciseDifficulty <= 2;
      case 2:
        return exerciseDifficulty <= 3;
      case 3:
        return exerciseDifficulty <= 3;
      case 4:
        return exerciseDifficulty >= 2 && exerciseDifficulty <= 4;
      default:
        return false;
    }
  }
}