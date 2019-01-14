import 'package:test/test.dart';

import 'package:dart_sentiment/sentiment.dart';

void main() {
  Tokenizer tokenizer;
  setUp(() async {
    tokenizer = WhitespaceAndPunctuationTokenizer();
  });

  test('Input should be tokenized as indiviual words', () {
    final words = tokenizer.tokenize('I like coffee');
    expect(['i', 'like', 'coffee'], words);
  });

  test('Input should be tokenized without punctuations', () {
    final words = tokenizer.tokenize('I like coffee, but I love tea!');
    expect(false, words.contains(','));
    expect(['i', 'like', 'coffee', 'but', 'i', 'love', 'tea'], words);
  });

  test('Whitespace input should return an empty array', () {
    expect([], tokenizer.tokenize(''));
    expect([], tokenizer.tokenize('\n'));
    expect([], tokenizer.tokenize('\t'));
    expect([], tokenizer.tokenize('\r'));
  });

  test('Input should be tokenized without emoticons', () {
    final words = tokenizer.tokenize('This input has emoticons :)');
    expect(['this', 'input', 'has', 'emoticons'], words);
  });

  test('Input should preserve contractions', () {
    final words = tokenizer.tokenize('This input has contractions, doesn\'t it?');
    expect(['this','input', 'has', 'contractions', 'doesn\'t', 'it'], words);
  });

  test('Input should preserve hyphened words', () {
    final words = tokenizer.tokenize('This input has hyphened-words');
    expect(['this', 'input', 'has', 'hyphened-words'], words);
  });
}