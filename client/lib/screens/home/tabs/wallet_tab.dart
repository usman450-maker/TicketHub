import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/booking_service.dart';
import '../../../services/transport_service.dart';
import '../../../services/park_service.dart';
import '../../../services/storage_service.dart';
import '../../notifications/notifications_screen.dart';
import '../../../services/refund_service.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  String _userName = 'Guest';
  String? _profileImagePath;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await StorageService.getUser();
    final imagePath = await StorageService.getProfileImage();

    if (mounted && user != null) {
      setState(() {
        _userName =
            user['name']?.toString().split(' ').first ?? 'Guest';
        _profileImagePath = imagePath;
      });
    }

    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> all = [];

    // ✅ Movie bookings
    try {
      final res = await BookingService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          all.add({
            'type': 'movie',
            'title': b['movie_title']?.toString() ?? 'Movie',
            'subtitle':
                '${b['venue_name'] ?? ''} • ${b['show_date'] ?? ''}',
            'amount': double.tryParse(
                    b['total_amount']?.toString() ?? '0') ??
                0,
            'date': b['created_at']?.toString() ?? '',
            'status': 'completed',
            'order_number': b['order_number']?.toString() ?? '',
            'image': b['movie_poster']?.toString() ?? '',
            'icon': Icons.movie,
          });
        }
      }
    } catch (e) {}

    // ✅ Transport / Sports / Events
    try {
      final res = await TransportService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          final type =
              b['transport_type']?.toString().toLowerCase() ?? '';
          IconData icon = Icons.confirmation_number;
          switch (type) {
            case 'bus':
              icon = Icons.directions_bus;
              break;
            case 'train':
              icon = Icons.train;
              break;
            case 'flight':
              icon = Icons.flight;
              break;
            case 'sports':
              icon = Icons.sports_soccer;
              break;
            case 'event':
              icon = Icons.event;
              break;
          }
          all.add({
            'type': type,
            'title': b['operator_name']?.toString() ?? 'Booking',
            'subtitle':
                '${b['from_location'] ?? ''} → ${b['to_location'] ?? ''}',
            'amount': double.tryParse(
                    b['total_amount']?.toString() ?? '0') ??
                0,
            'date': b['created_at']?.toString() ?? '',
            'status': 'completed',
            'order_number': b['order_number']?.toString() ?? '',
            'icon': icon,
          });
        }
      }
    } catch (e) {}

    // ✅ Park bookings
    try {
      final res = await ParkService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          all.add({
            'type': 'park',
            'title': b['park_name']?.toString() ?? 'Park',
            'subtitle':
                '${b['park_city'] ?? ''} • ${b['visit_date'] ?? ''}',
            'amount': double.tryParse(
                    b['total_amount']?.toString() ?? '0') ??
                0,
            'date': b['created_at']?.toString() ?? '',
            'status': 'completed',
            'order_number': b['order_number']?.toString() ?? '',
            'image': b['park_image']?.toString() ?? '',
            'icon': Icons.park,
          });
        }
      }
    } catch (e) {}

    // Sort by date
    all.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date']?.toString() ?? '') ??
              DateTime(2000);
      final dateB =
          DateTime.tryParse(b['date']?.toString() ?? '') ??
              DateTime(2000);
      return dateB.compareTo(dateA);
    });

    if (mounted) {
      setState(() {
        _transactions = all;
        _isLoading = false;
      });
    }
  }

  // ✅ Calculate total spending
  double get _totalSpent {
    return _transactions.fold(
        0, (sum, t) => sum + (t['amount'] as double? ?? 0));
  }

  double get _thisMonthSpent {
    final now = DateTime.now();
    return _transactions.where((t) {
      final date = DateTime.tryParse(t['date']?.toString() ?? '');
      return date != null &&
          date.year == now.year &&
          date.month == now.month;
    }).fold(0, (sum, t) => sum + (t['amount'] as double? ?? 0));
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _transactions;
    return _transactions
        .where((t) =>
            (t['type']?.toString().toLowerCase() ?? '') ==
            _selectedFilter.toLowerCase())
        .toList();
  }

  // ✅ Static Vouchers (till backend ready)
  final List<Map<String, dynamic>> _vouchers = [
    {
      'code': 'WELCOME20',
      'title': '20% OFF',
      'description':
          'Valid on your first booking. Save up to PKR 500.',
      'color': const Color(0xFFC49B63),
      'expiry': 'Dec 31, 2025',
    },
    {
      'code': 'MOVIE100',
      'title': 'PKR 100 OFF',
      'description': 'On movie tickets. Weekend special.',
      'color': AppColors.primary,
      'expiry': 'Nov 30, 2025',
    },
    {
      'code': 'FLIGHT500',
      'title': 'PKR 500 OFF',
      'description': 'On international flight bookings.',
      'color': const Color(0xFF3B82F6),
      'expiry': 'Jan 15, 2026',
    },
    {
      'code': 'EARLYBIRD15',
      'title': '15% OFF',
      'description': 'Valid on theater performances this weekend.',
      'color': const Color(0xFFEC407A),
      'expiry': 'Oct 20, 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header - Avatar + TicketHub + Notification
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImagePath != null &&
                                File(_profileImagePath!).existsSync()
                            ? Image.file(
                                File(_profileImagePath!),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person,
                                color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TicketHub',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const NotificationsScreen()),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Total Spent Card (Big)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F3A2E),
                        Color(0xFF6B8E7B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Watermark icon
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white.withOpacity(0.15),
                          size: 100,
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Spending',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PKR ${_totalSpent.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.trending_up,
                                  color: Color(0xFFC49B63),
                                  size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'PKR ${_thisMonthSpent.toStringAsFixed(0)} this month',
                                style: const TextStyle(
                                  color: Color(0xFFC49B63),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Quick Actions
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _actionButton(
                                icon: Icons.credit_card,
                                label: 'Cards',
                                onTap: _showPaymentMethods,
                              ),
                              _actionButton(
                                icon: Icons.receipt_long,
                                label: 'History',
                                onTap: _showAllTransactions,
                              ),
                              _actionButton(
                                icon: Icons.card_giftcard,
                                label: 'Coupons',
                                onTap: _showCoupons,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Active Vouchers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Vouchers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showCoupons,
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    return _voucherCard(_vouchers[index]);
                  },
                ),
              ),
                          const SizedBox(height: 24),

              // ✅ Refunds Section - YAHAN ADD KARO
              FutureBuilder<Map<String, dynamic>>(
                future: RefundService.getMyRefunds(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final refunds =
                      snapshot.data!['refunds'] as List? ?? [];
                  if (refunds.isEmpty) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.replay_circle_filled,
                                  color: AppColors.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${refunds.length} Active Refund${refunds.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...refunds.take(3).map((r) => Container(
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.05),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order #${r['order_number'] ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'PKR ${(double.tryParse(r['refund_amount']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _refundStatusColor(
                                                r['status']
                                                        ?.toString() ??
                                                    '')
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        (r['status'] ?? '')
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: _refundStatusColor(
                                              r['status']
                                                      ?.toString() ??
                                                  ''),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

             

              // ✅ Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list,
                              color: AppColors.textDark, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _selectedFilter,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Transactions List
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                )
              else if (_filteredTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 60,
                            color:
                                AppColors.primary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your bookings will appear here',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _filteredTransactions
                        .take(5)
                        .map((t) => _transactionCard(t))
                        .toList(),
                  ),
                ),

              if (_filteredTransactions.length > 5)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: GestureDetector(
                      onTap: _showAllTransactions,
                      child: const Text(
                        'View All Transactions',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Action Button
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Voucher Card
  Widget _voucherCard(Map<String, dynamic> voucher) {
    final color = voucher['color'] as Color;
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                voucher['code'] ?? '',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.local_offer_outlined,
                  color: color.withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            voucher['title'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              voucher['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
                height: 1.3,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Terms',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _applyCoupon(voucher),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Transaction Card
  Widget _transactionCard(Map<String, dynamic> t) {
    final amount = t['amount'] as double? ?? 0;
    final status = t['status']?.toString() ?? 'completed';
    final icon = t['icon'] as IconData? ?? Icons.confirmation_number;

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'refunded':
        statusColor = const Color(0xFFEC407A);
        break;
      default:
        statusColor = AppColors.textGrey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(t['date']?.toString() ?? ''),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-PKR ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Format Date
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  // ✅ Refund Status Color
Color _refundStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const Color(0xFFF59E0B);
    case 'approved':
      return const Color(0xFF3B82F6);
    case 'completed':
      return const Color(0xFF10B981);
    case 'rejected':
      return const Color(0xFFEF4444);
    default:
      return AppColors.textGrey;
  }
}

  // ✅ Filter Dialog
  void _showFilterDialog() {
    final filters = [
      'All',
      'Movie',
      'Bus',
      'Train',
      'Flight',
      'Sports',
      'Event',
      'Park'
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map((f) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = f);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedFilter == f
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedFilter == f
                                  ? AppColors.primary
                                  : AppColors.borderGrey,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: _selectedFilter == f
                                  ? Colors.white
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Apply Coupon
  void _applyCoupon(Map<String, dynamic> voucher) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${voucher['code']} coupon copied! Use it during booking.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // ✅ Show all coupons
  void _showCoupons() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _CouponsScreen(vouchers: _vouchers)),
    );
  }

  // ✅ Show all transactions
  void _showAllTransactions() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              _TransactionsScreen(transactions: _transactions)),
    );
  }

  // ✅ Show payment methods
  void _showPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PaymentMethodsScreen()),
    );
  }
}

// ================================
// ✅ COUPONS FULL SCREEN
// ================================
class _CouponsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> vouchers;

  const _CouponsScreen({required this.vouchers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back,
              color: AppColors.primary),
        ),
        title: const Text(
          'My Coupons',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final v = vouchers[index];
          final color = v['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      v['code'] ?? '',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  v['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  v['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Valid till: ${v['expiry']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${v['code']} copied!'),
                            backgroundColor: color,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================================
// ✅ TRANSACTIONS FULL SCREEN
// ================================
class _TransactionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const _TransactionsScreen({required this.transactions});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back,
              color: AppColors.primary),
        ),
        title: const Text(
          'All Transactions',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text('No transactions yet',
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                final icon =
                    t['icon'] as IconData? ?? Icons.confirmation_number;
                final amount = t['amount'] as double? ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon,
                            color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['title'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t['subtitle'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(
                                  t['date']?.toString() ?? ''),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-PKR ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ================================
// ✅ PAYMENT METHODS SCREEN
// ================================
class _PaymentMethodsScreen extends StatelessWidget {
  const _PaymentMethodsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back,
              color: AppColors.primary),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Stripe Card
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF1F3A2E),  // ✅ App primary dark
        Color(0xFF6B8E7B),  // ✅ App primary light
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC49B63), // ✅ Gold accent
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'STRIPE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.check_circle,
              color: Color(0xFFC49B63), size: 20),
        ],
      ),
      const SizedBox(height: 30),
      const Text(
        'Secure Payments',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'All payments processed by Stripe',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          _cardBrand('VISA'),
          const SizedBox(width: 8),
          _cardBrand('MC'),
          const SizedBox(width: 8),
          _cardBrand('AMEX'),
          const SizedBox(width: 8),
          _cardBrand('DISC'),
        ],
      ),
    ],
  ),
),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primary.withOpacity(0.7),
                      size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Card details are securely managed by Stripe. Your cards are never stored on our servers.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Features
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _featureItem(Icons.lock_outline, '256-bit SSL Encryption',
                'Bank-level security'),
            _featureItem(Icons.verified_user,
                'PCI DSS Compliant', 'Highest payment security standard'),
            _featureItem(Icons.flash_on, 'Instant Payments',
                'Fast and reliable transactions'),
            _featureItem(Icons.support_agent, '24/7 Support',
                'Get help anytime you need'),
          ],
        ),
      ),
    );
  }

  Widget _cardBrand(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}