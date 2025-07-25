import 'package:amazon_clone/common/widgets/custom_textfield.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/utils.dart';
import 'package:amazon_clone/features/address/services/address_services.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  const AddressScreen({super.key, required this.totalAmount});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  String phoneToBeUsed = "";
  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();

  // Add payment configuration futures
  late Future<PaymentConfiguration> _applePayConfigFuture;
  late Future<PaymentConfiguration> _googlePayConfigFuture;

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
        amount: widget.totalAmount,
        label: 'Total Amount',
        status: PaymentItemStatus.final_price,
      ),
    );

    // Initialize payment configurations
    _applePayConfigFuture = PaymentConfiguration.fromAsset('applepay.json');
    _googlePayConfigFuture = PaymentConfiguration.fromAsset('gpay.json');

    // Initialize phone from user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user.phone != null && user.phone!.isNotEmpty) {
        phoneController.text = user.phone!;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    phoneController.dispose();
  }

  void onApplePayResult(res) {
    print('Apple Pay Result: $res');
    try {
      if (Provider.of<UserProvider>(
        context,
        listen: false,
      ).user.address.isEmpty) {
        addressServices.saveUserAddress(
          context: context,
          address: addressToBeUsed,
        );
      }
      if (phoneToBeUsed.isNotEmpty &&
          Provider.of<UserProvider>(context, listen: false).user.phone !=
              phoneToBeUsed) {
        addressServices.saveUserPhone(context: context, phone: phoneToBeUsed);
      }
      addressServices.placeOrder(
        context: context,
        address: addressToBeUsed,
        totalSum: double.parse(widget.totalAmount),
      );
    } catch (e) {
      print('Apple Pay Error: $e');
      showSnackBar(context, 'Payment failed: ${e.toString()}');
    }
  }

  void onGooglePayResult(res) {
    print('Google Pay Result: $res');
    try {
      if (Provider.of<UserProvider>(
        context,
        listen: false,
      ).user.address.isEmpty) {
        addressServices.saveUserAddress(
          context: context,
          address: addressToBeUsed,
        );
      }
      if (phoneToBeUsed.isNotEmpty &&
          Provider.of<UserProvider>(context, listen: false).user.phone !=
              phoneToBeUsed) {
        addressServices.saveUserPhone(context: context, phone: phoneToBeUsed);
      }
      addressServices.placeOrder(
        context: context,
        address: addressToBeUsed,
        totalSum: double.parse(widget.totalAmount),
      );
    } catch (e) {
      print('Google Pay Error: $e');
      showSnackBar(context, 'Payment failed: ${e.toString()}');
    }
  }

  void onCODPayment() {
    print('COD Payment initiated');
    try {
      if (Provider.of<UserProvider>(
        context,
        listen: false,
      ).user.address.isEmpty) {
        addressServices.saveUserAddress(
          context: context,
          address: addressToBeUsed,
        );
      }
      if (phoneToBeUsed.isNotEmpty &&
          Provider.of<UserProvider>(context, listen: false).user.phone !=
              phoneToBeUsed) {
        addressServices.saveUserPhone(context: context, phone: phoneToBeUsed);
      }
      addressServices.placeOrderCOD(
        context: context,
        address: addressToBeUsed,
        totalSum: double.parse(widget.totalAmount),
      );
    } catch (e) {
      print('COD Payment Error: $e');
      showSnackBar(context, 'COD Order failed: ${e.toString()}');
    }
  }

  void showCODConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cash on Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Total: \$${widget.totalAmount}'),
              SizedBox(height: 10),
              Text('Payment Method: Cash on Delivery'),
              SizedBox(height: 10),
              Text('You will pay when the order is delivered to your address.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCODPayment();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                'Confirm Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void payPressed(String addressFromProvider) {
    addressToBeUsed = "";
    phoneToBeUsed = "";

    bool isForm =
        flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isForm) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${pincodeController.text} , ${cityController.text}';
      } else {
        throw Exception('Please enter all the values!');
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, 'ERROR');
    }

    // Handle phone number
    if (phoneController.text.isNotEmpty) {
      phoneToBeUsed = phoneController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address;
    var phone = context.watch<UserProvider>().user.phone;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty || (phone != null && phone.isNotEmpty))
                Column(
                  children: [
                    if (address.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                address,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (phone != null && phone.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(phone, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text('OR', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                  ],
                ),
              Form(
                key: _addressFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: flatBuildingController,
                      hintText: 'Flat, House no, Building',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: areaController,
                      hintText: 'Area, Street',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: pincodeController,
                      hintText: 'Ward',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: cityController,
                      hintText: 'Town/City',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // Apple Pay Button with FutureBuilder
              FutureBuilder<PaymentConfiguration>(
                future: _applePayConfigFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ApplePayButton(
                      paymentConfiguration: snapshot.data!,
                      width: double.infinity,
                      style: ApplePayButtonStyle.whiteOutline,
                      type: ApplePayButtonType.buy,
                      onPaymentResult: onApplePayResult,
                      paymentItems: paymentItems,
                      margin: const EdgeInsets.only(top: 15),
                      height: 50,
                      onPressed: () => payPressed(address),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 10),
              // Google Pay Button with FutureBuilder
              FutureBuilder<PaymentConfiguration>(
                future: _googlePayConfigFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GooglePayButton(
                      paymentConfiguration: snapshot.data!,
                      onPressed: () => payPressed(address),
                      onPaymentResult: onGooglePayResult,
                      paymentItems: paymentItems,
                      height: 50,
                      width: double.infinity,
                      type: GooglePayButtonType.buy,
                      margin: const EdgeInsets.only(top: 15),
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 10),
              // Cash on Delivery Button
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      payPressed(address);
                      showCODConfirmationDialog();
                    } catch (e) {
                      showSnackBar(context, e.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Cash on Delivery (COD)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
