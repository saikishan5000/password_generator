import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_strength/password_strength.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String password = "";
  int length = 50;
  bool includeNumbers = true;
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeSymbols = false;
  final TextEditingController _passwordController = TextEditingController();
  List<String> passwordHistory = [];

  @override
  void initState() {
    super.initState();
    _passwordController.text = password;
  }

  void _generatePassword() {
    // Clear previous password
    setState(() {
      password = '';
      _passwordController.text = password;
    });

    // Generate password character by character with a delay
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (index < length) {
          password += generatePasswordCharacter();
          _passwordController.text = password;
          index++;
        } else {
          timer.cancel();
          _addToPasswordHistory(password);
        }
      });
    });
  }

  void _addToPasswordHistory(String newPassword) {
    // Add the new password to the beginning of the history list
    passwordHistory.insert(0, newPassword);

    // Limit the history list to store only the last 5 passwords
    if (passwordHistory.length > 5) {
      passwordHistory.removeLast();
    }
  }

  String generatePasswordCharacter() {
    String allCharacters = '';
    if (includeNumbers) allCharacters += '0123456789';
    if (includeUppercase) allCharacters += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (includeLowercase) allCharacters += 'abcdefghijklmnopqrstuvwxyz';
    if (includeSymbols) allCharacters += '!@#\$%^&*()_+-=[]{};:,./<>?';

    return allCharacters[Random().nextInt(allCharacters.length)];
  }

  String generatePassword(int length, bool includeNumbers,
      bool includeUppercase, bool includeLowercase, bool includeSymbols) {
    String allCharacters = '';
    if (includeNumbers) allCharacters += '0123456789';
    if (includeUppercase) allCharacters += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (includeLowercase) allCharacters += 'abcdefghijklmnopqrstuvwxyz';
    if (includeSymbols) allCharacters += '!@#\$%^&*()_+-=[]{};:,./<>?';

    return List.generate(length, (index) {
      return allCharacters[Random().nextInt(allCharacters.length)];
    }).join();
  }

  double _calculatePasswordStrength(String password) {
    return estimatePasswordStrength(password);
  }

  void _incrementLength() {
    setState(() {
      if (length < 50) length++;
    });
  }

  void _decrementLength() {
    setState(() {
      if (length > 8) length--;
    });
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 3, color: Color(0xFFF8EF00)),
              // borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.transparent,
            checkColor: const Color(0xFFF8EF00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            side: const BorderSide(color: Colors.transparent),
          ),
        ),
        Text(
          "   $label",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double strength = _calculatePasswordStrength(password);

    return Scaffold(
      backgroundColor: Colors.black, // Change the background color here

      appBar: AppBar(
        backgroundColor: Colors.black, // Customize the app bar color
        title: Text(
          'PASSWORD \nGENERATOR',
          style: GoogleFonts.tomorrow(
            color: const Color(0xFFF8EF00),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true, // Align the title to the center
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password field
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _passwordController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.fixed,
                      backgroundColor: Colors.black, // Set background color
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 4,
                        child: Center(
                          child: Text(
                            'Password copied to clipboard',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tomorrow(
                              fontSize: 30,
                              color: const Color(0xFFF8EF00), // Set text color
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const ShapeDecoration(
                    color: Color(0x1900F0FF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 2, color: Color(0xFF00F0FF)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _passwordController.text,
                          style: GoogleFonts.tomorrow(
                            color: const Color(0xFF00F0FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.copy_all,
                            color: Color(0xFF00F0FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),

            // Password strength indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: strength,
                    color: strength > 0.7
                        ? Colors.green
                        : (strength > 0.4 ? Colors.orange : Colors.red),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  strength > 0.7
                      ? 'Very strong'
                      : (strength > 0.4 ? 'Strong' : 'Weak'),
                  style: TextStyle(
                    color: strength > 0.7
                        ? Colors.green
                        : (strength > 0.4 ? Colors.orange : Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Length slider with custom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password length:',
                  style: GoogleFonts.tomorrow(
                    fontSize: 20,
                    color: Colors.white, // Set text color
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(length.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementLength,
                  icon: const Icon(
                    Icons.remove,
                    color: Color(0xFF00F0FF),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: length.toDouble(),
                    min: 8.0,
                    max: 50.0,
                    divisions: 42,
                    activeColor: const Color(0xFF00F0FF),
                    inactiveColor: const Color(0xFF00F0FF),
                    thumbColor: const Color(0xFFF8EF00),
                    label: length.toString(),
                    onChanged: (value) {
                      setState(() {
                        length = value.toInt();
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: _incrementLength,
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF00F0FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
             Text(
              'Characters used:',
              style: GoogleFonts.tomorrow(
                fontSize: 20,
                color: Colors.white, // Set text color
                fontWeight: FontWeight.w700,
              ),            ),
            const SizedBox(height: 10),

            // Option checkboxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCheckbox('123', includeNumbers, (value) {
                  setState(() {
                    includeNumbers = value!;
                  });
                }),
                _buildCheckbox('ABC', includeUppercase, (value) {
                  setState(() {
                    includeUppercase = value!;
                  });
                }),
                _buildCheckbox('abc', includeLowercase, (value) {
                  setState(() {
                    includeLowercase = value!;
                  });
                }),
                _buildCheckbox('#\$&', includeSymbols, (value) {
                  setState(() {
                    includeSymbols = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 10),

            ExpansionTile(
              title:Text(
                'Password History:',
                style: GoogleFonts.tomorrow(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              collapsedIconColor: Colors.white,
              iconColor: Colors.white,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: passwordHistory.map((prevPassword) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 1.0), // Add space between items
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prevPassword,
                              style: GoogleFonts.tomorrow(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _passwordController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.fixed,
                                  backgroundColor: Colors.black, // Set background color
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height / 4,
                                    child: Center(
                                      child: Text(
                                        'Password copied to clipboard',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.tomorrow(
                                          fontSize: 30,
                                          color: const Color(0xFFF8EF00), // Set text color
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              ],
            ),

            // Generate button
            const Spacer(),
            Center(
              child: SizedBox(
                width: double.infinity, // Specify the desired width
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFFF8EF00),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: _generatePassword,
                  child: Text(
                    'GENERATE_',
                    style: GoogleFonts.tomorrow(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
