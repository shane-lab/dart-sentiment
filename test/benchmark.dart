import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:dart_sentiment/dart_sentiment.dart';

void main() async {
  final deserializer = AFINNLexiconDeserializer.asAFINN_165_EN();

  final tokenizer = WhitespaceAndPunctuationTokenizer();

  final negator = ENNegator.create();

  final constradictor = ENContradictor();

  final incrementingAdverbs = Set.of([
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
    ]);
  final decrementingAdverbs = Set.of([
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
    ]);

    _SentimentAnalyzerBenchmark(SentimentAnalyzer(
      await deserializer.parse(),
      tokenizer,
      negator,
      constradictor,
      incrementingAdverbs: incrementingAdverbs,
      decrementingAdverbs: decrementingAdverbs
    ), 'I love the beach, but the weather today is awful!')
    ..report();
}

class _SentimentAnalyzerBenchmark extends BenchmarkBase {
  final SentimentAnalyzer _analyzer;
  final String _sentence;
  _SentimentAnalyzerBenchmark(this._analyzer, this._sentence) : super('Sentiment Analyzer');

  @override
  void run() => _analyzer.analyze(_sentence);

  @override
  void report() {
    print('running benchmark for 2000ms...');
    super.report();
  }
}