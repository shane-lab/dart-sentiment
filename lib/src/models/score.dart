class Score {
  /// percentage of scored indifferentiality
  final num indifferent;
  /// percentage of scored negativity
  final num negative;
  /// percentage of scored positivity
  final num positive;
  /// the polarity score between the negative and the positive
  final num _polarity;
  /// normalizes the sentiment score between -1 and 1
  num get polarity {
    if (_polarity > 1.0)
      return 1.0;
    else if (_polarity < -1.0)
      return -1.0;

    return _polarity;
  }
  Score(this.indifferent, this.negative, this.positive, this._polarity);
}