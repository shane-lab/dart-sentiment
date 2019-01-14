class Score {
  /// percentage of scored indifferentiality
  final num indifferent;
  /// percentage of scored negativity
  final num negative;
  /// percentage of scored positivity
  final num positive;
  final num _value;
  /// normalizes the sentiment score between -1 and 1
  num get value {
    if (_value > 1.0)
      return 1.0;
    else if (_value < -1.0)
      return -1.0;

    return _value;
  }
  Score(this.indifferent, this.negative, this.positive, this._value);
}