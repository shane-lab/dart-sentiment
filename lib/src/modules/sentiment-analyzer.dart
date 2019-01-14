import 'dart:math' as math;

import '../models/index.dart';

import '../services/index.dart';

const _PUNCTUATIONS = const [
  '.',
  ',',
  '`',
  '\'',
  '"'
  '?',
  '!',
  ';',
  ':',
  '-',
  '_'
];

enum _ADVERB_TYPE {
  INCREMENTAL,
  DECREMENTAL,
  NONE
}

const _INCREMENT = 0.3;
const _DECREMENT = -0.3;

final _SPECIAL_CHARS_REGEXP = RegExp(r'[!@#$%^&(),.?":\{\}|<>\\\/\[\]_-~\+\*`]', multiLine: true, caseSensitive: false);

class SentimentAnalyzer {

  final Lexicon _lexicon;

  final Tokenizer _tokenizer;

  final Negator _negator;

  Set<String> _incrementingAdverbs;

  Set<String> _decrementingAdverbs;

  SentimentAnalyzer(this._lexicon, this._tokenizer, this._negator, {Set<String> incrementingAdverbs, Set<String> decrementingAdverbs}) {
    this._incrementingAdverbs = incrementingAdverbs;
    this._decrementingAdverbs = decrementingAdverbs;
  }

  Score analyze(final String input) {
    // individual words of the given input
    final words = _tokenizer.tokenize(input);

    // tallied score of input
    final scores = List<num>();

    final conpulatives = _lexicon.conpulatives;
    
    // conpulative of an iterated word
    String conpulative;
    int skipped = 0;

    var remainingInput = input.trim().toLowerCase();
    for (var i = 0; i < words.length; i++) {
      var word = words[i].toLowerCase();
      
      // check for a copulative of the current word
      if (conpulative == null) {
        final candidates = conpulatives.where((l) => l.lemma.startsWith('${word} '));
        if (candidates != null && candidates.length > 0) {
          for (var candidate in candidates) {
            // check if the given (remaining) input starts with one of the full conpulatives
            if (conpulative == null && remainingInput.startsWith(candidate.lemma)) {
              conpulative = candidate.lemma;
              continue;
            }
          }
        }

        skipped = 0;
      }
      
      // remove word from the given input
      final index = remainingInput.indexOf(word);
      if (index >= 0)
        remainingInput = remainingInput.substring(index + (word.length)).trimLeft();

      if (conpulative != null) {
        // skip loop until the full conpulative is met
        final skips = conpulative.split(' ').length;
        skipped++;
        if (skipped != skips) 
          continue;

        word = conpulative;

        conpulative = null;
      }

      final lemma = _lexicon[word];
      if (lemma != null && _checkAdverbType(word) == _ADVERB_TYPE.NONE)
        scores.add(_validity(lemma, words, i));
    }

    // scores = 

    return _calc(scores, words.length);
  }
  
  _ADVERB_TYPE _checkAdverbType(final String word) {
    if (word == null)
      return _ADVERB_TYPE.NONE;
    
    if(_incrementingAdverbs != null && _incrementingAdverbs.contains(word))
      return _ADVERB_TYPE.INCREMENTAL;
    else if(_decrementingAdverbs != null && _decrementingAdverbs.contains(word))
      return _ADVERB_TYPE.DECREMENTAL;

    return _ADVERB_TYPE.NONE;
  }

  /// checks and returns the score of word
  num _validity(final Lemma lemma, final List<String> words, int index) {
    if (lemma == null)
      return 0;

    var score = lemma.score;

    var precedingWords = [];
    // check preceding words (up to two) to either increase, decrease, or nullify the score of the lemma when negated
    for (var i = 0; i < 2; i++) {
      var precedingWord = index > i ? words[index - (i + 1)] : null;
      if (precedingWord != null) {
        score += _amplifyLemmaScore([[precedingWord], precedingWords].expand((w) => w).join(' '), score);

        precedingWords.add(precedingWord);
      }
    }

    return score;
  }

  /// increases or decreases the lemma based on the given adverb
  num _amplifyLemmaScore(final String word, num score) {
    num amp = 0.0;

    final type = _checkAdverbType(word);
    if (type != _ADVERB_TYPE.NONE) {
      amp = type == _ADVERB_TYPE.INCREMENTAL ? _INCREMENT : _DECREMENT;
      if (score < 0)
        amp *= -1;
      else if (score > 0)
        amp *= 1;
    }

    return amp;
  }

  // contradictory

  // peculiarities

  Score _calc(Iterable<num> scores, int wordCount) {
    num indifferent = 0;
    num negative = 0;
    num positive = 0;
    num tallied = 0;
    for (var score in scores) {
      if (score == 0)
        indifferent += 1;
      else if (score < 0)
        negative += score - 1;
      else if (score > 0)
        positive += score + 1;

      tallied += score;
    }

    var normalized = tallied != 0 ? tallied / math.sqrt(tallied * tallied + /*wordCount*/ 15) : 0.0;

    if (normalized > 1.0)
      normalized = 1.0;
    else if (normalized < -1.0)
      normalized = -1.0;

    return Score(indifferent, negative, positive, normalized);
  }
}