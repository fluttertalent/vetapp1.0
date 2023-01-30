import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperpay/hyperpay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'formatters.dart';

class CheckoutView extends StatefulWidget {
  final double amount;
  final String id;
  const CheckoutView({
    Key? key, required this.amount, required this.id,
  }) : super(key: key);
  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  TextEditingController holderNameController =
      TextEditingController();
  TextEditingController cardNumberController =
      TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  BrandType brandType = BrandType.visa;

  bool isLoading = false;
  String sessionCheckoutID = '';

  late HyperpayPlugin hyperpay;

  @override
  void initState() {
    setup();
    super.initState();
  }
  setup() async {
    // hyperpay = await HyperpayPlugin.setup(config: LiveConfig());
    hyperpay = await HyperpayPlugin.setup(config: TestConfig());
  }
  /// Initialize HyperPay session
  Future<void> initPaymentSession(
    BrandType brandType,
    double amount,
    String Id,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     var name = await prefs.getString('name');
     var mobile = await prefs.getString('phoneNumber');
     var email = await prefs.getString('email');

    CheckoutSettings _checkoutSettings = CheckoutSettings(
      brand: brandType,
      amount: amount,
      headers: {
        'Content-Type': 'application/json',
      },
      additionalParams: {
        'merchantTransactionId': Id,
        'merchantCustomerId': '#0845983457',
        'customerName': name,
        'customPhone': mobile,
        'email': email,
        // 'givenName': 'Mais',
        // 'surname': 'Alheraki',
        // 'email': 'mais@nyartech.com',
        // 'mobile': '+966551234567',
        'street1': 'Test',
        'city': 'Riyadh',
        'state': 'State',
        'country': 'SA',
        'postcode': '12345',
      },
    );
    print(_checkoutSettings);
    hyperpay.initSession(checkoutSetting: _checkoutSettings);
    print('initSession');
    sessionCheckoutID = await hyperpay.getCheckoutID;
    print('getCheckoutID');
    print(sessionCheckoutID);
  }

  Future<void> onPay(context) async {
    final bool valid = Form.of(context)?.validate() ?? false;

    if (valid) {
      setState(() {
        isLoading = true;
      });

      // Make a CardInfo from the controllers
      CardInfo card = CardInfo(
        holder: holderNameController.text,
        cardNumber: cardNumberController.text.replaceAll(' ', ''),
        cvv: cvvController.text,
        expiryMonth: expiryController.text.split('/')[0],
        expiryYear: '20' + expiryController.text.split('/')[1],
      );

      try {
        // Start transaction
        if (sessionCheckoutID.isEmpty) {
          // Only get a new checkoutID if there is no previous session pending now
          await initPaymentSession(brandType, widget.amount, widget.id);
        }
        print('paycard');
        final result = await hyperpay.pay(card);

        switch (result) {
          case PaymentStatus.init:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment session is still in progress'),
                backgroundColor: Colors.amber,
              ),
            );
            break;
          // For the sake of the example, the 2 cases are shown explicitly
          // but in real world it's better to merge pending with successful
          // and delegate the job from there to the server, using webhooks
          // to get notified about the final status and do some action.
          case PaymentStatus.pending:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment pending ⏳'),
                backgroundColor: Colors.amber,
              ),
            );
            break;
          case PaymentStatus.successful:
            sessionCheckoutID = '';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment approved 🎉'),
                backgroundColor: Colors.green,
              ),
            );
            break;
          default:
        }
      } on HyperpayException catch (exception) {
        sessionCheckoutID = '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.details ?? exception.message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (exception) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$exception'),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  void onApplePay(double amount) async {
    setState(() {
      isLoading = true;
    });

    // Start transaction
    if (sessionCheckoutID.isEmpty) {
      // Only get a new checkoutID if there is no previous session pending now
      await initPaymentSession(BrandType.applepay, amount, widget.id);
    }

    final applePaySettings = ApplePaySettings(
      amount: amount,
      appleMerchantId: 'merchant.com.emaan.app',
      countryCode: 'SA',
      currencyCode: 'SAR',
    );

    try {
      await hyperpay.payWithApplePay(applePaySettings);
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exception'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            autovalidateMode: autovalidateMode,
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      child: Image.asset('assets/images/YaMa vet-04 1.png'),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(height: 10),
                    // Holder
                    TextFormField(
                      autocorrect: false,
                      controller: holderNameController,
                      decoration: _inputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Color.fromRGBO(224, 115, 34, 1)), //<-- SEE HERE
                        ),
                        label: "Card Holder",
                        hint: "Jane Jones",
                        icon: Icons.account_circle_rounded,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Number
                    TextFormField(
                      controller: cardNumberController,
                      decoration: _inputDecoration(
                        label: "Card Number",
                        hint: "0000 0000 0000 0000",
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Color.fromRGBO(224, 115, 34, 1)), //<-- SEE HERE
                        ),
                        icon: brandType == BrandType.visa? 'assets/images/visa.png':
                              brandType == BrandType.mada? 'assets/images/mada.png':
                              brandType == BrandType.master? 'assets/images/master.png':
                              Icons.credit_card
                      ),
                      onChanged: (value) {
                        print(value.detectBrand);
                        setState(() {
                          brandType = value.detectBrand;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(brandType.maxLength),
                        CardNumberInputFormatter()
                      ],
                      validator: (String? number) =>
                          brandType.validateNumber(number ?? ""),
                    ),
                    const SizedBox(height: 10),
                    // Expiry date
                    TextFormField(
                      controller: expiryController,
                      decoration: _inputDecoration(
                        label: "Expiry Date",
                        hint: "MM/YY",
                        icon: Icons.date_range_rounded,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Color.fromRGBO(224, 115, 34, 1)), //<-- SEE HERE
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        CardMonthInputFormatter(),
                      ],
                      validator: (String? date) =>
                          CardInfo.validateDate(date ?? ""),
                    ),
                    const SizedBox(height: 10),
                    // CVV
                    TextFormField(
                      controller: cvvController,
                      decoration: _inputDecoration(
                        label: "CVV",
                        hint: "000",
                        icon: Icons.confirmation_number_rounded,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Color.fromRGBO(224, 115, 34, 1)), //<-- SEE HERE
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (String? cvv) =>
                          CardInfo.validateCVV(cvv ?? ""),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(224, 115, 34, 1), // Background color
                        ),
                        onPressed: () => onPay(context),
                        child: Text(
                          isLoading
                              ? 'Processing your request, please wait...'
                              : 'PAY',
                          style: const TextStyle(
                            fontFamily: 'Montserrat-SemiBold'
                          ),
                        ),
                      ),
                    ),
                    if (defaultTargetPlatform == TargetPlatform.iOS)
                      SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: ApplePayButton(
                          onPressed: () => onApplePay(1),
                          type: ApplePayButtonType.buy,
                          style: ApplePayButtonStyle.black,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {String? label, String? hint, dynamic icon, required OutlineInputBorder enabledBorder}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
          width: 3, color: Color.fromRGBO(224, 115, 34, 1)), //<-- SEE HERE
      ),
      prefixIcon: icon is IconData
          ? Icon(icon)
          : Container(
              padding: const EdgeInsets.all(6),
              width: 10,
              child: Image.asset(icon),
            ),
    );
  }
}
