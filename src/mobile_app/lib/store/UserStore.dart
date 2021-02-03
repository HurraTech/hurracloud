import 'package:mobx/mobx.dart';
// RUN THIS WATCHER TO AUTOMATICALLY GENERATE FILE:
// flutter packages pub run build_runner watch


// Include generated file
part 'UserStore.g.dart';

// This is the class used by rest of your codebase
class UserStore = _UserStore with _$UserStore;

// The store-class
abstract class _UserStore with Store {
  @observable
  bool isLoggedIn = false;

  @action
  void setLoggedIn() {
    isLoggedIn = true;
  }
}
