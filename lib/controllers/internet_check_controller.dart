import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dgc_demo_project/utils/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InternetCheckController extends GetxController {
  // Observable connectivity status
  final _connectionStatus = <ConnectivityResult>[ConnectivityResult.none].obs;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters
  List<ConnectivityResult> get connectionStatus => _connectionStatus.value;

  bool get isConnected => !_connectionStatus.contains(ConnectivityResult.none);

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startListening();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Start listening to connectivity changes
  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity listener error: $error');
        }
      },
    );
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final wasConnected = isConnected;
    _connectionStatus.value = result;
    final nowConnected = isConnected;

    // Show appropriate messages based on connectivity state changes
    if (!wasConnected && nowConnected) {
      _showConnectivityMessage(
        "internet_restored",
      ); // "ការភ្ជាប់អ៊ីនធឺណិតបានស្ដារឡើងវិញ"
    } else if (wasConnected && !nowConnected) {
      _showConnectivityMessage(
        "no_internet_connection",
      ); // "មិនមានការតភ្ជាប់អ៊ីនធឺណិត"
    }
  }

  /// Show connectivity message using context-safe approach
  void _showConnectivityMessage(String messageKey) {
    final context = Get.context;
    if (context != null) {
      // Use translation key if available, otherwise fallback to Khmer text
      final message = messageKey == "internet_restored"
          ? "ការភ្ជាប់អ៊ីនធឺណិតបានស្ដារឡើងវិញ"
          : "មិនមានការតភ្ជាប់អ៊ីនធឺណិត";
      showSnackbar(context, message);
    }
  }

  /// Initialize connectivity status
  void _initConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _connectionStatus.value = connectivityResult;

      // Show initial connectivity status if no connection
      if (!isConnected) {
        _showConnectivityMessage("no_internet_connection");
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to get connectivity: ${e.message}');
      }
      // Set to no connection on error
      _connectionStatus.value = [ConnectivityResult.none];
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during connectivity check: $e');
      }
      _connectionStatus.value = [ConnectivityResult.none];
    }
  }

  /// Manually refresh connectivity status
  void refreshConnectivity() {
    _initConnectivity();
  }

  /// Check if device has any network connection
  bool hasNetworkConnection() {
    return _connectionStatus.any(
      (connection) =>
          connection == ConnectivityResult.wifi ||
          connection == ConnectivityResult.ethernet ||
          connection == ConnectivityResult.mobile ||
          connection == ConnectivityResult.vpn,
    );
  }

  /// Get readable connection type
  String getConnectionType() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else {
      return 'No Connection';
    }
  }
}
