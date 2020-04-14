import 'package:hive/hive.dart';

import '../models/exercise.dart';
import 'package:mobx/mobx.dart';
import '../repositories/data_repository.dart';
import '../core/base_enums.dart';

part 'exercise_store.g.dart';

class ExerciseStore extends _ExerciseStore with _$ExerciseStore {
  ExerciseStore(DataRepository dataRepository) : super(dataRepository);
}

abstract class _ExerciseStore with Store {
  final DataRepository _dataRepository;

  _ExerciseStore(this._dataRepository);

  @observable
  List<Exercise> exerciseList;

  @computed
  List<Exercise> get filteredExerciseList {}

  @observable
  ObservableFuture<List<Exercise>> _exerciseListFuture;

  @computed
  StoreState get state {
    if (_exerciseListFuture == null ||
        _exerciseListFuture.status == FutureStatus.rejected) {
      return StoreState.initial;
    }
    return _exerciseListFuture.status == FutureStatus.pending
        ? StoreState.loading
        : StoreState.loaded;
  }

  @observable
  String errorMessage;

  @action
  Future getExerciseList() async {
    try {
      errorMessage = null;

      _exerciseListFuture =
          ObservableFuture(_dataRepository.fetchRemoteExercises());

      exerciseList = await _exerciseListFuture;
      print(_exerciseListFuture.status);
      print(exerciseList.length);
      // final exercisesBox = Hive.box<Exercise>('exercises');
      // await exercisesBox.clear();
      // await exercisesBox.addAll(exerciseList.map<Exercise>((e) => e));
    } catch (e) {
      print(e);
    }
  }
}