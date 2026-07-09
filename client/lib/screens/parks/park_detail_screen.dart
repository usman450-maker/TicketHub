import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/park_booking.dart';
import '../../services/park_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import '../../widgets/custom_snackbar.dart';

class ParkDetailScreen extends StatefulWidget {
  final Map<String, dynamic> park;

  const ParkDetailScreen({super.key, required this.park});

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen> {
  int _adultQty = 1;
  int _childQty = 0;
  int _seniorQty = 0;
  DateTime _visitDate = DateTime.now().add(const Duration(days: 1));
  bool _isProcessing = false;

  // Person details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();

  late List<ParkAddon> _addons;

  double get _adultPrice =>
      double.tryParse(widget.park['adult_price']?.toString() ?? '0') ?? 0;
  double get _childPrice =>
      double.tryParse(widget.park['child_price']?.toString() ?? '0') ?? 0;
  double get _seniorPrice =>
      double.tryParse(widget.park['senior_price']?.toString() ?? '0') ?? 0;

  double get _basePrice =>
      (_adultQty * _adultPrice) +
      (_childQty * _childPrice) +
      (_seniorQty * _seniorPrice);

  double get _addonTotal =>
      _addons.fold(0.0, (sum, a) => sum + (a.selected ? a.price : 0));

  double get _tax => (_basePrice + _addonTotal) * 0.05;
  double get _total => _basePrice + _addonTotal + _tax;

  int get _totalPersons => _adultQty + _childQty + _seniorQty;

  @override
  void initState() {
    super.initState();
    _addons = [
      ParkAddon(name: 'Fast Pass', price: 500, icon: IconType.fastPass),
      ParkAddon(name: 'Locker', price: 200, icon: IconType.locker),
      ParkAddon(name: 'Meal Voucher', price: 800, icon: IconType.food),
      ParkAddon(name: 'VIP Entry', price: 1500, icon: IconType.vip),
      ParkAddon(name: 'Parking', price: 300, icon: IconType.parking),
    ];
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await StorageService.getUser();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

IconData _getAddonIcon(IconType type) {
  switch (type) {
    case IconType.fastPass:
      return Icons.flash_on;
    case IconType.locker:
      return Icons.lock;
    case IconType.food:
      return Icons.restaurant;
    case IconType.vip:
      return Icons.star;
    case IconType.parking:
      return Icons.local_parking;
    case IconType.star:
      return Icons.star_border;
  }
}

  Future<void> _handleBooking() async {
    if (_totalPersons == 0) {
      CustomSnackbar.showError(context, 'Select at least 1 ticket');
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Fill all person details');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Create payment intent
      final intentRes = await ParkService.createPaymentIntent(_total);

      if (intentRes['success'] != true) {
        throw Exception(intentRes['message'] ?? 'Payment failed');
      }

      final clientSecret = intentRes['clientSecret'];
      final paymentIntentId = intentRes['paymentIntentId'];

      // Show Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TicketHub',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Confirm booking
      final bookingData = {
        'parkId': widget.park['id'],
        'parkName': widget.park['name'],
        'parkCity': widget.park['city'],
        'parkImage': widget.park['poster'],
        'visitDate': _formatDate(_visitDate),
        'adultQty': _adultQty,
        'childQty': _childQty,
        'seniorQty': _seniorQty,
        'addons': _addons
            .where((a) => a.selected)
            .map((a) => a.toJson())
            .toList(),
        'basePrice': _basePrice,
        'addonPrice': _addonTotal,
        'tax': _tax,
        'totalAmount': _total,
        'personDetails': {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'cnic': _cnicController.text,
        },
      };

      final confirmRes = await ParkService.confirmBooking(
          bookingData, paymentIntentId);

      if (!mounted) return;

      if (confirmRes['success'] == true) {
        final orderNumber =
            confirmRes['booking']?['order_number'] ?? 'TH-PRK-000000';

        CustomSnackbar.showSuccess(context, 'Booking confirmed!');

        // Navigate to confirmed screen
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => _ParkConfirmedScreen(
      park: widget.park,
      orderNumber: orderNumber,
      visitDate: _formatDate(_visitDate),
      adultQty: _adultQty,
      childQty: _childQty,
      seniorQty: _seniorQty,
      total: _total,
      personName: _nameController.text,
      personEmail: _emailController.text,
      personPhone: _phoneController.text,
      personCnic: _cnicController.text,
    ),
  ),
);
      } else {
        throw Exception(
            confirmRes['message'] ?? 'Booking failed');
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
          context, e.error.localizedMessage ?? 'Payment cancelled');
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.park;
    final activities = p['activities'] as List? ?? [];
    final facilities = p['facilities'] as List? ?? [];
    final rating =
        double.tryParse(p['rating']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  p['poster']?.toString() ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: AppColors.primary, size: 20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(p['name']?.toString() ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: const Color(0xFFC49B63),
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text('$rating (${p['reviews'] ?? ''})',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.location_on,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(p['city']?.toString() ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                      '${p['opening_time'] ?? ''} - ${p['closing_time'] ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          const Text('About',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(p['description']?.toString() ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                  height: 1.6)),
                          const SizedBox(height: 20),

                          // Activities
                          if (activities.isNotEmpty) ...[
                            const Text('Activities',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: activities
                                  .map<Widget>((a) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.attractions,
                                                size: 14,
                                                color:
                                                    AppColors.primary),
                                            const SizedBox(width: 6),
                                            Text(a.toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                    color: AppColors
                                                        .primary)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Facilities
                          if (facilities.isNotEmpty) ...[
                            const Text('Facilities',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: facilities
                                  .map<Widget>((f) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.check_circle,
                                                size: 12,
                                                color:
                                                    AppColors.success),
                                            const SizedBox(width: 4),
                                            Text(f.toString(),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Visit Date
                          const Text('Visit Date',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderGrey),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: AppColors.primary,
                                      size: 20),
                                  const SizedBox(width: 10),
                                  Text(_formatDate(_visitDate),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.bold)),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down,
                                      color: AppColors.textGrey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tickets
                          const Text('Book Tickets',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildTicketRow('Adult', _adultPrice,
                              _adultQty, (v) => setState(() => _adultQty = v)),
                          _buildTicketRow('Child', _childPrice,
                              _childQty, (v) => setState(() => _childQty = v)),
                          _buildTicketRow('Senior', _seniorPrice,
                              _seniorQty, (v) => setState(() => _seniorQty = v)),
                          const SizedBox(height: 20),

                          // Add-ons
                          const Text('Optional Add-ons',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...List.generate(_addons.length, (i) {
                            final addon = _addons[i];
                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: addon.selected
                                    ? AppColors.primary
                                        .withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                  color: addon.selected
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                      _getAddonIcon(addon.icon),
                                      color: AppColors.primary,
                                      size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(addon.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                  Text(
                                      'PKR ${addon.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.bold,
                                          color:
                                              AppColors.primary)),
                                  const SizedBox(width: 10),
                                  Switch(
                                    value: addon.selected,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: (v) => setState(
                                        () => addon.selected = v),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),

                          // Person Details
                          const Text('Person Details',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildField('Full Name', _nameController),
                          _buildField('Email', _emailController),
                          _buildField('Phone (03XXXXXXXXX)',
                              _phoneController,
                              isNumber: true),
                          _buildField(
                              'CNIC (Optional)', _cnicController,
                              isNumber: true),
                          const SizedBox(height: 20),

                          // Summary
                          if (_totalPersons > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderGrey),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Booking Summary',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  if (_adultQty > 0)
                                    _summaryRow(
                                        'Adult x $_adultQty',
                                        'PKR ${(_adultQty * _adultPrice).toStringAsFixed(0)}'),
                                  if (_childQty > 0)
                                    _summaryRow(
                                        'Child x $_childQty',
                                        'PKR ${(_childQty * _childPrice).toStringAsFixed(0)}'),
                                  if (_seniorQty > 0)
                                    _summaryRow(
                                        'Senior x $_seniorQty',
                                        'PKR ${(_seniorQty * _seniorPrice).toStringAsFixed(0)}'),
                                  if (_addonTotal > 0)
                                    _summaryRow('Add-ons',
                                        'PKR ${_addonTotal.toStringAsFixed(0)}'),
                                  _summaryRow('Tax (5%)',
                                      'PKR ${_tax.toStringAsFixed(0)}'),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      const Text('TOTAL',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.bold)),
                                      Text(
                                          'PKR ${_total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: AppColors
                                                  .primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            if (_totalPersons > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: AppColors.borderGrey)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(
                            'Book Now - PKR ${_total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(
      String label, double price, int qty, Function(int) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text('PKR ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (qty > 0) onChanged(qty - 1);
            },
            icon: const Icon(Icons.remove_circle_outline,
                color: AppColors.primary),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$qty',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ),
          IconButton(
            onPressed: () {
              if (qty < 20) onChanged(qty + 1);
            },
            icon: const Icon(Icons.add_circle,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textGrey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================
// PARK CONFIRMED SCREEN
// ==========================
class _ParkConfirmedScreen extends StatefulWidget {
  final Map<String, dynamic> park;
  final String orderNumber;
  final String visitDate;
  final int adultQty;
  final int childQty;
  final int seniorQty;
  final double total;
  final String personName;
  final String personEmail;
  final String personPhone;
  final String personCnic;

  const _ParkConfirmedScreen({
    required this.park,
    required this.orderNumber,
    required this.visitDate,
    required this.adultQty,
    required this.childQty,
    required this.seniorQty,
    required this.total,
    required this.personName,
    required this.personEmail,
    required this.personPhone,
    required this.personCnic,
  });

  @override
  State<_ParkConfirmedScreen> createState() => _ParkConfirmedScreenState();
}

class _ParkConfirmedScreenState extends State<_ParkConfirmedScreen> {
  bool _isSaving = false;

  Future<void> _saveTicket() async {
    setState(() => _isSaving = true);

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (mounted) CustomSnackbar.showError(context, 'Gallery permission required');
          setState(() => _isSaving = false);
          return;
        }
      }

      final controller = ScreenshotController();

      final Uint8List imageBytes = await controller.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 550),
            devicePixelRatio: 2.0,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.white,
              child: _ParkTicketWidget(
                parkName: widget.park['name']?.toString() ?? '',
                parkCity: widget.park['city']?.toString() ?? '',
                orderNumber: widget.orderNumber,
                visitDate: widget.visitDate,
                adultQty: widget.adultQty,
                childQty: widget.childQty,
                seniorQty: widget.seniorQty,
                total: widget.total,
                personName: widget.personName,
                personEmail: widget.personEmail,
                personPhone: widget.personPhone,
                personCnic: widget.personCnic,
              ),
            ),
          ),
        ),
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 500),
      );

      if (imageBytes == null) {
        if (mounted) CustomSnackbar.showError(context, 'Failed to generate ticket');
        setState(() => _isSaving = false);
        return;
      }

      await Gal.putImageBytes(
        imageBytes,
        album: 'TicketHub',
        name: 'TicketHub_${widget.orderNumber}',
      );

      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'Ticket saved to Gallery!');
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F16),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.check_circle,
                  color: Color(0xFFC49B63), size: 60),
              const SizedBox(height: 12),
              const Text('Booking Confirmed!',
                  style: TextStyle(
                      color: Color(0xFFC49B63),
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Confirmation sent to your inbox.',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 24),

              // Venue Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.network(
                      widget.park['poster']?.toString() ?? '',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                          height: 150, color: AppColors.primaryLight),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.park['name']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.park['city']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ticket Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.park,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('PARK PASS',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('CONFIRMATION',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.bold)),
                    Text(widget.orderNumber,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    _info('Park', widget.park['name']?.toString() ?? ''),
                    _info('City', widget.park['city']?.toString() ?? ''),
                    _info('Visit Date', widget.visitDate),
                    if (widget.adultQty > 0) _info('Adults', '${widget.adultQty}'),
                    if (widget.childQty > 0) _info('Children', '${widget.childQty}'),
                    if (widget.seniorQty > 0) _info('Seniors', '${widget.seniorQty}'),
                    _info('Booked By', widget.personName),
                    _info('Email', widget.personEmail),
                    _info('Phone', widget.personPhone),
                    if (widget.personCnic.isNotEmpty)
                      _info('CNIC', widget.personCnic),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL PAID',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        Text('PKR ${widget.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: widget.orderNumber,
                          version: QrVersions.auto,
                          size: 110,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text('SCAN AT ENTRANCE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Ticket Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTicket,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Ticket to Gallery',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF152A20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.home, (route) => false),
                child: const Text('Return to Dashboard',
                    style: TextStyle(
                        color: Color(0xFFC49B63),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey)),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ParkTicketWidget extends StatelessWidget {
  final String parkName;
  final String parkCity;
  final String orderNumber;
  final String visitDate;
  final int adultQty;
  final int childQty;
  final int seniorQty;
  final double total;
  final String personName;
  final String personEmail;
  final String personPhone;
  final String personCnic;

  const _ParkTicketWidget({
    required this.parkName,
    required this.parkCity,
    required this.orderNumber,
    required this.visitDate,
    required this.adultQty,
    required this.childQty,
    required this.seniorQty,
    required this.total,
    required this.personName,
    required this.personEmail,
    required this.personPhone,
    required this.personCnic,
  });

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(Icons.park,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TICKETHUB',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('PARK PASS',
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.5),
                  ),
                  child: QrImageView(
                    data: orderNumber,
                    version: QrVersions.auto,
                    size: 80,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Issue Info
            Row(
              children: [
                Expanded(child: _field('Serial No.', orderNumber)),
                const SizedBox(width: 4),
                Expanded(child: _field('Issue Date', _getCurrentDate())),
                const SizedBox(width: 4),
                Expanded(child: _field('Issue Time', _getCurrentTime())),
              ],
            ),
            const SizedBox(height: 6),

            // Park Info
            _field('Park', parkName, isFull: true),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(child: _field('City', parkCity)),
                const SizedBox(width: 4),
                Expanded(child: _field('Visit Date', visitDate)),
              ],
            ),
            const SizedBox(height: 6),

            // Tickets
            Row(
              children: [
                if (adultQty > 0) Expanded(child: _field('Adults', '$adultQty')),
                if (childQty > 0) ...[
                  const SizedBox(width: 4),
                  Expanded(child: _field('Children', '$childQty')),
                ],
                if (seniorQty > 0) ...[
                  const SizedBox(width: 4),
                  Expanded(child: _field('Seniors', '$seniorQty')),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Person Details
            _field('Person Name', personName, isFull: true),
            const SizedBox(height: 6),
            _field('Email', personEmail, isFull: true),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(child: _field('Phone', personPhone)),
                if (personCnic.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Expanded(child: _field('CNIC', personCnic)),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Total
            Row(
              children: [
                Expanded(child: _field('Total (PKR)', total.toStringAsFixed(0))),
                const SizedBox(width: 4),
                Expanded(child: _field('Status', 'PAID')),
              ],
            ),
            const SizedBox(height: 8),

            // Footer
            const Divider(color: Colors.black26, height: 6),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Powered by TicketHub',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text('www.tickethub.com.pk',
                        style: TextStyle(fontSize: 7, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('CONFIRMED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, {bool isFull = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          width: double.infinity,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          width: double.infinity,
          child: Text(value,
              style: TextStyle(
                  fontSize: isFull ? 10 : 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}