// lib/screens/tasbeeh_screen.dart
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../services/storage_service.dart';
import '../widgets/widgets.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({Key? key}) : super(key: key);

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late StorageService _storage;

  int _sessionCount = 0;
  int _dailyCount = 0;
  int _grandTotal = 0;
  int _currentDhikrIndex = 0;
  int _target = 33;

  final List<int> _targets = [33, 100, 500];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = StorageService();
    await _storage.init();
    final counters = _storage.getCounters();
    setState(() {
      _sessionCount = counters['session']!;
      _dailyCount = counters['daily']!;
      _grandTotal = counters['grand']!;
      _currentDhikrIndex = counters['dhikrIndex']!;
      // تعيين الهدف الافتراضي للذكر الحالي
      _target = AppData.dhikrList[_currentDhikrIndex].defaultTarget;
    });
  }

  Future<void> _increment() async {
    // اهتزاز خفيف
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 30);
    }

    setState(() {
      _sessionCount++;
      _dailyCount++;
      _grandTotal++;
    });

    _pulseController.forward().then((_) => _pulseController.reverse());

    await _storage.saveCounters(
      session: _sessionCount,
      daily: _dailyCount,
      grand: _grandTotal,
      dhikrIndex: _currentDhikrIndex,
    );

    if (_sessionCount == _target) {
      _showCompletionToast();
    }
  }

  void _showCompletionToast() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 60,
            ),
            const SizedBox(height: 16),
            ArabicText(
              text: 'أحسنت! أكملت ${_target} تسبيحة',
              size: 20,
              weight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            ArabicText(
              text: AppData.dhikrList[_currentDhikrIndex].fadl,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSession();
            },
            child: const ArabicText(
              text: 'استمرار',
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSession() async {
    setState(() {
      _sessionCount = 0;
    });
    await _storage.resetSession();
  }

  void _changeDhikr(bool next) {
    setState(() {
      if (next) {
        _currentDhikrIndex = (_currentDhikrIndex + 1) % AppData.dhikrList.length;
      } else {
        _currentDhikrIndex = (_currentDhikrIndex - 1 + AppData.dhikrList.length) 
                            % AppData.dhikrList.length;
      }
      _sessionCount = 0;
      _target = AppData.dhikrList[_currentDhikrIndex].defaultTarget;
    });
    _storage.saveCounters(
      session: 0,
      daily: _dailyCount,
      grand: _grandTotal,
      dhikrIndex: _currentDhikrIndex,
    );
  }

  void _setTarget(int target) {
    setState(() {
      _target = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = AppData.dhikrList[_currentDhikrIndex];
    final progress = _sessionCount / _target;

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // العدادات العلوية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CounterBadge(
                      label: 'الجلسة',
                      value: _sessionCount,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _CounterBadge(
                      label: 'اليوم',
                      value: _dailyCount,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    _CounterBadge(
                      label: 'الإجمالي',
                      value: _grandTotal,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // الذكر الحالي
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeDhikr(false),
                    ),
                    Expanded(
                      child: IslamicCard(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Column(
                          children: [
                            QuranText(
                              text: dhikr.text,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            ArabicText(
                              text: '(${_currentDhikrIndex + 1}/${AppData.dhikrList.length})',
                              size: 12,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeDhikr(true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // فضل الذكر
                IslamicCard(
                  child: ArabicText(
                    text: dhikr.fadl,
                    size: 14,
                    color: Colors.grey[600],
                    align: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // أزرار الأهداف
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _targets.map((t) {
                    final isSelected = _target == t;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        label: ArabicText(
                          text: '$t',
                          size: 14,
                          color: isSelected ? Colors.white : null,
                        ),
                        selected: isSelected,
                        onSelected: (_) => _setTarget(t),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // الزر الدائري
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _increment,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1 + (_pulseController.value * 0.1),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme.primary
                                        .withOpacity(0.3 + (_pulseController.value * 0.2)),
                                    blurRadius: 20 + (_pulseController.value * 10),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // حلقة التقدم
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ArabicText(
                                        text: '$_sessionCount',
                                        size: 48,
                                        weight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      ArabicText(
                                        text: '/ $_target',
                                        size: 16,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // زر إعادة التعيين
                TextButton.icon(
                  onPressed: _resetSession,
                  icon: const Icon(Icons.refresh),
                  label: const ArabicText(text: 'إعادة تعيين الجلسة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}

class _CounterBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CounterBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ArabicText(
            text: label,
            size: 12,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
