import '../negator.dart';

const _NEGATES = const [
  'no',
  'not',
  'nor',
  'nope',
  'never',
  'dont',
  'don\'t',
  'doesnt',
  'doesn\'t',
  'didnt',
  'didn\'t',
  'isnt',
  'isn\'t',
  'aint',
  'ain\'t',
  'arent',
  'aren\'t',
  'wasnt',
  'wasn\'t',
  'hasnt',
  'hasn\'t',
  'hadnt',
  'hadn\'t',
  'havent',
  'haven\'t',
  'couldnt',
  'couldn\'t',
  'shoudnt',
  'shouldn\'t',
  'shant',
  'wont',
  'won\'t'
  'wouldnt',
  'wouldn\'t',
  'cant',
  'can\'t',
  'musnt',
  'musn\'t',
  'yesnt',
  'yesn\'t',
  'neednt',
  'needn\'t'
];

/// Regular expression to check if a word ends with [consonant + (nt or n't)] (in most cases of the English language this would be a negate)
final _AUTO_NT_REGEXP = RegExp('([b-df-hj-np-tv-z])(nt|n\'t)\$', caseSensitive: false);

/// An English (US) negator
class ENNegator extends Negator {

  final List<String> _negatedWords;

  /// create negator and optionally extend with additional negates
  factory ENNegator.create([List<String> words]) => ENNegator._internal(words != null ? [_NEGATES, words].expand((x) => x).toList() : _NEGATES);

  ENNegator._internal(this._negatedWords);

  bool isNegated(final String input) {
    // check if the sentence contains a negator
    final negated = input.trim().toLowerCase().split(' ').firstWhere((s) => _negatedWords.contains(s) || _AUTO_NT_REGEXP.hasMatch(s), orElse: () => null);

    return negated != null;
  }
}