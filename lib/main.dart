// ignore_for_file: depend_on_referenced_packages, camel_case_types, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/cs.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Code IDE',
      home: CodeIDE_Screen(),
    );
  }
}

class CodeIDE_Screen extends StatefulWidget {
  const CodeIDE_Screen({super.key});

  @override
  State<CodeIDE_Screen> createState() => _CodeIDE_ScreenState();
}

class _CodeIDE_ScreenState extends State<CodeIDE_Screen> {
  late CodeController _controller;
  final TextEditingController _outputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedlanguage = 'Python';
  final List<String> _languages = [
    'Python',
    'Dart',
    'Java',
    'Javascript',
    // 'C',
    // 'C#',
    // 'C++',
  ];

  Future<void> _runCode() async {
    final String code = _controller.text;
    final url = Uri.parse('http://127.0.0.1:8000/api/execute/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code, 'language': _selectedlanguage}),
      );
      if (response.statusCode == 200) {
        final output = jsonDecode(response.body)['output'];
        setState(() {
          _outputController.text = output;
        });
      } else {
        setState(() {
          _outputController.text = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _outputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: '',
      language: _getHighlightLanguage(_selectedlanguage),
    );
  }

  void _updateControllerLanguage(String language) {
    setState(() {
      _controller.dispose();
      _controller = CodeController(
        text: _controller.text,
        language: _getHighlightLanguage(language),
      );
    });
  }

  dynamic _getHighlightLanguage(String language) {
    switch (language) {
      case 'Python':
        return python;
      case 'Dart':
        return dart;
      case 'Java':
        return java;
      case 'Javascript':
        return javascript;
      case 'C#':
        return cs;
      case 'C++':
        return cpp;
      default:
        return python;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Logic Complier',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: monokaiSublimeTheme['root']?.backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(controller: _scrollController, children: [
              CodeTheme(
                data: CodeThemeData(styles: monokaiSublimeTheme),
                child: CodeField(
                  lineNumbers: true,
                  lineNumberStyle: const GutterStyle(
                      textAlign: TextAlign.center,
                      showErrors: true,
                      margin: 1,
                      textStyle:
                          TextStyle(fontFamily: 'SourceCode', height: 1.53)),
                  controller: _controller,
                  textStyle: const TextStyle(fontFamily: 'SourceCode'),
                ),
              ),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 150,
                child: Center(
                  child: TextField(
                    controller: _outputController,
                    readOnly: true,
                    maxLines: null,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Output'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (MediaQuery.of(context).size.width > 500)
              Expanded(
                child: DropdownButtonFormField(
                  menuMaxHeight: 150,
                  value: _selectedlanguage,
                  items: _languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedlanguage = value.toString();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            if (MediaQuery.of(context).size.width < 500)
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: _updateControllerLanguage,
                  icon: const Icon(Icons.computer),
                  itemBuilder: (BuildContext context) {
                    return _languages.map((String language) {
                      return PopupMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList();
                  },
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runCode,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
