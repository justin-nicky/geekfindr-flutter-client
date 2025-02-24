import 'package:flutter/material.dart';
import 'package:geek_findr/contants.dart';
import 'package:geek_findr/controller/controller.dart';
import 'package:geek_findr/functions.dart';
import 'package:geek_findr/models/project_model_classes.dart';
import 'package:geek_findr/views/screens/project_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class MyProjectList extends StatelessWidget {
  const MyProjectList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textFactor =
        textfactorCustomize(MediaQuery.textScaleFactorOf(context));
    return GetBuilder<AppController>(
      id: "projectList",
      builder: (controller) {
        return FutureBuilder(
          future: projectServices.getMyProjects(),
          builder: (context, AsyncSnapshot<List<ProjectShortModel>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _skeleton(width, textFactor);
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                final datas = snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: white,
                    title: Text(
                      "Your Projects",
                      style: GoogleFonts.recursive(
                        fontSize: textFactor * 17,
                        color: black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      PopupMenuButton(
                        itemBuilder: (BuildContext bc) => [
                          PopupMenuItem(
                            value: "1",
                            child: Text(
                              "",
                              style: GoogleFonts.poppins(
                                fontSize: textFactor * 13,
                                color: Colors.black.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        ],
                        onSelected: (value) async {
                          if (value == "1") {}
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: black,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: secondaryColor,
                  body: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.separated(
                      itemCount: datas.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => ProjectView(
                                projectId: datas[index].project!.id!,
                              ),
                            );
                          },
                          child: Container(
                            height: height * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    child: Image.asset(
                                      "assets/images/Hand coding-bro.png",
                                      width: width,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          datas[index].project!.name!,
                                          style: GoogleFonts.poppins(
                                            fontSize: textFactor * 16,
                                            color:
                                                Colors.black.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          datas[index].project!.description!,
                                          maxLines: 3,
                                          style: GoogleFonts.poppins(
                                            fontSize: textFactor * 13,
                                            color:
                                                Colors.black.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 10),
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

  Widget _skeleton(double width, double textFactor) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        title: Text(
          "Your Projects",
          style: GoogleFonts.recursive(
            fontSize: textFactor * 17,
            color: black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          PopupMenuButton(
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
              if (value == "1") {}
            },
            icon: Icon(
              Icons.more_vert,
              color: black,
            ),
          ),
        ],
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: white,
        period: const Duration(milliseconds: 1000),
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => Column(
              children: [
                Container(
                  width: width,
                  height: 115,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
