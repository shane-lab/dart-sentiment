enum LemmaType {
  WORD,
  CONPULATIVE
}

class Lemma {
  final String lemma;
  final num score;
  final LemmaType type;

  Lemma(this.lemma, this.score, this.type);
}