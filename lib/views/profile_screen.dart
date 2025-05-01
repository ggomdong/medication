import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:medication/router.dart';
import '../views/widgets/custom_button.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../view_models/user_view_model.dart';
import '../utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _onGearPressed() {
    context.go(RouteURL.settings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    return ref
        .watch(usersProvider)
        .when(
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading:
              () => const Center(child: CircularProgressIndicator.adaptive()),
          data:
              (data) => Scaffold(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                body: SafeArea(
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 2,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            leading: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: FaIcon(
                                FontAwesomeIcons.globe,
                                size: Sizes.size24,
                              ),
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {},
                                icon: const FaIcon(
                                  FontAwesomeIcons.instagram,
                                  size: Sizes.size28,
                                ),
                              ),
                              IconButton(
                                onPressed: _onGearPressed,
                                icon: const FaIcon(
                                  FontAwesomeIcons.bars,
                                  size: Sizes.size28,
                                ),
                              ),
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size16,
                              ),
                              child: Column(
                                children: [
                                  Gaps.v10,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.name,
                                            style: TextStyle(
                                              fontSize: Sizes.size28,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Gaps.v3,
                                          Row(
                                            children: [
                                              Text(
                                                data.email,
                                                style: TextStyle(
                                                  fontSize: Sizes.size18,
                                                ),
                                              ),
                                              Gaps.h5,
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Sizes.size12,
                                                      vertical: Sizes.size5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Sizes.size40,
                                                      ),
                                                ),
                                                child: Text(
                                                  "threads.net",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Gaps.v10,
                                          Text(
                                            data.bio,
                                            style: TextStyle(
                                              fontSize: Sizes.size18,
                                            ),
                                          ),
                                          Gaps.v10,
                                          SizedBox(
                                            height: Sizes.size48,
                                            width: Sizes.size96,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  top: 10,
                                                  left: 3,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          "https://i.pravatar.cc/150?img=1",
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 6,
                                                  left: 15,
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            isDark
                                                                ? Colors.black
                                                                : Colors.white,
                                                        width: 4,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          "https://i.pravatar.cc/150?img=2",
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 6,
                                                  left: 50,
                                                  child: Text(
                                                    "${data.followerCount} followers",
                                                    style: TextStyle(
                                                      fontSize: Sizes.size18,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Avatar(
                                      //   uid: data.uid,
                                      //   name: data.name,
                                      //   hasAvatar: data.hasAvatar,
                                      // ),
                                    ],
                                  ),
                                  Gaps.v6,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomButton(text: "Edit profile"),
                                      CustomButton(text: "Share profile"),
                                    ],
                                  ),
                                  Gaps.v20,
                                ],
                              ),
                            ),
                          ),
                          // SliverPersistentHeader(
                          //   delegate: PersistentTabBar(),
                          //   pinned: true,
                          // ),
                        ];
                      },
                      body: Text("test"),
                    ),
                  ),
                ),
              ),
        );
  }
}
