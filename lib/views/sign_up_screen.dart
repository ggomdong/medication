import '../utils.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../view_models/sign_up_view_model.dart';
import '../views/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool _obscurePw1 = true;
  bool _obscurePw2 = true;

  // Keyboard 외의 영역 클릭시 Keyboard가 사라지도록 처리
  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  // email 유효성 체크
  bool _isEmailValid(String email) {
    final regExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regExp.hasMatch(email);
  }

  // password 유효성 체크(자리수)
  bool _isPasswordValid(String password) {
    return password.length >= 8;
  }

  // password 유효성 체크(일치)
  bool _isPasswordMatch() {
    return _password == _confirmPassword;
  }

  // password 비식별 처리 토글
  void _toggleObscurePw1() {
    _obscurePw1 = !_obscurePw1;
    setState(() {});
  }

  void _toggleObscurePw2() {
    _obscurePw2 = !_obscurePw2;
    setState(() {});
  }

  void _onSubmitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(signUpForm.notifier).state = {
        "email": _email,
        "password": _password,
      };
      ref.read(signUpProvider.notifier).signUp(context);
    }
  }

  void _onLogInTap() {
    context.pop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.size64),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Gaps.v96,
                  Image.asset(logo, height: 150),
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
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w600,
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
                      if (!_isEmailValid(value)) {
                        return '잘못된 이메일 형식이에요.';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() => _email = value),
                    onSaved: (value) {
                      if (value != null) {
                        _email = value;
                      }
                    },
                  ),
                  Gaps.v10,
                  TextFormField(
                    obscureText: _obscurePw1,
                    decoration: InputDecoration(
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _toggleObscurePw1,
                            child: FaIcon(
                              _obscurePw1
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
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w600,
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
                      if (!_isPasswordValid(value)) {
                        return '비밀번호는 최소한 8자리 이상이어야 해요.';
                      }
                      if (!_isPasswordMatch()) {
                        return '비밀번호가 일치하지 않아요.';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() => _password = value),
                    onSaved: (value) {
                      if (value != null) {
                        _password = value;
                      }
                    },
                  ),
                  Gaps.v10,
                  TextFormField(
                    obscureText: _obscurePw2,
                    decoration: InputDecoration(
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _toggleObscurePw2,
                            child: FaIcon(
                              _obscurePw1
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
                      hintText: '비밀번호 확인',
                      hintStyle: TextStyle(
                        fontSize: Sizes.size18,
                        fontWeight: FontWeight.w600,
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
                        return '비밀번호르 입력해 주세요.';
                      }
                      if (!_isPasswordValid(value)) {
                        return '비밀번호는 최소한 8자리 이상이어야 해요.';
                      }
                      if (!_isPasswordMatch()) {
                        return '비밀번호가 일치하지 않아요.';
                      }
                      return null;
                    },
                    onChanged:
                        (value) => setState(() => _confirmPassword = value),
                    onSaved: (value) {
                      if (value != null) {
                        _confirmPassword = value;
                      }
                    },
                  ),
                  Gaps.v16,
                  FormButton(
                    disabled:
                        !(_isEmailValid(_email) &&
                            _isPasswordValid(_password) &&
                            _isPasswordMatch() &&
                            !ref.watch(signUpProvider).isLoading),
                    text: "계정 생성",
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
              text: "이미 계정이 있다면? →",
              onTap: _onLogInTap,
            ),
          ),
        ),
      ),
    );
  }
}
