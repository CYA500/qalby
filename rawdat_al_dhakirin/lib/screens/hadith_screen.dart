// lib/screens/hadith_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../services/storage_service.dart';
import '../widgets/widgets.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({Key? key}) : super(key: key);

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  HadithCategory? _selectedCategory;
  int _dailyHadithIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyHadith();
  }

  Future<void> _loadDailyHadith() async {
    final storage = StorageService();
    await storage.init();
    setState(() {
      _dailyHadithIndex = storage.getDailyHadithIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory != null) {
      return _HadithListView(
        category: _selectedCategory!,
        onBack: () => setState(() => _selectedCategory = null),
      );
    }

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // حديث اليوم
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArabicText(
                        text: 'حديث اليوم',
                        size: 20,
                        weight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _DailyHadithCard(
                        hadith: _getDailyHadith(),
                      ),
                      const SizedBox(height: 24),
                      ArabicText(
                        text: 'التصنيفات',
                        size: 20,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
              // شبكة الفئات
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = AppData.hadithCategories[index];
                      return _CategoryCard(
                        category: category,
                        onTap: () => setState(() => _selectedCategory = category),
                      );
                    },
                    childCount: AppData.hadithCategories.length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      ),
    );
  }

  HadithModel _getDailyHadith() {
    // اختيار حديث عشوائي بناءً على اليوم
    final allHadiths = AppData.hadithCategories
        .expand((c) => c.hadiths)
        .toList();
    return allHadiths[_dailyHadithIndex % allHadiths.length];
  }
}

class _DailyHadithCard extends StatelessWidget {
  final HadithModel hadith;

  const _DailyHadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return IslamicCard(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Column(
        children: [
          ArabicText(
            text: hadith.text,
            size: 16,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          ArabicText(
            text: 'رواه ${hadith.source}',
            size: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final HadithCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IslamicCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconData(category.iconName),
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          ArabicText(
            text: category.name,
            size: 16,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ArabicText(
              text: '${category.hadiths.length} حديث',
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'mosque': return Icons.mosque;
      case 'prayer': return Icons.accessibility_new;
      case 'tasbih': return Icons.fingerprint;
      case 'heart': return Icons.favorite;
      case 'sun': return Icons.wb_sunny;
      case 'hands': return Icons.back_hand;
      case 'star': return Icons.star;
      default: return Icons.book;
    }
  }
}

class _HadithListView extends StatefulWidget {
  final HadithCategory category;
  final VoidCallback onBack;

  const _HadithListView({
    required this.category,
    required this.onBack,
  });

  @override
  State<_HadithListView> createState() => _HadithListViewState();
}

class _HadithListViewState extends State<_HadithListView> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: ArabicText(
          text: widget.category.name,
          size: 20,
          weight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.category.hadiths.length,
          itemBuilder: (context, index) {
            final hadith = widget.category.hadiths[index];
            final isExpanded = _expandedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IslamicCard(
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ArabicText(
                            text: hadith.text,
                            size: 16,
                            weight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 24),
                      ArabicText(
                        text: 'الراوي: ${hadith.narrator}',
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      ArabicText(
                        text: 'المصدر: ${hadith.source}',
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: ArabicText(
                          text: hadith.explanation,
                          size: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
