import '../tokenizer.dart';

final _PUNCTUATION_REGEXP = RegExp(r'[!"#$%&()*+,./:;<=>?@[\]^_`{|}~]');
final _WHITESPACE_REGEXP = RegExp(r'(\s|\t|\r|\n)+');

class WhitespaceAndPunctuationTokenizer extends Tokenizer {
  List<String> tokenize(final String input) 
    => input
      .trim()
      .toLowerCase()
      .replaceAll(_PUNCTUATION_REGEXP, '')
      .split(_WHITESPACE_REGEXP)
      ..removeWhere((s) => s.trim().length == 0);
}