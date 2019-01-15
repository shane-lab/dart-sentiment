enum LemmaType {
  WORD,
  CONPULATIVE
}

class Lemma {
  final String lemma;
  final num score;
  final LemmaType type;

  Lemma(String lemma, this.score, this.type): this.lemma = lemma.toLowerCase().trim();
}