import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/passenger_check_service.dart';
import '../../services/passenger_storage_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../bus/bus_seat_selection_screen.dart';
import '../flight/flight_seat_selection_screen.dart';
import '../train/train_seat_selection_screen.dart';
import '../sports/sports_seat_selection_screen.dart';
import 'transport_payment_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final TransportBooking booking;

  const PassengerDetailsScreen({super.key, required this.booking});

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  late List<PassengerFormData> _passengers;
  List<Passenger> _savedPassengers = [];
  bool _isLoading = true;
  int _maxPassengers = 1;

  @override
  void initState() {
    super.initState();
    _maxPassengers = widget.booking.passengers.isNotEmpty
        ? widget.booking.passengers.length
        : 1;
    _passengers = List.generate(_maxPassengers, (_) => PassengerFormData());
    _loadSavedPassengers();
  }

  Future<void> _loadSavedPassengers() async {
    final saved = await PassengerStorageService.getSavedPassengers();
    if (mounted) {
      setState(() {
        _savedPassengers = saved;
        _isLoading = false;
      });
    }
  }

  bool _isValidCNIC(String cnic) {
    final cleaned = cnic.replaceAll('-', '');
    if (cleaned.length != 13) return false;
    return int.tryParse(cleaned) != null;
  }

  String _formatCNIC(String input) {
    final cleaned = input.replaceAll('-', '');
    if (cleaned.length <= 5) return cleaned;
    if (cleaned.length <= 12) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    }
    return '${cleaned.substring(0, 5)}-${cleaned.substring(5, 12)}-${cleaned.substring(12)}';
  }

  bool _isValidPassport(String passport) {
    if (passport.isEmpty) return true;
    return RegExp(r'^[A-Z]{2}[0-9]{7}$').hasMatch(passport.toUpperCase());
  }

  String? _findDuplicateCNIC() {
    final cnics = <String>[];
    for (var p in _passengers) {
      final cnic = p.idNumber.text.replaceAll('-', '');
      if (cnic.isEmpty) continue;
      if (cnics.contains(cnic)) return cnic;
      cnics.add(cnic);
    }
    return null;
  }

  Future<void> _savePersonToStorage(int index) async {
    final p = _passengers[index];

    if (p.fullName.text.isEmpty || p.idNumber.text.isEmpty) {
      CustomSnackbar.showError(context, 'Fill Name and CNIC before saving');
      return;
    }

    if (!_isValidCNIC(p.idNumber.text)) {
      CustomSnackbar.showError(context, 'Invalid CNIC format');
      return;
    }

    if (p.gender == null) {
      CustomSnackbar.showError(context, 'Select gender before saving');
      return;
    }

    final passenger = Passenger(
      fullName: p.fullName.text,
      idNumber: p.idNumber.text,
      gender: p.gender ?? 'Male',
      age: int.tryParse(p.age.text) ?? 0,
      nationality: p.nationality.text,
      email: p.email.text,
      phone: p.phone.text,
    );

    await PassengerStorageService.savePassenger(passenger);
    await _loadSavedPassengers();

    if (!mounted) return;
    CustomSnackbar.showSuccess(context, '${p.fullName.text} saved!');
  }

  Future<void> _showSavedPersons(int formIndex) async {
    if (_savedPassengers.isEmpty) {
      CustomSnackbar.showError(context, 'No saved persons yet');
      return;
    }

    final usedCNICs = <String>[];
    for (var i = 0; i < _passengers.length; i++) {
      if (i == formIndex) continue;
      final cnic = _passengers[i].idNumber.text.replaceAll('-', '');
      if (cnic.isNotEmpty) usedCNICs.add(cnic);
    }

    final selected = await showModalBottomSheet<Passenger>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SavedPersonsSheet(
        passengers: _savedPassengers,
        usedCNICs: usedCNICs,
        onDelete: (p) async {
          await PassengerStorageService.deletePassenger(p.fullName, p.phone);
          await _loadSavedPassengers();
        },
      ),
    );

    if (selected != null) {
      final cleanedCNIC = selected.idNumber.replaceAll('-', '');
      for (var i = 0; i < _passengers.length; i++) {
        if (i == formIndex) continue;
        if (_passengers[i].idNumber.text.replaceAll('-', '') == cleanedCNIC) {
          if (!mounted) return;
          CustomSnackbar.showError(context, 'This person is already added');
          return;
        }
      }

      setState(() {
        _passengers[formIndex].fullName.text = selected.fullName;
        _passengers[formIndex].idNumber.text = selected.idNumber;
        _passengers[formIndex].gender = selected.gender;
        _passengers[formIndex].age.text = selected.age.toString();
        _passengers[formIndex].nationality.text = selected.nationality;
        _passengers[formIndex].email.text = selected.email;
        _passengers[formIndex].phone.text = selected.phone;
      });
      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'Person loaded!');
    }
  }

  Future<void> _proceedNext() async {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    final phoneRegex = RegExp(r'^(\+92|0)?3[0-9]{9}$');
    final isFlightBooking = widget.booking.transportType == 'flight';

    for (var i = 0; i < _passengers.length; i++) {
      final p = _passengers[i];

      if (p.fullName.text.isEmpty) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Enter name');
        return;
      }

      if (p.idNumber.text.isEmpty) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Enter CNIC');
        return;
      }

      if (!_isValidCNIC(p.idNumber.text)) {
        CustomSnackbar.showError(
            context, 'Person ${i + 1}: Invalid CNIC format');
        return;
      }

      if (isFlightBooking) {
        if (p.passport.text.isEmpty) {
          CustomSnackbar.showError(
              context, 'Person ${i + 1}: Passport required for flights');
          return;
        }
        if (!_isValidPassport(p.passport.text)) {
          CustomSnackbar.showError(
              context, 'Person ${i + 1}: Invalid passport (AB1234567)');
          return;
        }
      }

      if (p.gender == null) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Select gender');
        return;
      }

      if (p.email.text.isEmpty) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Enter email');
        return;
      }

      if (!emailRegex.hasMatch(p.email.text)) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Invalid email');
        return;
      }

      if (p.phone.text.isEmpty) {
        CustomSnackbar.showError(context, 'Person ${i + 1}: Enter phone');
        return;
      }

      if (!phoneRegex.hasMatch(p.phone.text.replaceAll(' ', ''))) {
        CustomSnackbar.showError(
            context, 'Person ${i + 1}: Invalid phone (03XXXXXXXXX)');
        return;
      }
    }

    final duplicate = _findDuplicateCNIC();
    if (duplicate != null) {
      CustomSnackbar.showError(
          context, 'Duplicate CNIC! Each person must have unique CNIC');
      return;
    }

    final passengers = _passengers
        .map((p) => Passenger(
              fullName: p.fullName.text,
              idNumber: p.idNumber.text,
              gender: p.gender ?? 'Male',
              age: int.tryParse(p.age.text) ?? 0,
              nationality: p.nationality.text,
              email: p.email.text,
              phone: p.phone.text,
            ))
        .toList();

    // Check already booked for all transport types
    if (widget.booking.transportType == 'bus' ||
        widget.booking.transportType == 'flight' ||
        widget.booking.transportType == 'train' ||
        widget.booking.transportType == 'sports' ||
        widget.booking.transportType == 'event') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final alreadyBooked = await PassengerCheckService.checkAlreadyBooked(
        operatorNumber: widget.booking.operatorNumber,
        departureDate: widget.booking.departureDate,
        departureTime: widget.booking.departureTime,
        passengers: passengers,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (alreadyBooked.isNotEmpty) {
        _showAlreadyBookedDialog(alreadyBooked);
        return;
      }
    }

    final updated = widget.booking.copyWith(passengers: passengers);

    if (!mounted) return;

    // Navigate based on transport type
    if (widget.booking.transportType == 'bus') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BusSeatSelectionScreen(booking: updated),
        ),
      );
    } else if (widget.booking.transportType == 'flight') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlightSeatSelectionScreen(booking: updated),
        ),
      );
    } else if (widget.booking.transportType == 'train') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrainSeatSelectionScreen(booking: updated),
        ),
      );
    } else if (widget.booking.transportType == 'sports') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SportsSeatSelectionScreen(
            match: {},
            category: {
              'name': updated.classType ?? 'General',
              'color': '2D5A3D',
              'code': 'GEN',
            },
            ticketCount: updated.passengers.length,
            totalPrice: updated.totalAmount,
            booking: updated,
          ),
        ),
      );
    } else if (widget.booking.transportType == 'event') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SportsSeatSelectionScreen(
        match: {},
        category: {
          'name': updated.classType ?? 'General',
          'color': '6B8E7B',
          'code': 'GA',
        },
        ticketCount: updated.passengers.length,
        totalPrice: updated.totalAmount,
        booking: updated,
      ),
    ),
  );
}
    
     else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TransportPaymentScreen(booking: updated)),
      );
    }
  }

  void _showAlreadyBookedDialog(List<String> names) {
    final type = widget.booking.transportType;
    final typeName = type == 'flight'
        ? 'flight'
        : type == 'train'
            ? 'train'
            : type == 'sports'
                ? 'match'
                : 'bus';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text('Already Booked!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following person(s) already booked on this $typeName:',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            ...names.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Text(
              'One person can only book ONE ticket per $typeName. Please change or remove.',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK, Change Person',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFlightBooking = widget.booking.transportType == 'flight';
final isSportsBooking = widget.booking.transportType == 'sports' || 
                         widget.booking.transportType == 'event';

    // Icon based on type
    IconData typeIcon;
    switch (widget.booking.transportType) {
      case 'bus':
        typeIcon = Icons.directions_bus;
        break;
      case 'flight':
        typeIcon = Icons.flight;
        break;
      case 'train':
        typeIcon = Icons.train;
        break;
      case 'sports':
        typeIcon = Icons.stadium;
        break;
      case 'event':
  typeIcon = Icons.celebration;
  break;
      default:
        typeIcon = Icons.confirmation_number;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'TicketHub',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journey Card
                    // Journey Card
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(typeIcon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.operatorName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text(widget.booking.operatorNumber,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          if (widget.booking.classType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.booking.classType!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
        ],
      ),
      // Sports/Event layout
      if (isSportsBooking || widget.booking.transportType == 'event') ...[
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.textGrey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${widget.booking.fromLocation}, ${widget.booking.toLocation}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: AppColors.textGrey),
            const SizedBox(width: 4),
            Text(
              '${widget.booking.departureDate} • ${widget.booking.departureTime}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ] else ...[
        // Bus/Train/Flight layout
        const SizedBox(height: 14),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.departureTime,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                Text(widget.booking.fromLocation,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textGrey),
                  Text(widget.booking.duration ?? '',
                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.booking.arrivalTime ?? '',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                Text(widget.booking.toLocation,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
      const Divider(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Fare per person', style: TextStyle(fontSize: 12)),
          Text(
            'PKR ${widget.booking.pricePerPassenger.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC49B63)),
          ),
        ],
      ),
    ],
  ),
),
const SizedBox(height: 20),

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Person Details',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_maxPassengers Person${_maxPassengers > 1 ? "s" : ""}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFlightBooking
                          ? 'Enter details for each person.\nCNIC: XXXXX-XXXXXXX-X | Passport: AB1234567'
                          : 'Enter details for each person.\nCNIC format: XXXXX-XXXXXXX-X',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 16),

                    // Person forms
                    ..._passengers.asMap().entries.map((entry) {
                      return _buildPersonForm(
                          entry.key, entry.value, isFlightBooking);
                    }),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _proceedNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Go to Seat Selection',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonForm(
      int index, PassengerFormData data, bool isFlightBooking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Person ${index + 1}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showSavedPersons(index),
                icon: const Icon(Icons.person_search,
                    size: 16, color: AppColors.primary),
                label: const Text('Load Saved Person',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Full Name', 'As shown on CNIC', data.fullName),
          _cnicField(data),
          if (isFlightBooking) _passportField(data),
          _dropdown('Gender', data),
          _field('Age', 'Years', data.age, isNumber: true),
          _field('Nationality', 'Country', data.nationality),
          const SizedBox(height: 8),
          const Text('Contact Information',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _field('Email Address', 'For your e-ticket', data.email),
          _field('Phone Number', '03XXXXXXXXX', data.phone, isNumber: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _savePersonToStorage(index),
              icon: const Icon(Icons.save_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text('Save This Person For Later',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cnicField(PassengerFormData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CNIC Number',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          TextField(
            controller: data.idNumber,
            keyboardType: TextInputType.number,
            maxLength: 15,
            onChanged: (value) {
              final formatted = _formatCNIC(value);
              if (formatted != value) {
                data.idNumber.value = TextEditingValue(
                  text: formatted,
                  selection:
                      TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
            decoration: InputDecoration(
              hintText: '12345-1234567-1',
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.badge_outlined,
                  color: AppColors.primary, size: 20),
            ),
          ),
          if (data.idNumber.text.isNotEmpty &&
              !_isValidCNIC(data.idNumber.text))
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text('CNIC must be 13 digits',
                  style: TextStyle(fontSize: 11, color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _passportField(PassengerFormData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Passport Number',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              SizedBox(width: 4),
              Text('(Required for flights)',
                  style: TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: data.passport,
            textCapitalization: TextCapitalization.characters,
            maxLength: 9,
            onChanged: (value) {
              final upper = value.toUpperCase();
              if (upper != value) {
                data.passport.value = TextEditingValue(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
            },
            decoration: InputDecoration(
              hintText: 'AB1234567',
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.airplane_ticket,
                  color: AppColors.primary, size: 20),
            ),
          ),
          if (data.passport.text.isNotEmpty &&
              !_isValidPassport(data.passport.text))
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text('Format: 2 letters + 7 digits (AB1234567)',
                  style: TextStyle(fontSize: 11, color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType:
                isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, PassengerFormData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: data.gender,
              hint: const Text('Select Gender'),
              isExpanded: true,
              underline: const SizedBox(),
              items: ['Male', 'Female', 'Other']
                  .map((g) =>
                      DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => data.gender = val),
            ),
          ),
        ],
      ),
    );
  }
}

class PassengerFormData {
  final fullName = TextEditingController();
  final idNumber = TextEditingController();
  final passport = TextEditingController();
  String? gender;
  final age = TextEditingController();
  final nationality = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
}

// ==========================
// SAVED PERSONS BOTTOM SHEET
// ==========================
class _SavedPersonsSheet extends StatefulWidget {
  final List<Passenger> passengers;
  final List<String> usedCNICs;
  final Function(Passenger) onDelete;

  const _SavedPersonsSheet({
    required this.passengers,
    required this.usedCNICs,
    required this.onDelete,
  });

  @override
  State<_SavedPersonsSheet> createState() => _SavedPersonsSheetState();
}

class _SavedPersonsSheetState extends State<_SavedPersonsSheet> {
  late List<Passenger> _passengers;

  @override
  void initState() {
    super.initState();
    _passengers = List.from(widget.passengers);
  }

  bool _isAlreadyUsed(Passenger p) {
    final cleanCNIC = p.idNumber.replaceAll('-', '');
    return widget.usedCNICs.contains(cleanCNIC);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.people, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Saved Persons',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _passengers.isEmpty
                ? const Center(
                    child: Text('No saved persons',
                        style: TextStyle(color: AppColors.textGrey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _passengers.length,
                    itemBuilder: (context, index) {
                      final p = _passengers[index];
                      final isUsed = _isAlreadyUsed(p);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isUsed
                              ? Colors.grey.shade100
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: isUsed
                              ? Border.all(color: Colors.grey.shade400)
                              : null,
                        ),
                        child: ListTile(
                          enabled: !isUsed,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: p.gender == 'Female'
                                  ? const Color(0xFFEC407A).withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              p.gender == 'Female'
                                  ? Icons.female
                                  : Icons.male,
                              color: p.gender == 'Female'
                                  ? const Color(0xFFEC407A)
                                  : AppColors.primary,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isUsed ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                              if (isUsed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('ALREADY ADDED',
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CNIC: ${p.idNumber}',
                                  style: const TextStyle(fontSize: 11)),
                              Text(p.email,
                                  style: const TextStyle(fontSize: 11)),
                              Text('${p.gender} • Age ${p.age}',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () async {
                              widget.onDelete(p);
                              setState(
                                  () => _passengers.removeAt(index));
                            },
                          ),
                          onTap: isUsed
                              ? null
                              : () => Navigator.pop(context, p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}