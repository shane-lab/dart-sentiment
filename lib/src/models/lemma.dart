enum LemmaType {
  WORD,
  CONPULATIVE
}

class Lemma {
  final String lemma;
  final num score;
  final LemmaType type;

  Lemma(String lemma, this.score, this.type): this.lemma = lemma.toLowerCase().trim();

  operator==(dynamic other) {
    if (other == null && !(other is Lemma))
      return false;

    return other.hashCode == hashCode;
  }

  @override
  int get hashCode {
    int hash = 7;
    hash = 31 * hash + lemma.hashCode;
    hash = 31 * hash + score.hashCode;
    hash = 31 * hash + type.hashCode;

    return hash;
  }
}