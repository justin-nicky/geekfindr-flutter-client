import 'package:flutter/material.dart';
import 'package:geek_findr/contants.dart';
import 'package:geek_findr/database/box_instance.dart';
import 'package:geek_findr/models/post_models.dart';
import 'package:geek_findr/views/components/users_list_bottomsheet.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

bool checkRequest(List<Join> requests) {
  final currentUser = Boxes.getCurrentUser();
  return requests
      .where((element) => element.owner == currentUser.id)
      .isNotEmpty;
}

double textfactorCustomize(double val) {
  if (val == 0.85) {
    return val + 0.1;
  } else if (val == 1.00) {
    return val;
  } else if (val == 1.15) {
    return val - 0.2;
  } else if (val == 1.3) {
    return val - 0.4;
  } else if (val == 1.45) {
    return val - 0.6;
  } else if (val == 1.6) {
    return val - 0.8;
  } else {
    return val;
  }
}

String findDatesDifferenceFromToday(DateTime dateTime) {
  final today = DateTime.now();
  final diff = dateTime.difference(today);
  if (diff.inMinutes > -1) {
    return "${diff.inSeconds * -1} seconds ago";
  } else if (diff.inHours > -1) {
    return "${diff.inMinutes * -1} minutes ago";
  } else if (diff.inDays > -1) {
    return "${diff.inHours * -1} hours ago";
  } else if (diff.inDays < -7) {
    final month = findMonth(dateTime.month.toString());
    return "${dateTime.day} $month";
  } else {
    return "${diff.inDays * -1} days ago";
  }
}

String findMonth(String month) {
  if (month == "1") {
    return "Jan";
  } else if (month == "2") {
    return "Feb";
  } else if (month == "3") {
    return "Mar";
  } else if (month == "4") {
    return "Apr";
  } else if (month == "5") {
    return "May";
  } else if (month == "6") {
    return "Jun";
  } else if (month == "7") {
    return "Jul";
  } else if (month == "8") {
    return "Aug";
  } else if (month == "9") {
    return "Sep";
  } else if (month == "10") {
    return "Octr";
  } else if (month == "11") {
    return "Nov";
  }
  return "Dec";
}

Widget loadingIndicator() => const Center(
      child: SizedBox(
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballPulse,
          colors: [
            Colors.red,
            Colors.redAccent,
            Colors.orange,
          ],
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.transparent,
        ),
      ),
    );

Future<void> buildLikedUsersBottomSheet(String imageId) async {
  Get.dialog(loadingIndicator());
  final data = await postServices.getLikedUsers(
    imageId: imageId,
  );
  final userList = data!.map((e) => e.owner!).toList();
  Get.back();
  Get.bottomSheet(
    UsersListView(
      userList: userList,
    ),
  );
}

Owner getUserDatAsOwnerModel() {
  final currentUser = Boxes.getCurrentUser();
  final _owner = Owner();
  _owner.avatar = currentUser.avatar;
  _owner.id = currentUser.id;
  _owner.username = currentUser.username;
  return _owner;
}
