import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _passwordController.text = password;
  }

  void _generatePassword() {
    setState(() {
      password = generatePassword(
        length,
        includeNumbers,
        includeUppercase,
        includeLowercase,
        includeSymbols,
      );
      _passwordController.text = password;
    });
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
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFC5D6E0)),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.transparent,
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            side: const BorderSide(color: Colors.transparent),
          ),
        ),
        Text("   $label"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double strength = _calculatePasswordStrength(password);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password field
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: _passwordController.text));
                // Optionally show a snackbar or toast to indicate the text has been copied
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password copied to clipboard')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: strength > 0.7
                  ? Colors.green
                      : (strength > 0.4 ? Colors.orange : Colors.red),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _passwordController.text,
                        style: const TextStyle(
                          height: 1.4,
                          color: Colors.black, // Adjust color as needed
                        ),
                      ),
                    ),
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.copy_all,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ),
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
                const Text('Password length:'),
                Text(length.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementLength,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Slider(
                    value: length.toDouble(),
                    min: 8.0,
                    max: 50.0,
                    divisions: 42,
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
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Characters used:'),
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

            // Generate button
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xFF0070F6)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(400),
                    ),
                  ),
                ),
                onPressed: _generatePassword,
                child: const Text('Generate',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
