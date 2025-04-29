import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../view_models/login_view_model.dart';
import '../views/sign_up_screen.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const routeUrl = "/";
  static const routeName = "login";

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  Map<String, String> formData = {};

  // Keyboard 외의 영역 클릭시 Keyboard가 사라지도록 처리
  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  // password 비식별 처리 토글
  void _toggleObscureText() {
    _obscureText = !_obscureText;
    setState(() {});
  }

  void _onSubmitForm() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        ref
            .read(loginProvider.notifier)
            .login(formData["email"]!, formData["password"]!, context);
      }
    }
  }

  void _onSignUpTap() {
    context.pushNamed(SignUpScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CommonAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.size64),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Gaps.v96,
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: Sizes.size20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Gaps.v32,
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Sizes.size14,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: '이메일',
                      hintStyle: TextStyle(
                        fontSize: Sizes.size16,
                        letterSpacing: -0.5,
                        color: Colors.grey.shade400,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이메일을 입력해 주세요.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        formData['email'] = value;
                      }
                    },
                  ),
                  Gaps.v10,
                  TextFormField(
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _toggleObscureText,
                            child: FaIcon(
                              _obscureText
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              color: Colors.grey.shade500,
                              size: Sizes.size20,
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Sizes.size14,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: '비밀번호',
                      hintStyle: TextStyle(
                        fontSize: Sizes.size16,
                        letterSpacing: -0.5,
                        color: Colors.grey.shade400,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '비밀번호를 입력해 주세요.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        formData['password'] = value;
                      }
                    },
                  ),
                  Gaps.v16,
                  FormButton(
                    disabled: ref.watch(loginProvider).isLoading,
                    text: "로그인",
                    onTap: _onSubmitForm,
                  ),
                  Gaps.v32,
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size44,
            vertical: Sizes.size48,
          ),
          child: Container(
            padding: EdgeInsets.all(Sizes.size20),
            child: FormButton(
              disabled: false,
              text: "새로운 계정 만들기 →",
              onTap: _onSignUpTap,
            ),
          ),
        ),
      ),
    );
  }
}
