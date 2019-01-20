library example;

import 'dart:io' as io;

import 'package:dart_sentiment/dart_sentiment.dart' as sentiment;

void main(List<String> args) async {

  final deserializer = sentiment.AFINNLexiconDeserializer.asAFINN_165_EN();

  final tokenizer = sentiment.WhitespaceAndPunctuationTokenizer();

  final negator = sentiment.ENNegator.create();

  final adverbs = await _adverbs();

  final analyzer = sentiment.SentimentAnalyzer(await deserializer.parse()..append(sentiment.Lemma('good shit', 5, sentiment.LemmaType.CONPULATIVE)), tokenizer, negator, 
    incrementingAdverbs: Set.of(adverbs[0]),
    decrementingAdverbs: Set.of(adverbs[1])
  );

  final sentence = 'you were never smart';

  final score = analyzer.analyze(sentence);

  if (score != null)
    print(
'''
\"${sentence}\"
neu: ${score.indifferent.toStringAsFixed(4)}
neg: ${score.negative.toStringAsFixed(4)}
pos: ${score.positive.toStringAsFixed(4)}
polarity: ${score.polarity.toStringAsFixed(4)}
'''
    );
}

/// read in the adverbs from a local file
Future<List<Iterable<String>>> _adverbs() async {
  final incrementing = Set<String>();
  final decrementing = Set<String>();

  final regexp = RegExp(r'^(INC|DEC)(\s\w+)+$', caseSensitive: true);

  // format: [INC|DEC][white space][adverb]
  try {
    final file = io.File('${io.Directory.current.path}/example/adverbs.txt');

    final lines = await file.readAsLines();

    for (var line in lines) {
      line = line.trim();

      final matches = regexp.allMatches(line);
      if (matches.length <= 0) 
        continue;

      final splitted = line.split(' ');
      final key = splitted.removeAt(0);
      if (splitted.length >= 1) {
        final adverb = splitted.reduce((a, b) => '${a} ${b ?? ''}').trim();
        if (key == 'INC')
          incrementing.add(adverb);
        else
          decrementing.add(adverb);
      }
    }
  } catch(ex) { }

  return [incrementing, decrementing];
}