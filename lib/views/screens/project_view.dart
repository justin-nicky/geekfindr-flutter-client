import 'package:flutter/material.dart';
import 'package:geek_findr/contants.dart';
import 'package:geek_findr/controller/controller.dart';
import 'package:geek_findr/functions.dart';
import 'package:geek_findr/models/project_model_classes.dart';
import 'package:geek_findr/views/components/project_info_view.dart';
import 'package:geek_findr/views/components/project_tasks_view.dart';
import 'package:geek_findr/views/components/project_teams_view.dart';
import 'package:geek_findr/views/components/project_todos_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ProjectView extends StatefulWidget {
  const ProjectView({
    Key? key,
    required this.projectId,
  }) : super(key: key);
  final String projectId;

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  int _currentIndex = 0;
  double width = 0;
  double height = 0;
  double textFactor = 0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    textFactor = textfactorCustomize(MediaQuery.textScaleFactorOf(context));
    return GetBuilder<AppController>(
      id: "projectView",
      builder: (controller) {
        return FutureBuilder<ProjectModel?>(
          future: projectServices.getProjectDetialsById(id: widget.projectId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _skeleton();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                final projectModel = snapshot.data!;
                final projectDetials = projectModel.project!;
                final date =
                    findDatesDifferenceFromToday(projectDetials.createdAt!);
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      controller.update(["projectView"]);
                    },
                  ),
                  backgroundColor: secondaryColor,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: white,
                    leading: IconButton(
                      splashRadius: 25,
                      icon: ImageIcon(
                        const AssetImage("assets/icons/left.png"),
                        color: black,
                        size: 25,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    actions: [
                      Visibility(
                        visible: projectModel.role! == owner,
                        child: PopupMenuButton(
                          itemBuilder: (BuildContext bc) => [
                            PopupMenuItem(
                              value: "1",
                              child: Text(
                                "Delete Project",
                                style: GoogleFonts.poppins(
                                  fontSize: textFactor * 13,
                                  color: Colors.black.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                          onSelected: (value) async {
                            if (value == "1") {
                              await projectServices.deleteProject(
                                projectId: widget.projectId,
                                projectName: projectDetials.name!,
                              );
                              controller.update(["projectList"]);
                              Get.back();
                            }
                          },
                          icon: Icon(
                            Icons.more_vert,
                            color: black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    // physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.02),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            projectDetials.name!,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: black,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Started $date",
                            style: GoogleFonts.roboto(
                              fontSize: textFactor * 12,
                              fontWeight: FontWeight.w500,
                              color: black.withOpacity(0.6),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        GetBuilder<AppController>(
                          id: "projtabs",
                          builder: (controller) {
                            return Column(
                              children: [
                                buildTabbar(),
                                IndexedStack(
                                  index: _currentIndex,
                                  children: [
                                    Visibility(
                                      visible: _currentIndex == 0,
                                      child: ProjectInfoView(
                                        projuctDetials: projectModel.project!,
                                        myRole: projectModel.role!,
                                      ),
                                    ),
                                    Visibility(
                                      visible: _currentIndex == 1,
                                      child: ProjectTeamView(
                                        projuctDetials: projectModel.project!,
                                        myRole: projectModel.role!,
                                      ),
                                    ),
                                    Visibility(
                                      visible: _currentIndex == 2,
                                      child: ProjectTodosView(
                                        projuctDetials: projectDetials,
                                        myRole: projectModel.role!,
                                      ),
                                    ),
                                    Visibility(
                                      maintainState: true,
                                      visible: _currentIndex == 3,
                                      child: ProjectTaskView(
                                        projuctDetials: projectDetials,
                                        myRole: projectModel.role!,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _skeleton() {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        leading: IconButton(
          splashRadius: 25,
          icon: ImageIcon(
            const AssetImage("assets/icons/left.png"),
            color: black,
            size: 25,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.2),
                highlightColor: white,
                period: const Duration(milliseconds: 1000),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  width: width * 0.3,
                  height: height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                ),
              ),
              buildTabbar(),
              Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.2),
                highlightColor: white,
                period: const Duration(milliseconds: 1000),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  width: width,
                  height: height * 0.075,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.2),
                highlightColor: white,
                period: const Duration(milliseconds: 1000),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: width,
                  height: height * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabbar() {
    return DefaultTabController(
      length: categories.length,
      child: TabBar(
        indicatorColor: Colors.blue,
        physics: const BouncingScrollPhysics(),
        indicatorWeight: .0001,
        onTap: (index) {
          _currentIndex = index;
          controller.update(["projtabs"]);
        },
        tabs: [
          ...categories.map(
            (element) => Container(
              width: width * 0.3,
              height: height * 0.085,
              padding: const EdgeInsets.symmetric(
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color:
                    categories[_currentIndex] == element ? primaryColor : white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      element["iconPath"]!,
                      height: 30,
                      width: 30,
                      color: categories[_currentIndex] == element
                          ? white
                          : Colors.grey[700],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 3,
                      ),
                      child: Text(
                        element['name']!,
                        style: GoogleFonts.poppins(
                          color: categories[_currentIndex] == element
                              ? white
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: textFactor * 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
