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

  final stopWords = Set.of([
      'i',
      'me',
      'my',
      'myself',
      'we',
      'our',
      'ours',
      'ourselves',
      'you',
      'you\'re',
      'you\'ve',
      'you\'ll',
      'you\'d',
      'your',
      'yours',
      'yourself',
      'yourselves',
      'he',
      'him',
      'his',
      'himself',
      'she',
      'she\'s',
      'her',
      'hers',
      'herself',
      'it',
      'it\'s',
      'its',
      'itself',
      'they',
      'them',
      'their',
      'theirs',
      'themselves',
      'what',
      'which',
      'who',
      'whom',
      'this',
      'that',
      'that\'ll',
      'these',
      'those',
      'am',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'having',
      'do',
      'does',
      'did',
      'doing',
      'a',
      'an',
      'the',
      'and',
      'but',
      'if',
      'or',
      'because',
      'as',
      'until',
      'while',
      'of',
      'at',
      'by',
      'for',
      'with',
      'about',
      'against',
      'between',
      'into',
      'through',
      'during',
      'before',
      'after',
      'above',
      'below',
      'to',
      'from',
      'up',
      'down',
      'in',
      'out',
      'on',
      'off',
      'over',
      'under',
      'again',
      'further',
      'then',
      'once',
      'here',
      'there',
      'when',
      'where',
      'why',
      'how',
      'all',
      'any',
      'both',
      'each',
      'few',
      'more',
      'most',
      'other',
      'some',
      'such',
      'no',
      'nor',
      'not',
      'only',
      'own',
      'same',
      'so',
      'than',
      'too',
      'very',
      's',
      't',
      'can',
      'will',
      'just',
      'should',
      'should\'ve',
      'now',
      'd',
      'll',
      'm',
      'o',
      're',
      've',
      'y'
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