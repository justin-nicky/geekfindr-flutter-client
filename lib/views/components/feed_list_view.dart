import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geek_findr/contants.dart';
import 'package:geek_findr/controller/controller.dart';
import 'package:geek_findr/functions.dart';
import 'package:geek_findr/database/box_instance.dart';
import 'package:geek_findr/models/post_models.dart';
import 'package:geek_findr/views/components/comments_bottomsheet.dart';
import 'package:geek_findr/views/components/heart_animation_widget.dart';
import 'package:geek_findr/views/screens/users_profile_page.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedList extends StatefulWidget {
  const FeedList({Key? key}) : super(key: key);
  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final commmentEditController = TextEditingController();
  List<bool> isCommenting = [];
  List<bool> isLikedList = [];
  List<bool> isHeartAnimatingList = [];
  List<ImageModel> datas = [];
  bool isLoading = false;
  bool allLoaded = false;
  int dataLength = -1;
  bool isRefresh = true;
  bool isRequested = false;

  Future<void> mockData(String lastId) async {
    if (!allLoaded) {
      isLoading = true;
    }
    final newData = await postServices.getMyFeeds(lastId: lastId);
    if (newData.isNotEmpty) {
      datas.addAll(newData);
      itemsSetup(newData);
      likesSetUp();
      controller.update(["dataList"]);
    }
    print("datas.length ${datas.length}");
    isLoading = false;
    allLoaded = newData.isEmpty;
  }

  Future<void> likesSetUp() async {
    final currentUser = Boxes.getCurrentUser();
    final values = <bool>[];
    for (int i = 0; i < datas.length; i++) {
      final likedUsers = await postServices.getLikedUsers(
        imageId: datas[i].id!,
      );
      final isLiked = likedUsers!
          .where(
            (element) => element.owner!.id == currentUser.id,
          )
          .isNotEmpty;
      values.add(isLiked);
    }
    if (values.isNotEmpty) {
      isLikedList = values;
      controller.update(["Like"]);
    }
  }

  void itemsSetup(List<ImageModel> values) {
    for (int i = 0; i < values.length; i++) {
      isLikedList.add(false);
    }
    for (int i = 0; i < values.length; i++) {
      isCommenting.add(false);
    }
    for (int i = 0; i < values.length; i++) {
      isHeartAnimatingList.add(false);
    }
    for (final e in values) {
      postController.feedLikesCountList.add(e.likeCount!);
    }
    for (final e in values) {
      postController.feedCommentCountList.add(e.commentCount!);
    }
  }

  Future<void> _buildCommentBottomSheet(String imageId, int index) async {
    Get.dialog(loadingIndicator());
    final data = await postServices.getCommentedUsers(
      imageId: imageId,
    );
    Get.back();
    Get.bottomSheet(
      CommentBottomSheet(
        isFeed: true,
        index: index,
        imageId: imageId,
        userList: data!,
      ),
    );
    isCommenting[index] = false;
    controller.update(
      ["comments"],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return FutureBuilder<List<ImageModel>>(
      future: postServices.getMyFeeds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeleton(width);
        }
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            datas = [];
            datas = snapshot.data!;
            return GetBuilder<AppController>(
              id: "dataList",
              builder: (contoller) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: datas.length,
                  itemBuilder: (context, index) {
                    if (isRefresh) {
                      itemsSetup(datas);
                      likesSetUp();
                    }
                    isRefresh = false;
                    final postedTime =
                        findDatesDifferenceFromToday(datas[index].createdAt!);
                    if (datas[index].isProject!) {
                      isRequested =
                          checkRequest(datas[index].teamJoinRequests!);
                    }
                    return VisibilityDetector(
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 1) {
                          // print("index $index");

                          if (datas.length - 3 <= index &&
                              !isLoading &&
                              (dataLength + 2) < index) {
                            dataLength = index;
                            // print(dataLength);
                            mockData(datas.last.id!);
                          }
                        }
                      },
                      key: UniqueKey(),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: datas[index].isProject!
                              ? primaryBlue
                              : secondaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            width: 1.5,
                                            color: white,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Get.to(
                                                  () => OtherUserProfile(
                                                    userId:
                                                        datas[index].owner!.id!,
                                                  ),
                                                );
                                              },
                                              autofocus: true,
                                              highlightColor: Colors.orange,
                                              splashColor: Colors.red,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "${datas[index].owner!.avatar}&s=${height * 0.04}",
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey
                                                      .withOpacity(0.3),
                                                  highlightColor: white,
                                                  period: const Duration(
                                                    milliseconds: 1000,
                                                  ),
                                                  child: Container(
                                                    height: height * 0.04,
                                                    width: height * 0.04,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        100,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => OtherUserProfile(
                                                  userId:
                                                      datas[index].owner!.id!,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              datas[index].owner!.username!,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            postedTime,
                                            style: GoogleFonts.roboto(
                                              fontSize: 10,
                                              color: black.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: datas[index].isProject!,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Project",
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          datas[index].projectName!,
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(
                                left: 10,
                                bottom: 10,
                              ),
                              child: ReadMoreText(
                                datas[index].description!,
                                colorClickableText: primaryColor,
                                trimMode: TrimMode.Line,
                                style: GoogleFonts.poppins(color: black),
                              ),
                            ),
                            _buildImage(index, width),
                            _buildBottomRowItems(index),
                            GetBuilder<AppController>(
                              id: "comments",
                              builder: (_) => Visibility(
                                visible: isCommenting[index],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        splashRadius: 25,
                                        icon: const Icon(
                                          Icons.send_rounded,
                                        ),
                                        onPressed: () async {
                                          if (commmentEditController
                                              .text.isNotEmpty) {
                                            await postServices.postComment(
                                              imageId: datas[index].id!,
                                              comment:
                                                  commmentEditController.text,
                                            );
                                            postController.feedCommentCountList[
                                                index] += 1;
                                            isCommenting[index] = false;
                                            controller.update(["comments"]);
                                          }
                                        },
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'Add comment',
                                    ),
                                    controller: commmentEditController,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBottomRowItems(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GetBuilder<AppController>(
                id: "likes",
                builder: (_) => InkWell(
                  onTap: () {
                    if (0 < postController.feedLikesCountList[index]) {
                      buildLikedUsersBottomSheet(
                        datas[index].id!,
                      );
                    }
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(
                      5,
                    ),
                    child: Text(
                      "${postController.feedLikesCountList[index]} Likes",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              GetBuilder<AppController>(
                id: "commentCount",
                builder: (_) => InkWell(
                  onTap: () {
                    if (0 < postController.feedCommentCountList[index]) {
                      _buildCommentBottomSheet(
                        datas[index].id!,
                        index,
                      );
                    }
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(
                      5,
                    ),
                    child: Text(
                      "${postController.feedCommentCountList[index]} Comments",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GetBuilder<AppController>(
                id: "Like",
                builder: (_) {
                  final icon = isLikedList[index]
                      ? Icons.favorite
                      : Icons.favorite_border_outlined;
                  final color = isLikedList[index] ? primaryColor : black;
                  return HeartAnimationWidget(
                    isAnimating: isLikedList[index],
                    child: IconButton(
                      splashRadius: 28,
                      onPressed: () {
                        if (!isLikedList[index]) {
                          postController.feedLikesCountList[index] += 1;
                          postServices.postLike(
                            imageId: datas[index].id!,
                          );
                        }
                        isLikedList[index] = true;
                        controller.update(["Like"]);
                      },
                      icon: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.mode_comment_outlined,
                  color: black,
                  size: 28,
                ),
                splashRadius: 25,
                tooltip: 'comment',
                onPressed: () {
                  if (isCommenting[index]) {
                    isCommenting[index] = false;
                  } else {
                    for (int i = 0; i < isCommenting.length; i++) {
                      isCommenting[i] = false;
                    }
                    isCommenting[index] = true;
                  }
                  controller.update(["comments"]);
                  commmentEditController.clear();
                },
              ),
              Visibility(
                visible: datas[index].isProject! && !isRequested,
                child: IconButton(
                  icon: ImageIcon(
                    const AssetImage(
                      "assets/icons/people.png",
                    ),
                    color: black,
                    size: 23,
                  ),
                  splashRadius: 25,
                  tooltip: 'join request',
                  onPressed: () {
                    postServices.sendJoinRequest(
                      projectName: datas[index].projectName!,
                      projectId: datas[index].id!,
                    );
                    isRequested = false;
                    controller.update(["dataList"]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(int index, double width) => GetBuilder<AppController>(
        id: "Like",
        builder: (controller) => GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: datas[index].mediaUrl!,
                  fit: BoxFit.fitWidth,
                  width: width,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.3),
                    highlightColor: white,
                    period: const Duration(
                      milliseconds: 1000,
                    ),
                    child: Container(
                      height: width * 0.65,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: isHeartAnimatingList[index] ? 1 : 0,
                child: HeartAnimationWidget(
                  duration: const Duration(
                    milliseconds: 700,
                  ),
                  isAnimating: isHeartAnimatingList[index],
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 60,
                  ),
                  onEnd: () {
                    isHeartAnimatingList[index] = false;
                    controller.update(["Like"]);
                  },
                ),
              )
            ],
          ),
          onDoubleTap: () {
            if (!isLikedList[index]) {
              postController.feedLikesCountList[index] += 1;
              postServices.postLike(
                imageId: datas[index].id!,
              );
            }
            isLikedList[index] = true;
            isHeartAnimatingList[index] = true;
            controller.update(["Like"]);
          },
        ),
      );

  Widget _skeleton(double width) => Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: white,
        period: const Duration(milliseconds: 1000),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (context, index) => Column(
              children: [
                Container(
                  width: width,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      );
}
