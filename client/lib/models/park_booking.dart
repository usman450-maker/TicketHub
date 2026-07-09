class ParkBooking {
  final int? parkId;
  final String parkName;
  final String parkCity;
  final String parkImage;
  final String visitDate;
  final int adultQty;
  final int childQty;
  final int seniorQty;
  final double adultPrice;
  final double childPrice;
  final double seniorPrice;
  final List<ParkAddon> addons;
  final String personName;
  final String personEmail;
  final String personPhone;
  final String personCnic;

  ParkBooking({
    this.parkId,
    required this.parkName,
    required this.parkCity,
    required this.parkImage,
    required this.visitDate,
    this.adultQty = 0,
    this.childQty = 0,
    this.seniorQty = 0,
    this.adultPrice = 0,
    this.childPrice = 0,
    this.seniorPrice = 0,
    this.addons = const [],
    this.personName = '',
    this.personEmail = '',
    this.personPhone = '',
    this.personCnic = '',
  });

  int get totalPersons => adultQty + childQty + seniorQty;

  double get basePrice =>
      (adultQty * adultPrice) +
      (childQty * childPrice) +
      (seniorQty * seniorPrice);

  double get addonTotal =>
      addons.fold(0.0, (sum, a) => sum + (a.selected ? a.price : 0));

  double get tax => (basePrice + addonTotal) * 0.05;

  double get totalAmount => basePrice + addonTotal + tax;

  Map<String, dynamic> toJson() {
    return {
      'parkId': parkId,
      'parkName': parkName,
      'parkCity': parkCity,
      'parkImage': parkImage,
      'visitDate': visitDate,
      'adultQty': adultQty,
      'childQty': childQty,
      'seniorQty': seniorQty,
      'addons':
          addons.where((a) => a.selected).map((a) => a.toJson()).toList(),
      'basePrice': basePrice,
      'addonPrice': addonTotal,
      'tax': tax,
      'totalAmount': totalAmount,
      'personDetails': {
        'name': personName,
        'email': personEmail,
        'phone': personPhone,
        'cnic': personCnic,
      },
    };
  }
}

class ParkAddon {
  final String name;
  final double price;
  final IconType icon;
  bool selected;

  ParkAddon({
    required this.name,
    required this.price,
    this.icon = IconType.star,
    this.selected = false,
  });

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

enum IconType { fastPass, locker, food, vip, parking, star }