// ignore_for_file: depend_on_referenced_packages, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
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
      // darkTheme: ThemeData.dark(),
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
    Widget _codeide() {
      return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          boxShadow: [],
          borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                    textStyle: TextStyle(height: 1.5)),
                controller: _controller,
                textStyle: const TextStyle(fontFamily: 'SourceCode'),
              ),
            ),
          ]),
        ),
      );
    }

    Widget? screenresponsive() {
      if (MediaQuery.of(context).size.width >= 700) {
        return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: _codeide(),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 150,
                              child: Center(
                                child: TextField(
                                  controller: _outputController,
                                  readOnly: true,
                                  maxLines: 20,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Output'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField(
                              menuMaxHeight: 300,
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
                          if (_selectedlanguage == "Java")
                            const Text(
                                'Use Class Name as <temp> when programming on java')
                        ],
                      ),
                    )),
              ],
            ));
      } else if (MediaQuery.of(context).size.width <= 700) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _codeide()),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField(
                  menuMaxHeight: 300,
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
              const SizedBox(height: 5),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: TextField(
                      controller: _outputController,
                      readOnly: true,
                      maxLines: 20,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Output'),
                    ),
                  ),
                ),
              ),
              if (_selectedlanguage == "Java")
                const Center(
                    child: Text(
                        'Use Class Name as <temp> when programming on java')),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      } else {
        return null;
      }
    }

    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tascuit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Logic',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton.icon(
                onPressed: _runCode,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text("Run"),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
            )
          ],
        ),
        body: screenresponsive());

    // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    // floatingActionButton: FloatingActionButton(
    //   onPressed: _runCode,
    //   child: const Icon(Icons.play_arrow),
    // ),
  }
}
