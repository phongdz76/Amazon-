import 'package:amazon_clone/features/admin/models/sales.dart';
import 'package:flutter/material.dart';

class CategoryProductsChart extends StatelessWidget {
  final List<Sales> salesData;
  const CategoryProductsChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    // Tính toán revenue cho từng category
    Map<String, double> categoryRevenues = _calculateCategoryRevenues();
    
    // Tính tổng doanh thu
    double totalEarnings = categoryRevenues.values.fold(0, (sum, earning) => sum + earning);

    // Sắp xếp categories theo revenue giảm dần
    List<MapEntry<String, double>> sortedCategories = categoryRevenues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue by Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Total Revenue: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${_formatCurrency(totalEarnings)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sortedCategories.length} Categories',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Table
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Table Header với animation
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category_outlined, 
                           size: 18, 
                           color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF374151),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Icon(Icons.monetization_on_outlined, 
                           size: 18, 
                           color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Revenue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF374151),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Icon(Icons.pie_chart_outline, 
                           size: 18, 
                           color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Share',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF374151),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Enhanced Table Rows
                ...sortedCategories.asMap().entries.map((entry) {
                  int index = entry.key;
                  String category = entry.value.key;
                  double revenue = entry.value.value;
                  double percentage = totalEarnings > 0 ? (revenue / totalEarnings) * 100 : 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(category).withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Có thể thêm action khi tap vào category
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Enhanced Category Icon with rank
                              Stack(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getCategoryColor(category),
                                          _getCategoryColor(category).withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getCategoryColor(category).withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(category),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 16),

                              // Category Name with product count
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_getProductCount(category)} products',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Enhanced Revenue
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      '\$${_formatCurrency(revenue)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _getCategoryColor(category),
                                        letterSpacing: -0.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'revenue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              // Enhanced Percentage with improved progress bar
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: percentage / 100,
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  _getCategoryColor(category),
                                                  _getCategoryColor(category).withOpacity(0.7),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getCategoryColor(category).withOpacity(0.4),
                                                  spreadRadius: 0,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Summary footer
                if (sortedCategories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.indigo.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Top Category',
                          sortedCategories.first.key,
                          Icons.trending_up,
                          Colors.green.shade600,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        _buildSummaryItem(
                          'Categories',
                          '${sortedCategories.length}',
                          Icons.category,
                          Colors.blue.shade600,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        _buildSummaryItem(
                          'Avg Revenue',
                          '\$${_formatCurrency(totalEarnings / sortedCategories.length)}',
                          Icons.analytics,
                          Colors.purple.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Map<String, double> _calculateCategoryRevenues() {
    Map<String, double> categoryRevenues = {};
    
    for (Sales sale in salesData) {
      String category = sale.label;
      double earning = sale.earning.toDouble();
      
      if (categoryRevenues.containsKey(category)) {
        categoryRevenues[category] = categoryRevenues[category]! + earning;
      } else {
        categoryRevenues[category] = earning;
      }
    }
    
    return categoryRevenues;
  }

  int _getProductCount(String category) {
    return salesData.where((sale) => sale.label == category).length;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mobiles':
        return const Color(0xFF3B82F6); // Blue
      case 'essentials':
        return const Color(0xFF10B981); // Emerald
      case 'books':
        return const Color(0xFF8B5CF6); // Violet
      case 'appliances':
        return const Color(0xFFF59E0B); // Amber
      case 'fashion':
        return const Color(0xFFEF4444); // Red
      case 'electronics':
        return const Color(0xFF06B6D4); // Cyan
      case 'home & garden':
        return const Color(0xFF84CC16); // Lime
      case 'sports':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mobiles':
        return Icons.smartphone;
      case 'essentials':
        return Icons.local_grocery_store;
      case 'books':
        return Icons.menu_book;
      case 'appliances':
        return Icons.kitchen;
      case 'fashion':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'home & garden':
        return Icons.home;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }
}