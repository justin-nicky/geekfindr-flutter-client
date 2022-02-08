import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:geek_findr/services/posts.dart';
import 'package:geek_findr/views/drawer_page.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _advancedDrawerController = AdvancedDrawerController();
  final imagePicker = ImagePicker();
  String? imagePath;


  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // final textFactor = MediaQuery.textScaleFactorOf(context);
    // final user = box.get("user") as UserModel;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // imgFromcamara();
            postImage();
            //  getMyImages();
          },
        ),
        body: AdvancedDrawer(
          backdropColor: Colors.black.withOpacity(.9),
          controller: _advancedDrawerController,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          childDecoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 100.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          drawer: const DrawerPage(),
          child: Scaffold(
            backgroundColor: const Color(0xffE7EAF0),
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 60,
              // title: Text(user.username!),
              leading: IconButton(
                icon: Image.asset(
                  "assets/icons/hamburger.png",
                  height: height * .035,
                ),
                onPressed: () {
                  _advancedDrawerController.showDrawer();
                },
              ),
              backgroundColor: Colors.white,
            ),
            body: FutureBuilder<List<PostImage>>(
              future: getMyImages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data;
                  if (data != null) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Image.network(
                            data[index].mediaUrl!,
                            fit: BoxFit.fitWidth,
                          ),
                          Text(data[index].description!),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
