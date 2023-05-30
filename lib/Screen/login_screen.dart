import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/Screen/Map_Screen.dart';
import 'package:login/Screen/Station_Owner_Map.dart';
import 'package:login/Screen/register_screen.dart';
import 'package:login/auth/authentication_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var _passwordVisible = false;

  var isPressed = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          leading: const Icon(Icons.menu),
          title: const Text('EASY CHARGE'),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(MdiIcons.evStation,
                                size: 100, color: Colors.green),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'login',
                          style: GoogleFonts.lato(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(
                          height: 30.00,
                        ),
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
                          textInputAction: TextInputAction.done,
                          keyboardAppearance: Brightness.dark,
                          decoration: InputDecoration(
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
                          height: 20,
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
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
                              onPressed: () async {
                                await _handleLogin();
                              },

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign in ',
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Icon(Icons.login)
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
                              'Dont have an account ?',
                              style: GoogleFonts.aBeeZee(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to the details page when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()),
                                );
                              },
                              child: Text(
                                'Register Now',
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
  Future<void> _handleLogin() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isPressed = true;
      });

      final authService = AuthenticationService();
      final userKind = await authService.login(
        emailController.text,
        passwordController.text,
      );
      print('User kind: $userKind');
      setState(() {
        isPressed = false;
      });

      // Delay the navigation to ensure the BuildContext is available
      Future.delayed(Duration.zero, () {
        if (userKind == 'User') {
          // Navigate to the home page for the user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Map_Screen(),
            ),
          );
        } else if (userKind == 'Station Owner') {
          // Navigate to the home page for the station owner
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Station_Owner_Map(),
            ),
          );
        } else {
          // Handle the case when the user is not found in any collection
          Fluttertoast.showToast(
            msg: 'Invalid user',
          );
        }
      });
    }
  }

}
