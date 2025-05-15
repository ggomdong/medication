import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../views/widgets/point_indicator.dart';
import '../views/widgets/medication_info.dart';
import '../views/widgets/persistent_tab_bar.dart';
import '../notification/notification_list.dart';
import '../repos/authentication_repo.dart';
import '../view_models/settings_view_model.dart';
import '../notification/notification_service.dart';
import '../router.dart';
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
  void _onShowModal(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text("정말 로그아웃하시겠어요?"),
            content: const Text("가지마~~"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("아니오"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  ref.read(authRepo).signOut();
                  context.go(RouteURL.login);
                },
                isDestructiveAction: true,
                child: const Text("예"),
              ),
            ],
          ),
    );
  }

  void _removeAllAlarms() async {
    final service = ref.read(notificationServiceProvider);
    await service.cancelAllNotifications();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("모든 알림이 삭제되었습니다.")));

    setState(() {});
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
                            centerTitle: false,
                            titleSpacing: 0,
                            toolbarHeight: 70,
                            title: Image.asset(
                              isDark ? logoDarkmode : logo,
                              height: 150,
                            ),
                            actions: [PointIndicator(), Gaps.h20],
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
                                            // data.name,
                                            data.email.split('@')[0],
                                            style: TextStyle(
                                              fontSize: Sizes.size28,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Gaps.v3,
                                          Row(
                                            children: [
                                              // Text(
                                              //   data.email,
                                              //   style: TextStyle(
                                              //     fontSize: Sizes.size18,
                                              //   ),
                                              // ),
                                              // Gaps.h5,
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
                                                  data.email,
                                                  style: TextStyle(
                                                    fontSize: Sizes.size16,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Gaps.v10,
                                        ],
                                      ),
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundImage: AssetImage(
                                          "assets/images/avatar.png",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gaps.v6,
                                  Divider(thickness: 0.5),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: Sizes.size20,
                                    ),
                                    value: ref.watch(settingsProvider).darkMode,
                                    onChanged:
                                        (value) => ref
                                            .read(settingsProvider.notifier)
                                            .setDarkMode(value),
                                    title: const Text(
                                      "다크모드",
                                      style: TextStyle(fontSize: Sizes.size18),
                                    ),
                                    secondary: Icon(
                                      isDark
                                          ? Icons.dark_mode_outlined
                                          : Icons.light_mode_outlined,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.logout),
                                    title: const Text(
                                      "로그아웃",
                                      style: TextStyle(fontSize: Sizes.size18),
                                    ),
                                    textColor: Colors.red,
                                    onTap: () => _onShowModal(context, ref),
                                  ),
                                  // Divider(thickness: 0.5),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     GestureDetector(
                                  //       onTap: openExactAlarmSettings,
                                  //       child: CustomButton(text: "알람 권한 설정"),
                                  //     ),
                                  //     GestureDetector(
                                  //       onTap: _removeAllAlarms,
                                  //       child: CustomButton(text: "알람 삭제"),
                                  //     ),
                                  //   ],
                                  // ),
                                  // Gaps.v20,
                                ],
                              ),
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: PersistentTabBar(),
                            pinned: true,
                          ),
                        ];
                      },
                      body: TabBarView(
                        children: [
                          // 복약 통계 탭
                          MedicationInfo(),
                          // 알림 내역 탭
                          const NotificationList(),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(RouteURL.info),
                    icon: Icon(Icons.edit),
                    label: Text("건강정보 및 약 정보 입력"),
                  ),
                ),
                // floatingActionButton: FloatingActionButton.extended(
                //   onPressed: () {
                //     context.push("/edit-profile-info");
                //   },
                //   label: Text("건강정보 및 약 정보 입력"),
                //   icon: Icon(Icons.edit),
                // ),
              ),
        );
  }
}
