class ApiRoute {
  static const String login = "customer/login";
  static const String register = "customer/register";
  static const String profile = "customer/profile";
  static const String editProfile = "customer/profile/update";

  /// Order
  static const String createOrder = "customer/order/store";

  static String updateOrder(String id) => "customer/order/update/$id";

  static String deleteOrder(String id) => "customer/order/destroy/$id";
  static const String orders = "customer/order/all";

  static String orderDetail(String id) => "customer/order/$id";

  /// Warehouses
  static const String warehouse = "warehouse/all";
}
