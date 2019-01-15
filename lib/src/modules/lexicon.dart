import 'dart:collection';

import '../models/lemma.dart';

export '../models/lemma.dart';

class Lexicon {
  
  final Set<Lemma> _lemmas;

  Iterable _conpulatives;
  Iterable _words;

  Lexicon(this._lemmas) {
    if (this._lemmas == null || (this._lemmas != null && this._lemmas.length == 0))
      throw 'The lexicon may not be initialized with empty lemmas';
    
    this._conpulatives = _lemmas.where((l) => l.type == LemmaType.CONPULATIVE);
    this._words = _lemmas.where((l) => l.type == LemmaType.WORD);
  }

  Lemma operator [](final String key) => find(key);

  /// find a specific [Lemma] by its word
  Lemma find(String key) {
    if (key == null) 
      return null;

    key = key.toLowerCase().trim();
    
    return _lemmas?.firstWhere((l) => l.lemma == key, orElse: () => null);
  }

  Iterable<Lemma> get words => List<Lemma>.unmodifiable(_words);

  Iterable<Lemma> get conpulatives => List<Lemma>.unmodifiable(_conpulatives);

  /// get all lemmas of the lexicon or by [LemmaType]
  Iterable<Lemma> getAll([LemmaType type = null]) {
    if (type == LemmaType.WORD)
      return _words;
    if (type == LemmaType.CONPULATIVE)
      return _conpulatives;

    return List<Lemma>.unmodifiable(_lemmas);
  }

  /// add a new or replace an existing [Lemma]
  void append(final Lemma lemma) {
    if (lemma == null)
      return;

    Lemma existing = find(lemma.lemma);

    // trying to insert false conpulative
    if (lemma.type == LemmaType.CONPULATIVE && lemma.lemma.indexOf(' ') < 0)
      return;

    _lemmas
      ..remove(existing)
      ..add(lemma);
  }

  // add or replace an [Iterable<Lemma>]
  void appendAll(final Iterable<Lemma> lemmas) => lemmas.forEach(append);
}