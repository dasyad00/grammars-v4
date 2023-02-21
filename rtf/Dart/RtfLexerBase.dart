// Copied from https://github.com/antlr/grammars-v4
// ignore_for_file: non_constant_identifier_names, file_names
import 'package:antlr4/antlr4.dart';

abstract class RtfLexerBase extends Lexer {
  var nestingLevel = 0;
  RtfLexerBase(CharStream input) : super(input);

  void openingBrace() {
    nestingLevel++;
  }

  void closingBrace() {
    if (--nestingLevel == 0) popMode();
  }
}
