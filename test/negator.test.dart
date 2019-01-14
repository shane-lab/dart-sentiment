import 'package:test/test.dart';

import 'package:dart_sentiment/sentiment.dart';

void main() {
  Negator negator;
  setUp(() async {
    negator = ENNegator.create();
  });

  test('Input should not be negated', () {
    final flag = negator.isNegated('I like coffee');
    expect(false, flag);
  });

  test('Input should be negated', () {
    final flag0 = negator.isNegated('I dont like coffee');
    final flag1 = negator.isNegated('I don\'t like coffee');
    expect(flag0, flag1);
    expect([true, true], [flag0, flag1]);
  });

  test('Input should be automatically negated when a word is ending on nt', () {
    final flag0 = negator.isNegated('gibberish wordsnt gibberish');
    final flag1 = negator.isNegated('gibberish wordsn\'t gibberish');
    expect(flag0, flag1);
    expect([true, true], [flag0, flag1]);
  });

  test('Input should not be automatically negated when a word is ending on nt', () {
    final flag0 = negator.isNegated('gibberish appointment gibberish');
    final flag1 = negator.isNegated('gibberish counterirritant gibberish');
    expect(flag0, flag1);
    expect([false, false], [flag0, flag1]);
  });
}