import 'package:flutter/material.dart';

import '../utils/game_constants.dart';

/// One tappable answer option.
///
/// Presentation only: it does not know whether the answer is right or wrong.
/// The parent decides what happens in [onPressed].
///
/// - [text]: the answer text shown on the button.
/// - [onPressed]: called when the button is tapped.
/// - [isEnabled]: when false (or when [onPressed] is null) the button is
///   dimmed and ignores taps. Defaults to true.
/// - [isCorrect]: when true the button is shown in green. The parent sets it
///   only after the player picked the correct answer. There is no
///   "wrong answer" state: an incorrect answer keeps the normal look.
class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isCorrect;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isCorrect = false,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _cardColor = Color(0xFF1E2933);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    final bool canTap = isEnabled && onPressed != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: isCorrect
            ? AppColors.success.withValues(alpha: 0.25)
            : _cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          // A null onTap disables the ripple and the tap.
          onTap: canTap ? onPressed : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCorrect
                    ? AppColors.success
                    : _accentColor.withValues(alpha: canTap ? 0.4 : 0.15),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: (canTap || isCorrect) ? Colors.white : Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
