import 'package:hyperpay/hyperpay.dart';

class TestConfig implements HyperpayConfig {
  @override
  String? creditcardEntityID = '8ac7a4c88518eb8b0185246b94b831bf';
  @override
  String? madaEntityID = '8ac7a4c88518eb8b0185246c8a3931c3';
  @override
  String? applePayEntityID = '';
  @override
  Uri checkoutEndpoint = _checkoutEndpoint;
  @override
  Uri statusEndpoint = _statusEndpoint;
  @override
  PaymentMode paymentMode = PaymentMode.test;
}

class LiveConfig implements HyperpayConfig {
  @override
  String? creditcardEntityID = '8ac7a4c88518eb8b0185246b94b831bf';
  @override
  String? madaEntityID = '8ac7a4c88518eb8b0185246c8a3931c3';
  @override
  String? applePayEntityID = '';
  @override
  Uri checkoutEndpoint = _checkoutEndpoint;
  @override
  Uri statusEndpoint = _statusEndpoint;
  @override
  PaymentMode paymentMode = PaymentMode.live;
}

// Setup using your own endpoints.
// https://wordpresshyperpay.docs.oppwa.com/tutorials/mobile-sdk/integration/server.

String _host = 'us-central1-vetapp-9c64c.cloudfunctions.net';

Uri _checkoutEndpoint = Uri(
  scheme: 'https',
  host: _host,
  path: 'checkout',
);

Uri _statusEndpoint = Uri(
  scheme: 'https',
  host: _host,
  path: 'paymentStatus',
);

