library example;

import 'package:dart_sentiment/sentiment.dart' as sentiment;

void main(List<String> args) async {

  final deserializer = sentiment.AFINNLexiconDeserializer.asAFINN_165_EN();

  final tokenizer = sentiment.WhitespaceAndPunctuationTokenizer();

  final negator = sentiment.ENNegator.create();

  final analyzer = sentiment.SentimentAnalyzer(await deserializer.parse()..append(sentiment.Lemma('good shit', 5, sentiment.LemmaType.CONPULATIVE)), tokenizer, negator, 
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
      'pretty',
      'quite',
      'somewhat',
      'some what',
      'sort of',
      'sorta',
      'sortof',
      'slightly'
    ])
  );

  final score = analyzer.analyze('fucking love');

  if (score != null)
    print(
'''
neu: ${score.indifferent.toStringAsFixed(4)}
neg: ${score.negative.toStringAsFixed(4)}
pos: ${score.positive.toStringAsFixed(4)}
comparative: ${score.value.toStringAsFixed(4)}
'''
    );
}