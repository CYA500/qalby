// lib/screens/adhkar_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../widgets/widgets.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({Key? key}) : super(key: key);

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, int> _counters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _incrementCounter(int index) {
    setState(() {
      _counters[index] = (_counters[index] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // عنوان
              Padding(
                padding: const EdgeInsets.all(16),
                child: ArabicText(
                  text: 'الأذكار اليومية',
                  size: 24,
                  weight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // علامات التبويب
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'الصباح'),
                    Tab(text: 'المساء'),
                    Tab(text: 'النوم'),
                  ],
                  labelStyle: const TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // محتوى التبويبات
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AdhkarList(
                      type: AdhkarType.morning,
                      counters: _counters,
                      onIncrement: _incrementCounter,
                    ),
                    _AdhkarList(
                      type: AdhkarType.evening,
                      counters: _counters,
                      onIncrement: _incrementCounter,
                    ),
                    _AdhkarList(
                      type: AdhkarType.sleep,
                      counters: _counters,
                      onIncrement: _incrementCounter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AdhkarList extends StatelessWidget {
  final AdhkarType type;
  final Map<int, int> counters;
  final Function(int) onIncrement;

  const _AdhkarList({
    required this.type,
    required this.counters,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final adhkarList = AppData.adhkarData[type] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: adhkarList.length,
      itemBuilder: (context, index) {
        final adhkar = adhkarList[index];
        final currentCount = counters[index] ?? 0;
        final isCompleted = currentCount >= adhkar.repeat;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IslamicCard(
            color: isCompleted 
              ? Colors.green.withOpacity(0.1)
              : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // النص
                ArabicText(
                  text: adhkar.text,
                  size: 18,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                // معلومات إضافية
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ArabicText(
                        text: 'التكرار: ${adhkar.repeat}',
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ArabicText(
                        text: adhkar.source,
                        size: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // الفضل
                ArabicText(
                  text: adhkar.virtue,
                  size: 13,
                  color: Colors.grey[600],
                ),
                const Divider(height: 24),
                // عداد التكرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$currentCount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' / ${adhkar.repeat}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: isCompleted ? null : () => onIncrement(index),
                      icon: const Icon(Icons.add),
                      label: const ArabicText(
                        text: 'تسبيح',
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey : Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
