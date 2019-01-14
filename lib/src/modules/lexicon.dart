import '../models/lemma.dart';

export '../models/lemma.dart';

class Lexicon {
  
  final Set<Lemma> _lemmas;

  Lexicon(this._lemmas);

  Lemma operator [](final String key) => find(key);

  Lemma find(final String key) 
    => key != null ? _lemmas?.firstWhere((l) => l.lemma == key.trim().toLowerCase(), orElse: () => null) : null;

  Iterable<Lemma> get words => List<Lemma>.unmodifiable(_lemmas).where((l) => l.type == LemmaType.WORD);

  Iterable<Lemma> get conpulatives => List<Lemma>.unmodifiable(_lemmas).where((l) => l.type == LemmaType.CONPULATIVE);

  void append(final Lemma lemma) {
    if (_lemmas == null)
      return;

    Lemma existing = find(lemma.lemma);

    // trying to insert false conpulative
    if (lemma.type == LemmaType.CONPULATIVE && lemma.lemma.indexOf(' ') < 0)
      return;

    _lemmas
      ..remove(existing)
      ..add(lemma);
  }

  void appendAll(final Iterable<Lemma> lemmas) => lemmas.forEach(append);
}