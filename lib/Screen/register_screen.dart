import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/Screen/login_screen.dart';
import 'package:login/models/user_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');
  var _passwordVisible = false;

  var isPressed = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.blueAccent, //<-- SEE HERE
              child: IconButton(
                icon: const Icon(
                  MdiIcons.carArrowLeft,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
          title: const Text('EASY CHARGE'),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello!'
                          ' Register to get started',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                            shadows: <Shadow>[
                              const Shadow(
                                offset: Offset(0.0, 4.0),
                                blurRadius: 4.0,
                                color: Color(0x40000000),
                              ),
                            ],
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(
                          height: 50.00,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'username must not be empty';
                            }

                            return null;
                          },
                          controller: usernameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'User Name',
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: ' Enter Name ',
                            hintStyle: GoogleFonts.aBeeZee(),
                            prefixIcon: const Icon(Icons.person),
                            prefixIconColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.focused)
                                        ? Colors.green
                                        : Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.white54,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'email address must not be empty';
                            }

                            return null;
                          },
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: ' Enter Email ',
                            hintStyle: GoogleFonts.aBeeZee(),
                            prefixIcon: const Icon(Icons.email),
                            prefixIconColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.focused)
                                        ? Colors.green
                                        : Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.white54,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'password is too short';
                            }

                            return null;
                          },
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.next,
                          keyboardAppearance: Brightness.dark,
                          decoration: InputDecoration(
                            isDense: false,
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: ' Enter Password ',
                            hintStyle: GoogleFonts.aBeeZee(),
                            prefixIcon: const Icon(Icons.lock),
                            prefixIconColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.focused)
                                        ? Colors.green
                                        : Colors.grey),

                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: (isPressed) ? Colors.red : Colors.green,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  isPressed = !isPressed;
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            // border: OutlineInputBorder(
                            //   borderSide: const BorderSide(color: Colors.white),
                            //   borderRadius: BorderRadius.circular(15),
                            // ),

                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.white54,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xffeeeeee),
                                  blurRadius: 10,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: Colors.green.withOpacity(1)),
                          ),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              // print(number.phoneNumber);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Phone must not be empty';
                              }

                              return null;
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle:
                                const TextStyle(color: Colors.black),
                            initialValue: number,
                            textFieldController: phoneController,
                            formatInput: true,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            onSaved: (PhoneNumber number) {
                              print('On Saved: $number');
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ))),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    isPressed = true;
                                  });
                                }
                                FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text)
                                    .then((userData) {
                                  // Fluttertoast.showToast(
                                  //   msg: userData.user!.uid,
                                  // );


                                    UserDataModel model = UserDataModel(
                                      uId: userData.user!.uid,
                                      phone: phoneController.text,
                                      email: emailController.text,
                                      username: usernameController.text,
                                      token: passwordController.text,
                                    );
                                    userConst = userData.user;
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userData.user!.uid)
                                        .set(model.toJson())
                                        .then((value) {
                                      setState(() {
                                        isPressed = false;
                                      });
                                    }).catchError((error) {
                                      Fluttertoast.showToast(
                                        msg: error.toString(),
                                      );
                                    });

                                }).catchError((error) {
                                  setState(() {
                                    isPressed = false;
                                  });

                                  Fluttertoast.showToast(
                                    msg: error.toString().split(']').last,
                                  );
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ' Register ',
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Icon(Icons.app_registration_rounded)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'have an account ?',
                              style: GoogleFonts.aBeeZee(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to the details page when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Login Now',
                                style: GoogleFonts.abel(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          ],
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ));

  }
}
