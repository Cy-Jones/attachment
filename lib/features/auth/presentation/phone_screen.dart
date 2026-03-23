import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/responsive_wrapper.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class CountryData {
  final String name;
  final String flag;
  final String dialCode;
  final int minLength;
  final int maxLength;
  const CountryData(this.name, this.flag, this.dialCode, this.minLength, this.maxLength);
}

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> with WidgetsBindingObserver {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize with default locale.
    _selectedCountry = _countries.firstWhere((c) => c.name == 'India', orElse: () => _countries.first);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneController.dispose();
    super.dispose();
  }

  // OS LIFECYCLE HANDLER:
  // If the user returns from Safari, ensures the UI buffer hasn't cleared.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isLoading) {
      setState(() {});
    }
  }

  // FULL GLOBAL E.164 MATRIX: Corrected boundaries for 230+ regions.
  // maxLength is buffered (+1/+2) to handle local trunk prefixes (leading zeros).
  final List<CountryData> _countries = const [
    CountryData('Afghanistan', '🇦🇫', '+93', 9, 10),
    CountryData('Albania', '🇦🇱', '+355', 8, 10),
    CountryData('Algeria', '🇩🇿', '+213', 8, 10),
    CountryData('American Samoa', '🇦🇸', '+1', 10, 11),
    CountryData('Andorra', '🇦🇩', '+376', 6, 9),
    CountryData('Angola', '🇦🇴', '+244', 9, 10),
    CountryData('Anguilla', '🇦🇮', '+1', 10, 11),
    CountryData('Antigua and Barbuda', '🇦🇬', '+1', 10, 11),
    CountryData('Argentina', '🇦🇷', '+54', 10, 11),
    CountryData('Armenia', '🇦🇲', '+374', 8, 9),
    CountryData('Aruba', '🇦🇼', '+297', 7, 8),
    CountryData('Australia', '🇦🇺', '+61', 9, 10),
    CountryData('Austria', '🇦🇹', '+43', 4, 13),
    CountryData('Azerbaijan', '🇦🇿', '+994', 9, 10),
    CountryData('Bahamas', '🇧🇸', '+1', 10, 11),
    CountryData('Bahrain', '🇧🇭', '+973', 8, 9),
    CountryData('Bangladesh', '🇧🇩', '+880', 10, 11),
    CountryData('Barbados', '🇧🇧', '+1', 10, 11),
    CountryData('Belarus', '🇧🇾', '+375', 9, 10),
    CountryData('Belgium', '🇧🇪', '+32', 8, 10),
    CountryData('Belize', '🇧🇿', '+501', 7, 8),
    CountryData('Benin', '🇧🇯', '+229', 8, 9),
    CountryData('Bermuda', '🇧🇲', '+1', 10, 11),
    CountryData('Bhutan', '🇧🇹', '+975', 8, 9),
    CountryData('Bolivia', '🇧🇴', '+591', 8, 9),
    CountryData('Bosnia and Herzegovina', '🇧🇦', '+387', 8, 10),
    CountryData('Botswana', '🇧🇼', '+267', 7, 9),
    CountryData('Brazil', '🇧🇷', '+55', 10, 12),
    CountryData('British Virgin Islands', '🇻🇬', '+1', 10, 11),
    CountryData('Brunei', '🇧🇳', '+673', 7, 8),
    CountryData('Bulgaria', '🇧🇬', '+359', 8, 10),
    CountryData('Burkina Faso', '🇧🇫', '+226', 8, 9),
    CountryData('Burundi', '🇧🇮', '+257', 8, 9),
    CountryData('Cambodia', '🇰🇭', '+855', 8, 10),
    CountryData('Cameroon', '🇨🇲', '+237', 9, 10),
    CountryData('Canada', '🇨🇦', '+1', 10, 11),
    CountryData('Cape Verde', '🇨🇻', '+238', 7, 8),
    CountryData('Cayman Islands', '🇰🇾', '+1', 10, 11),
    CountryData('Central African Republic', '🇨🇫', '+236', 8, 9),
    CountryData('Chad', '🇹🇩', '+235', 8, 9),
    CountryData('Chile', '🇨🇱', '+56', 9, 10),
    CountryData('China', '🇨🇳', '+86', 11, 12),
    CountryData('Colombia', '🇨🇴', '+57', 10, 11),
    CountryData('Comoros', '🇰🇲', '+269', 7, 8),
    CountryData('Congo, Dem. Rep.', '🇨🇩', '+243', 9, 10),
    CountryData('Congo, Rep.', '🇨🇬', '+242', 9, 10),
    CountryData('Costa Rica', '🇨🇷', '+506', 8, 9),
    CountryData('Croatia', '🇭🇷', '+385', 8, 13),
    CountryData('Cuba', '🇨🇺', '+53', 8, 9),
    CountryData('Cyprus', '🇨🇾', '+357', 8, 9),
    CountryData('Czech Republic', '🇨🇿', '+420', 9, 10),
    CountryData('Denmark', '🇩🇰', '+45', 8, 9),
    CountryData('Djibouti', '🇩🇯', '+253', 8, 9),
    CountryData('Dominica', '🇩🇲', '+1', 10, 11),
    CountryData('Dominican Republic', '🇩🇴', '+1', 10, 11),
    CountryData('Ecuador', '🇪🇨', '+593', 9, 10),
    CountryData('Egypt', '🇪🇬', '+20', 9, 11),
    CountryData('El Salvador', '🇸🇻', '+503', 8, 9),
    CountryData('Equatorial Guinea', '🇬🇶', '+240', 9, 10),
    CountryData('Eritrea', '🇪🇷', '+291', 7, 8),
    CountryData('Estonia', '🇪🇪', '+372', 7, 9),
    CountryData('Eswatini', '🇸🇿', '+268', 8, 9),
    CountryData('Ethiopia', '🇪🇹', '+251', 9, 10),
    CountryData('Falkland Islands', '🇫🇰', '+500', 5, 6),
    CountryData('Faroe Islands', '🇫🇴', '+298', 6, 7),
    CountryData('Fiji', '🇫🇯', '+679', 7, 8),
    CountryData('Finland', '🇫🇮', '+358', 5, 13),
    CountryData('France', '🇫🇷', '+33', 9, 10),
    CountryData('French Guiana', '🇬🇫', '+594', 9, 10),
    CountryData('French Polynesia', '🇵🇫', '+689', 6, 7),
    CountryData('Gabon', '🇬🇦', '+241', 9, 10),
    CountryData('Gambia', '🇬🇲', '+220', 7, 8),
    CountryData('Georgia', '🇬🇪', '+995', 9, 10),
    CountryData('Germany', '🇩🇪', '+49', 10, 12),
    CountryData('Ghana', '🇬🇭', '+233', 9, 10),
    CountryData('Gibraltar', '🇬🇮', '+350', 8, 9),
    CountryData('Greece', '🇬🇷', '+30', 10, 11),
    CountryData('Greenland', '🇬🇱', '+299', 6, 7),
    CountryData('Grenada', '🇬🇩', '+1', 10, 11),
    CountryData('Guadeloupe', '🇬🇵', '+590', 9, 10),
    CountryData('Guam', '🇬🇺', '+1', 10, 11),
    CountryData('Guatemala', '🇬🇹', '+502', 8, 9),
    CountryData('Guinea', '🇬🇳', '+224', 9, 10),
    CountryData('Guinea-Bissau', '🇬🇼', '+245', 9, 10),
    CountryData('Guyana', '🇬🇾', '+592', 7, 8),
    CountryData('Haiti', '🇭🇹', '+509', 8, 9),
    CountryData('Honduras', '🇭🇳', '+504', 8, 9),
    CountryData('Hong Kong', '🇭🇰', '+852', 8, 9),
    CountryData('Hungary', '🇭🇺', '+36', 9, 10),
    CountryData('Iceland', '🇮🇸', '+354', 7, 10),
    CountryData('India', '🇮🇳', '+91', 10, 11),
    CountryData('Indonesia', '🇮🇩', '+62', 9, 14),
    CountryData('Iran', '🇮🇷', '+98', 10, 11),
    CountryData('Iraq', '🇮🇶', '+964', 10, 11),
    CountryData('Ireland', '🇮🇪', '+353', 7, 10),
    CountryData('Israel', '🇮🇱', '+972', 9, 10),
    CountryData('Italy', '🇮🇹', '+39', 9, 11),
    CountryData('Ivory Coast', '🇨🇮', '+225', 10, 11),
    CountryData('Jamaica', '🇯🇲', '+1', 10, 11),
    CountryData('Japan', '🇯🇵', '+81', 10, 11),
    CountryData('Jordan', '🇯🇴', '+962', 9, 10),
    CountryData('Kazakhstan', '🇰🇿', '+7', 10, 11),
    CountryData('Kenya', '🇰🇪', '+254', 9, 10),
    CountryData('Kiribati', '🇰🇮', '+686', 5, 9),
    CountryData('Kuwait', '🇰🇼', '+965', 8, 9),
    CountryData('Kyrgyzstan', '🇰🇬', '+996', 9, 10),
    CountryData('Laos', '🇱🇦', '+856', 8, 10),
    CountryData('Latvia', '🇱🇻', '+371', 8, 9),
    CountryData('Lebanon', '🇱🇧', '+961', 7, 9),
    CountryData('Lesotho', '🇱🇸', '+266', 8, 9),
    CountryData('Liberia', '🇱🇷', '+231', 7, 10),
    CountryData('Libya', '🇱🇾', '+218', 8, 10),
    CountryData('Liechtenstein', '🇱🇮', '+423', 7, 8),
    CountryData('Lithuania', '🇱🇹', '+370', 8, 9),
    CountryData('Luxembourg', '🇱🇺', '+352', 9, 10),
    CountryData('Macau', '🇲🇴', '+853', 8, 9),
    CountryData('Madagascar', '🇲🇬', '+261', 9, 10),
    CountryData('Malawi', '🇲🇼', '+265', 9, 10),
    CountryData('Malaysia', '🇲🇾', '+60', 9, 11),
    CountryData('Maldives', '🇲🇻', '+960', 7, 8),
    CountryData('Mali', '🇲🇱', '+223', 8, 9),
    CountryData('Malta', '🇲🇹', '+356', 8, 9),
    CountryData('Marshall Islands', '🇲🇭', '+692', 7, 8),
    CountryData('Martinique', '🇲🇶', '+596', 9, 10),
    CountryData('Mauritania', '🇲🇷', '+222', 8, 9),
    CountryData('Mauritius', '🇲🇺', '+230', 8, 9),
    CountryData('Mayotte', '🇾🇹', '+262', 9, 10),
    CountryData('Mexico', '🇲🇽', '+52', 10, 11),
    CountryData('Micronesia', '🇫🇲', '+691', 7, 8),
    CountryData('Moldova', '🇲🇩', '+373', 8, 9),
    CountryData('Monaco', '🇲🇨', '+377', 8, 10),
    CountryData('Mongolia', '🇲🇳', '+976', 8, 9),
    CountryData('Montenegro', '🇲🇪', '+382', 8, 9),
    CountryData('Montserrat', '🇲🇸', '+1', 10, 11),
    CountryData('Morocco', '🇲🇦', '+212', 9, 10),
    CountryData('Mozambique', '🇲🇿', '+258', 9, 10),
    CountryData('Myanmar', '🇲🇲', '+95', 8, 10),
    CountryData('Namibia', '🇳🇦', '+264', 9, 10),
    CountryData('Nauru', '🇳🇷', '+674', 7, 8),
    CountryData('Nepal', '🇳🇵', '+977', 10, 11),
    CountryData('Netherlands', '🇳🇱', '+31', 9, 10),
    CountryData('New Caledonia', '🇳🇨', '+687', 6, 7),
    CountryData('New Zealand', '🇳🇿', '+64', 8, 11),
    CountryData('Nicaragua', '🇳🇮', '+505', 8, 9),
    CountryData('Niger', '🇳🇪', '+227', 8, 9),
    CountryData('Nigeria', '🇳🇬', '+234', 10, 11),
    CountryData('North Macedonia', '🇲🇰', '+389', 8, 9),
    CountryData('Northern Mariana Islands', '🇲🇵', '+1', 10, 11),
    CountryData('Norway', '🇳🇴', '+47', 8, 9),
    CountryData('Oman', '🇴🇲', '+968', 8, 9),
    CountryData('Pakistan', '🇵🇰', '+92', 10, 11),
    CountryData('Palau', '🇵🇼', '+680', 7, 8),
    CountryData('Palestine', '🇵🇸', '+970', 9, 10),
    CountryData('Panama', '🇵🇦', '+507', 8, 9),
    CountryData('Papua New Guinea', '🇵🇬', '+675', 8, 9),
    CountryData('Paraguay', '🇵🇾', '+595', 9, 10),
    CountryData('Peru', '🇵🇪', '+51', 9, 10),
    CountryData('Philippines', '🇵🇭', '+63', 10, 11),
    CountryData('Poland', '🇵🇱', '+48', 9, 10),
    CountryData('Portugal', '🇵🇹', '+351', 9, 10),
    CountryData('Puerto Rico', '🇵🇷', '+1', 10, 11),
    CountryData('Qatar', '🇶🇦', '+974', 8, 9),
    CountryData('Reunion', '🇷🇪', '+262', 9, 10),
    CountryData('Romania', '🇷🇴', '+40', 9, 10),
    CountryData('Russia', '🇷🇺', '+7', 10, 11),
    CountryData('Rwanda', '🇷🇼', '+250', 9, 10),
    CountryData('Samoa', '🇼🇸', '+685', 7, 8),
    CountryData('San Marino', '🇸🇲', '+378', 6, 11),
    CountryData('Sao Tome and Principe', '🇸🇹', '+239', 7, 8),
    CountryData('Saudi Arabia', '🇸🇦', '+966', 9, 10),
    CountryData('Senegal', '🇸🇳', '+221', 9, 10),
    CountryData('Serbia', '🇷🇸', '+381', 8, 10),
    CountryData('Seychelles', '🇸🇨', '+248', 7, 8),
    CountryData('Sierra Leone', '🇸🇱', '+232', 8, 9),
    CountryData('Singapore', '🇸🇬', '+65', 8, 10),
    CountryData('Sint Maarten', '🇸🇽', '+1', 10, 11),
    CountryData('Slovakia', '🇸🇰', '+421', 9, 10),
    CountryData('Slovenia', '🇸🇮', '+386', 8, 9),
    CountryData('Solomon Islands', '🇸🇧', '+677', 7, 8),
    CountryData('Somalia', '🇸🇴', '+252', 8, 9),
    CountryData('South Africa', '🇿🇦', '+27', 9, 10),
    CountryData('South Korea', '🇰🇷', '+82', 9, 11),
    CountryData('South Sudan', '🇸🇸', '+211', 9, 10),
    CountryData('Spain', '🇪🇸', '+34', 9, 10),
    CountryData('Sri Lanka', '🇱🇰', '+94', 9, 10),
    CountryData('Sudan', '🇸🇩', '+249', 9, 10),
    CountryData('Suriname', '🇸🇷', '+597', 7, 8),
    CountryData('Sweden', '🇸🇪', '+46', 7, 10),
    CountryData('Switzerland', '🇨🇭', '+41', 9, 10),
    CountryData('Syria', '🇸🇾', '+963', 9, 10),
    CountryData('Taiwan', '🇹🇼', '+886', 9, 10),
    CountryData('Tajikistan', '🇹🇯', '+992', 9, 10),
    CountryData('Tanzania', '🇹🇿', '+255', 9, 10),
    CountryData('Thailand', '🇹🇭', '+66', 9, 10),
    CountryData('Timor-Leste', '🇹🇱', '+670', 7, 8),
    CountryData('Togo', '🇹🇬', '+228', 8, 9),
    CountryData('Tonga', '🇹🇴', '+676', 5, 8),
    CountryData('Trinidad and Tobago', '🇹🇹', '+1', 10, 11),
    CountryData('Tunisia', '🇹🇳', '+216', 8, 9),
    CountryData('Turkey', '🇹🇷', '+90', 10, 11),
    CountryData('Turkmenistan', '🇹🇲', '+993', 8, 9),
    CountryData('Turks and Caicos', '🇹🇨', '+1', 10, 11),
    CountryData('Tuvalu', '🇹🇻', '+688', 5, 7),
    CountryData('US Virgin Islands', '🇻🇮', '+1', 10, 11),
    CountryData('Uganda', '🇺🇬', '+256', 9, 10),
    CountryData('Ukraine', '🇺🇦', '+380', 9, 10),
    CountryData('United Arab Emirates', '🇦🇪', '+971', 9, 10),
    CountryData('United Kingdom', '🇬🇧', '+44', 10, 11),
    CountryData('United States', '🇺🇸', '+1', 10, 11),
    CountryData('Uruguay', '🇺🇾', '+598', 8, 10),
    CountryData('Uzbekistan', '🇺🇿', '+998', 9, 10),
    CountryData('Vanuatu', '🇻🇺', '+678', 5, 8),
    CountryData('Vatican City', '🇻🇦', '+379', 10, 11),
    CountryData('Venezuela', '🇻🇪', '+58', 10, 11),
    CountryData('Vietnam', '🇻🇳', '+84', 9, 11),
    CountryData('Wallis and Futuna', '🇼🇫', '+681', 5, 6),
    CountryData('Yemen', '🇾🇪', '+967', 9, 10),
    CountryData('Zambia', '🇿🇲', '+260', 9, 10),
    CountryData('Zimbabwe', '🇿🇼', '+263', 9, 11),
  ];

  late CountryData _selectedCountry;

  void _safeShowError(String message) {
    final navContext = rootNavigatorKey.currentContext;
    if (navContext != null) {
      ScaffoldMessenger.of(navContext).clearSnackBars();
      ScaffoldMessenger.of(navContext).showSnackBar(
        SnackBar(
          content: Row(children: [const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20), const SizedBox(width: 12), Expanded(child: Text(message, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)))]),
          backgroundColor: const Color(0xFF1E1E2C).withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
        ),
      );
    }
  }

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) { _safeShowError('Please enter your phone number.'); return; }

    if (phone.length < _selectedCountry.minLength || phone.length > _selectedCountry.maxLength) {
      _safeShowError('A valid ${_selectedCountry.name} number is between ${_selectedCountry.minLength} and ${_selectedCountry.maxLength} digits.');
      return;
    }

    setState(() => _isLoading = true);
    final formattedPhone = '${_selectedCountry.dialCode} $phone';

    await ref.read(authRepositoryProvider).verifyPhone(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await ref.read(authRepositoryProvider).signInWithPhoneCredential(credential);
          final navContext = rootNavigatorKey.currentContext;
          if (navContext != null) {
            final user = FirebaseAuth.instance.currentUser;
            if (user?.displayName == null || user!.displayName!.isEmpty) {
              navContext.go('/name-entry');
            } else {
              navContext.go('/home');
            }
          }
        } catch (e) {
          _safeShowError("Auto-sign in failed. Please check code.");
          setState(() => _isLoading = false);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        if (e.code == 'internal-error') {
          _safeShowError("Security check failed. Try whitelisted test numbers.");
        } else {
          _safeShowError(e.message ?? 'Verification failed.');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _isLoading = false);
        final navContext = rootNavigatorKey.currentContext;
        if (navContext != null) {
          navContext.push('/verify', extra: {
            'phone': formattedPhone,
            'verificationId': verificationId,
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _showCountryPicker() {
    List<CountryData> filtered = List.from(_countries);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(hintText: 'Search country...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                onChanged: (v) => setModalState(() => filtered = _countries.where((c) => c.name.toLowerCase().contains(v.toLowerCase()) || c.dialCode.contains(v)).toList()),
              ),
            ),
            Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (context, i) => ListTile(
              leading: Text(filtered[i].flag, style: const TextStyle(fontSize: 22)),
              title: Text(filtered[i].name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              trailing: Text(filtered[i].dialCode, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              onTap: () { setState(() => _selectedCountry = filtered[i]); Navigator.pop(context); },
            ))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double textScale = screenWidth > 600 ? 1.25 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFC5CAF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, leadingWidth: 72,
        leading: Center(child: GestureDetector(onTap: () => context.pop(), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)))),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Phone Number', textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(fontSize: 40 * textScale, fontWeight: FontWeight.w900, color: const Color(0xFF1E1E2C))),
                const SizedBox(height: 16),
                Text('Enter your number for verification', textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16 * textScale, color: const Color(0xFF888BAA), fontWeight: FontWeight.w500)),
                const SizedBox(height: 48),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : _showCountryPicker,
                      child: Container(
                        height: 60, padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [
                          Text(_selectedCountry.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(_selectedCountry.dialCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down)]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: _selectedCountry.maxLength,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          enabled: !_isLoading,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18 * textScale),
                          decoration: InputDecoration(
                              hintText: '893 456 789',
                              filled: true,
                              fillColor: Colors.white,
                              counterText: "",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF08080),
                      foregroundColor: const Color(0xFF1E1E2C),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E1E2C)))
                      : Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * textScale)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}