import '../modules/lexicon.dart';

export '../modules/lexicon.dart';

abstract class LexiconDeserializer {
  /// parses a file or response and converts the lemma scores to a lexicon
  Future<Lexicon> parse();
}