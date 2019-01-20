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

const _NEGATE_SCALAR = -0.75;

final _SPECIAL_CHARS_REGEXP = RegExp(r'[!@#$%^&(),.?":\{\}|<>\\\/\[\]_-~\+\*`]', multiLine: true, caseSensitive: false);

class SentimentAnalyzer {

  final Lexicon _lexicon;

  final Tokenizer _tokenizer;

  final Negator _negator;

  Set<String> _incrementingAdverbs;

  Set<String> _decrementingAdverbs;

  SentimentAnalyzer(this._lexicon, this._tokenizer, this._negator, {Set<String> incrementingAdverbs, Set<String> decrementingAdverbs}) {
    this._incrementingAdverbs = incrementingAdverbs != null ? List<String>.unmodifiable(incrementingAdverbs).toSet() : null;
    this._decrementingAdverbs = decrementingAdverbs != null ? List<String>.unmodifiable(decrementingAdverbs).toSet() : null;
  }

  int get _maxAdverbs {
    int _a = _incrementingAdverbs?.reduce((a, b) => a.split(' ').length > b.split(' ').length ? a : b)?.split(' ')?.length ?? 0;
    int _b = _decrementingAdverbs?.reduce((a, b) => a.split(' ').length > b.split(' ').length ? a : b)?.split(' ')?.length ?? 0;

    return _a > _b ? _a : _b;
  }

  Score analyze(final String input) {
    // individual words of the given input
    final words = _tokenizer.tokenize(input).map((s) => s.toLowerCase()).toList();

    // tallied score of input
    final scores = List<num>();

    final conpulatives = _lexicon.conpulatives;
    
    // conpulative of an iterated word
    String conpulative;
    int skipped = 0;

    var remainingInput = words.join(' ').trim().toLowerCase();
    for (var i = 0; i < words.length; i++) {
      var word = words[i];
      
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

          if (conpulative != null)
            print('found conpulative lemma: \'${conpulative}\'');
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
      if (lemma != null && !_lookAhead(word, words, i))
        scores.add(_validity(lemma, words, word.contains(RegExp(r'\s+')) ? i - (word.split(' ').length - 1) : i));
      else
        scores.add(0);
    }

    // scores = 

    return _tally(scores);
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

  /// checks if the next word is another registered adverb to increment or decrement, returns true when the word is an adverb or registered as part of the lexicon
  bool _lookAhead(final String word, final List<String> words, int index) {
    if (word != null && words != null && words.length - 1 > index) {
      var nextWord = words[index + 1];
      if (_checkAdverbType(word) != _ADVERB_TYPE.NONE) {
        bool isAdverb = _checkAdverbType(nextWord) != _ADVERB_TYPE.NONE;
        if (!isAdverb)
          return _lexicon.find(nextWord) != null;

        return true;
      }
    }

    return false;
  }

  /// checks if the given word is (part of) an adverb
  List<bool> _isAdverb(final String word) {
    if (word == null)
      return [false, false];

    final merger = List<Iterable<String>>();
    if (_incrementingAdverbs != null)
      merger.add(_incrementingAdverbs);
    if (_decrementingAdverbs != null)
      merger.add(_decrementingAdverbs);

    final set = Set<String>.of(merger.expand((x) => x));

    if (set.length == 0)
      return [false, false];

    bool isPartial = false;
    bool flag = set.where((adverb) {
      // check if last word is (part of) the adverb
      final splitted = adverb.split(' ');
      if (splitted[splitted.length - 1] == word) {
        if (splitted.length > 1) 
          isPartial = true;
        
        return true;
      }

      return adverb == word;
    }).length > 0;

    return [flag, isPartial];
  }

  /// checks and returns the score of word, amplified by the preceding adverbs
  num _validity(final Lemma lemma, final List<String> words, int index) {
    if (lemma == null)
      return 0;

    num amplifier = 0;

    // check for possible preceding adverbs
    int i = 0, n = 0;
    bool flag0 = index > i;
    do {
      final j = index - (i + 1);
      if (j < 0) {
        flag0 = false;
        continue;
      }
      var precedingWord = words[j];

      var adverbCheck = _isAdverb(precedingWord);
      var isAdverb = adverbCheck[0];
      var isPartial = adverbCheck[1];

      // word is not an adverb, break 
      if (!isAdverb) {
        flag0 = false;
        break;
      }

      // fetch full the adverb of the returned partial adverb
      if (isPartial) {
        final k = j - 1;
        if (k < 0) {
          flag0 = false;
          continue;
        }
        
        // store preceding words of the partial adverb untill an adverb is formed
        final precedingWords = [precedingWord];

        bool flag1 = true;

        int l = 0;
        do {
          if ((k - l) < 0) {
            flag1 = false;
            continue;
          }

          precedingWord = words[k - l];
          final conpulative = [[precedingWord], precedingWords].expand((x) => x).join(' ');

          adverbCheck = _isAdverb(conpulative);
          isAdverb = adverbCheck[0];
          isPartial = adverbCheck[1];

          if (!isAdverb && !isPartial) {
            flag0 = false;
            precedingWord = null;
            break;
          }

          if (!isAdverb || (isAdverb && !isPartial)) {
            if (isAdverb && !isPartial) 
              precedingWord = conpulative;

            flag1 = false;
            n++;
            continue;
          }

          precedingWords.add(precedingWord);
          l++;
        } while (flag1);
      } 

      amplifier += (_amplifier(precedingWord, lemma.score) * (1 - (.05 * i)));

      i++;
    } while (flag0);

    var score = lemma.score + amplifier;

    // trying to find a negator before the current index and all preceding adverbs
    final negatorIndex = index - (i + n + 1);
    if (negatorIndex >= 0 && _negator.isNegator(words[negatorIndex])) 
      score *= _NEGATE_SCALAR;

    return score;
  }

  /// returns the adverb (increase or decrease) amplifier based on the score of the corresponding lemma
  num _amplifier(final String word, num score) {
    num amp = 0.0;

    _ADVERB_TYPE type = _checkAdverbType(word);
    if (type != _ADVERB_TYPE.NONE) {
      print('adverb: \'${word}\', type: ${type}');
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

  Score _tally(Iterable<num> scores) {
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

    // TODO: test comparive score on length - length should be the estimated mean of words in a single sentence
    var normalized = tallied != 0 ? tallied / math.sqrt(tallied * tallied + 15) : 0.0; 

    if (normalized > 1.0)
      normalized = 1.0;
    else if (normalized < -1.0)
      normalized = -1.0;

    // percentages
    num total = indifferent + negative.abs() + positive;
    num pIndifferent = indifferent != 0 ? (indifferent / total).abs() : 0;
    num pNegative = negative != 0 ? (negative / total).abs() : 0;
    num pPositive = positive != 0 ? (positive / total).abs() : 0;

    return Score(pIndifferent, pNegative, pPositive, normalized);
  }
}