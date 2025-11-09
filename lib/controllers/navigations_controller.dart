import 'package:get/get.dart';

class NavigationsController extends GetxController{

  var currentMainNavigation = 'dashboard'.obs;

   mainNavigation(String route) {
    // Logic to navigate to a specific route
    currentMainNavigation.value = route;
    update();
  }
}