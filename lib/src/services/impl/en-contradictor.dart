import '../contradictor.dart';

/// An English (US) contradictor
class ENContradictor extends Contradictor {

  @override
  bool isContradictor(final String word) => word != null && word == 'but';

  @override
  int contradictedAt(final String input) => input.trim().toLowerCase().split(' ').indexOf('but');
}