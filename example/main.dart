library example;

import 'package:dart_sentiment/sentiment.dart' as sentiment;

void main(List<String> args) async {

  final deserializer = sentiment.AFINNLexiconDeserializer.asAFINN_165_EN();

  final tokenizer = sentiment.WhitespaceAndPunctuationTokenizer();

  final negator = sentiment.ENNegator.create();

  final analyzer = sentiment.SentimentAnalyzer(await deserializer.parse(), tokenizer, negator, 
    incrementingAdverbs: Set.of([
      'absolutely',
      'amazingly',
      'completely',
      'considerably',
      'extremely',
      'fully',
      'fucking',
      'greatly',
      'incredibly',
      'quite',
      'really',
      'remarkably',
      'tremendously',
      'unbelievably',
      'utterly',
      'very'
    ]),
    decrementingAdverbs: Set.of([
      'almost',
      'barely',
      'hardly',
      'kind of',
      'kinda',
      'kindof',
      'partly',
      'somewhat',
      'some what',
      'sort of',
      'sorta',
      'sortof'
    ])
  );

  final score = analyzer.analyze('absolutely shit');

  if (score != null)
    print(
'''
neu: ${score.indifferent}
neg: ${score.negative}
pos: ${score.positive}
comparative: ${score.value}
'''
    );
}