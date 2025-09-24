// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vcare_payment_module/ui/fluid/providers/fluid_card_form_provider.dart';

class FluidBottomSheetContent extends StatefulWidget {
  const FluidBottomSheetContent({super.key});

  @override
  State<FluidBottomSheetContent> createState() =>
      _FluidBottomSheetContentState();
}

class _FluidBottomSheetContentState extends State<FluidBottomSheetContent> {
  final FocusNode _cardHolderNameFocus = FocusNode();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardHolderNameFocus.dispose();
    _cardFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _cardHolderNameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String getCardAsset(CardType type) {
    switch (type) {
      case CardType.Visa:
        return 'assets/visa.svg';
      case CardType.Mastercard:
        return 'assets/master.svg';
      case CardType.Amex:
        return 'assets/amex.svg';
      case CardType.Discover:
        return 'assets/discover.svg';
      case CardType.JCB:
        return 'assets/jcb.svg';
      default:
        return 'assets/unknown.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FluidCardFormProvider>();

    Color white30 = const Color(0xFF000000).withAlpha(77);
    Color white60 = const Color(0xFF000000).withAlpha(153);
    Color shadowColor = const Color(0xFF000000).withAlpha(102);

    const errorStyle = TextStyle(color: Colors.red, fontSize: 12, height: 1.0);

    bool isButtonDisabled =
        provider.buttonState == ButtonState.loading ||
        provider.buttonState == ButtonState.success;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              "Cardholder information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: shadowColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: white30),
              ),
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: TextFormField(
                focusNode: _cardHolderNameFocus,
                controller: _cardHolderNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: "Cardholder Name",
                  hintStyle: TextStyle(color: white60),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  errorStyle: errorStyle,
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cardholder name';
                  }
                  if (value.length < 3) {
                    return 'Too short';
                  }
                  return null;
                },
                onChanged: (value) {
                  provider.setCardHolderName(value, _cardHolderNameController);
                },
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Card information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: shadowColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: white30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        child: TextFormField(
                          focusNode: _cardFocus,
                          controller: _cardController,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: "Card Number",
                            hintStyle: TextStyle(color: white60),
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: SvgPicture.asset(
                                getCardAsset(provider.cardType),
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                package: 'vcare_payment_module',
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                              maxHeight: 36,
                              maxWidth: 80,
                            ),
                            errorStyle: errorStyle,
                          ),
                          style: const TextStyle(color: Colors.black87),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              19,
                            ), // 16 digits + 3 spaces
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a card number';
                            }
                            if (!isValidCardNumber(value)) {
                              return 'Invalid card number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            provider.setCardNumber(_cardController, value);
                            if (provider.cardNumber
                                    .replaceAll(' ', '')
                                    .length ==
                                16) {
                              _expiryFocus.requestFocus();
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 1,
                        color: white30,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: TextFormField(
                                focusNode: _expiryFocus,
                                controller: _expiryController,
                                keyboardType: TextInputType.number,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  hintText: "MM/YY",
                                  counterText: "",
                                  hintStyle: TextStyle(color: white60),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.black87,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  errorStyle: errorStyle,
                                ),
                                style: const TextStyle(color: Colors.black87),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(5), // MM/YY
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (!RegExp(
                                    r'^(0[1-9]|1[0-2])\/\d{2}$',
                                  ).hasMatch(value)) {
                                    return 'Invalid MM/YY';
                                  }

                                  final parts = value.split('/');
                                  final month = int.tryParse(parts[0]);
                                  final year = int.tryParse(parts[1]);
                                  final now = DateTime.now();
                                  final currentYear = int.parse(
                                    now.year.toString().substring(2),
                                  );

                                  if (month == null || year == null) {
                                    return 'Invalid date';
                                  }
                                  if (year < currentYear ||
                                      (year == currentYear &&
                                          month < now.month)) {
                                    return 'Expired card';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  provider.setExpiry(value, _expiryController);
                                  if (value.length == 5) {
                                    _cvvFocus.requestFocus();
                                  } else if (value.isEmpty) {
                                    _cardFocus.requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              child: TextFormField(
                                focusNode: _cvvFocus,
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: "CVV",
                                  hintStyle: TextStyle(color: white60),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black87,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  errorStyle: errorStyle,
                                ),
                                style: const TextStyle(color: Colors.black87),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.length < 3) return 'Too short';
                                  return null;
                                },
                                onChanged: (value) {
                                  provider.setCVV(value, _cvvController);
                                  if (value.isEmpty) {
                                    _expiryFocus.requestFocus();
                                  }
                                },
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
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonDisabled
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          provider.setButtonState(ButtonState.loading);

                          await Future.delayed(const Duration(seconds: 2));

                          provider.setButtonState(ButtonState.success);

                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );
                          Navigator.pop(context);

                          provider.setButtonState(ButtonState.idle);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.amber,
                  elevation: 0,
                  shadowColor: shadowColor,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: provider.buttonState == ButtonState.idle
                      ? const Text(
                          "Pay Now",
                          key: ValueKey('pay_now_text'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      : provider.buttonState == ButtonState.loading
                      ? const SizedBox(
                          key: ValueKey('loading_spinner'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black87,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.check,
                          key: ValueKey('success_icon'),
                          color: Colors.black87,
                          size: 24,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
