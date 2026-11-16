import 'package:flutter/material.dart';
import '../services/progress_tracker.dart';
import '../utils/game_constants.dart';
import 'game_screen.dart';

class ChallengeSelectionScreen extends StatefulWidget {
  const ChallengeSelectionScreen({super.key});

  @override
  State<ChallengeSelectionScreen> createState() =>
      _ChallengeSelectionScreenState();
}

class _ChallengeSelectionScreenState extends State<ChallengeSelectionScreen> {
  int completedChallenges = 0;

  @override
  void initState() {
    super.initState();
    completedChallenges = ProgressTracker.completedChallenges.value;
    ProgressTracker.completedChallenges.addListener(_syncProgress);
    // Make sure the list matches the saved progress (same data as Home).
    ProgressTracker.load();
  }

  void _syncProgress() {
    if (!mounted) return;
    setState(() {
      completedChallenges = ProgressTracker.completedChallenges.value;
    });
  }

  @override
  void dispose() {
    ProgressTracker.completedChallenges.removeListener(_syncProgress);
    super.dispose();
  }

  Future<void> _openChallenge(int challengeNumber) async {
    final isUnlocked = challengeNumber <= completedChallenges + 1;
    if (!isUnlocked) return;

    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          challengeNumber: challengeNumber,
        ),
      ),
    );

    if (!mounted) return;
    if (completed == true && challengeNumber > completedChallenges) {
      setState(() {
        completedChallenges = challengeNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 720
                ? 6
                : width >= 540
                    ? 5
                    : width >= 400
                        ? 4
                        : 3;

            final rows =
                (GameConstants.totalChallenges + columns - 1) ~/ columns;
            final useFixedMap = width >= 720;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width < 500 ? 12 : 22,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MissionHeader(
                    totalChallenges: GameConstants.totalChallenges,
                  ),
                  const SizedBox(height: 14),
                  const _MapLegend(),
                  const SizedBox(height: 10),
                  if (useFixedMap)
                    Expanded(
                      child: _buildMissionMap(columns, rows),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: rows * 100.0,
                          child: _buildMissionMap(columns, rows),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'COMPLETE A MISSION TO UNLOCK THE NEXT',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMissionMap(int columns, int rows) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _SnakeRoutePainter(
            columns: columns,
            rows: rows,
            total: GameConstants.totalChallenges,
          ),
        ),
        Column(
          children: List.generate(rows, (rowIndex) {
            final firstNumber = rowIndex * columns + 1;
            final remaining =
                GameConstants.totalChallenges - rowIndex * columns;
            final count = remaining < columns ? remaining : columns;
            final emptySlotsAtStart =
                rowIndex.isOdd ? columns - count : 0;

            return Expanded(
              child: Row(
                children: List.generate(columns, (visualColumn) {
                  int? number;

                  if (rowIndex.isEven) {
                    if (visualColumn < count) {
                      number = firstNumber + visualColumn;
                    }
                  } else if (visualColumn >= emptySlotsAtStart) {
                    number = firstNumber +
                        count -
                        1 -
                        (visualColumn - emptySlotsAtStart);
                  }

                  if (number == null) {
                    return const Expanded(child: SizedBox.shrink());
                  }

                  final isCompleted = number <= completedChallenges;
                  final isUnlocked = number <= completedChallenges + 1;

                  return Expanded(
                    child: _MissionNode(
                      number: number,
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                      onTap: () => _openChallenge(number!),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MissionHeader extends StatelessWidget {
  final int totalChallenges;

  const _MissionHeader({required this.totalChallenges});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: AppColors.primary.withOpacity(0.10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.45),
            ),
          ),
          child: const Icon(
            Icons.radar_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CODE BREAKER',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'MISSION MAP',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            '$totalChallenges MISSIONS',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: const [
        _LegendItem(color: AppColors.success, label: 'COMPLETED'),
        _LegendItem(color: AppColors.primary, label: 'AVAILABLE'),
        _LegendItem(color: AppColors.locked, label: 'LOCKED'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.65),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _MissionNode extends StatelessWidget {
  final int number;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _MissionNode({
    required this.number,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isCompleted
        ? AppColors.success
        : isUnlocked
            ? AppColors.primary
            : AppColors.locked;

    final label = isCompleted
        ? 'CLEARED'
        : isUnlocked
            ? 'START'
            : 'LOCKED';

    final icon = isCompleted
        ? Icons.check_rounded
        : isUnlocked
            ? Icons.play_arrow_rounded
            : Icons.lock_rounded;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? const [
                        Color(0xFF153B39),
                        Color(0xFF102A30),
                      ]
                    : isUnlocked
                        ? const [
                            Color(0xFF17323B),
                            Color(0xFF17243A),
                          ]
                        : const [
                            Color(0xFF1A2030),
                            Color(0xFF121827),
                          ],
              ),
              border: Border.all(
                color: accent.withOpacity(isUnlocked ? 0.75 : 0.35),
                width: isUnlocked ? 1.2 : 0.8,
              ),
              boxShadow: [
                if (isUnlocked)
                  BoxShadow(
                    color: accent.withOpacity(0.13),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.14),
                        border: Border.all(
                          color: accent.withOpacity(0.7),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 23,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnakeRoutePainter extends CustomPainter {
  final int columns;
  final int rows;
  final int total;

  const _SnakeRoutePainter({
    required this.columns,
    required this.rows,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (columns <= 0 || rows <= 0 || total <= 1) return;

    final route = Path();

    for (int number = 1; number <= total; number++) {
      final row = (number - 1) ~/ columns;
      final positionInRow = (number - 1) % columns;

      final column = row.isEven
          ? positionInRow
          : columns - 1 - positionInRow;

      final point = Offset(
        size.width * (column + 0.5) / columns,
        size.height * (row + 0.5) / rows,
      );

      if (number == 1) {
        route.moveTo(point.dx, point.dy);
      } else {
        route.lineTo(point.dx, point.dy);
      }
    }

    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(route, glowPaint);
    canvas.drawPath(route, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SnakeRoutePainter oldDelegate) {
    return oldDelegate.columns != columns ||
        oldDelegate.rows != rows ||
        oldDelegate.total != total;
  }
}