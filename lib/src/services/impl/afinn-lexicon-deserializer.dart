import 'dart:io' as io;

import '../lexicon-deserializer.dart';

final _MULTI_WORD_REGEXP = RegExp(r'\s[aA-zZ]', caseSensitive: false);
final _WHITESPACE_REGEXP = RegExp(r'(\s|\t)+');

class AFINNLexiconDeserializer extends LexiconDeserializer { 
  String absolutePath;

  factory AFINNLexiconDeserializer.asAFINN_165_EN() => AFINNLexiconDeserializer._internal('afinn-165-en');
  
  factory AFINNLexiconDeserializer.withCustomFile(final String absolutePath) => AFINNLexiconDeserializer._internal(absolutePath, false);

  AFINNLexiconDeserializer._internal(final String path, [bool isRelative = true]) {
    absolutePath = isRelative ? '${io.Directory.current.path}/lexicons/afinn/${path}.txt' : path;
  }

  @override
  Future<Lexicon> parse() async {
    final lemmas = Set<Lemma>();
    
    // format: [key][white space][value]
    try {
      final file = io.File(absolutePath);

      final lines = await file.readAsLines();

      for (var line in lines) {
        line = line.trim();

        // check if read-in the lemma contains multiple words
        final matches = _MULTI_WORD_REGEXP.allMatches(line);
        if (matches.length > 0) {
          var shallowCopy = line;
          for (int i = 0; i < matches.length; i++) {
            final match = matches.elementAt(i);
            final ch = match.group(0).trim();
            shallowCopy = shallowCopy.replaceFirst(' ${ch}', '_${ch}');
          }
          line = shallowCopy;
        }
        final splitted = line.split(_WHITESPACE_REGEXP);
        if (splitted.length == 2) // all strings should be splitted as lemma(key) score(value)
          lemmas.add(Lemma(splitted[0].replaceAll('_', ' '), int.parse(splitted[1]), splitted[0].contains('_') ? LemmaType.CONPULATIVE : LemmaType.WORD));
      }
    } catch(ex) { }

    return Lexicon(lemmas);
  }
}