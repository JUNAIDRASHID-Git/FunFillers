import '../entities/user.dart';
import '../entities/product.dart';
import '../entities/category.dart';
import '../entities/cart_item.dart';
import '../entities/address.dart';
import '../entities/order.dart';

abstract class AppRepository {
  // Auth
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> signUp(String name, String email, String password);
  Future<UserEntity> signInWithGoogle({String? email, String? name, String? avatarUrl});
  Future<Map<String, dynamic>> sendPhoneOtp(String phone);
  Future<UserEntity> verifyPhoneOtp(String phone, String otp);
  Future<UserEntity> signInAsGuest();
  Future<UserEntity?> getCurrentUser();
  Future<void> signOut();

  // Catalog & Products
  Future<List<ProductEntity>> getProducts();
  Future<List<CategoryEntity>> getCategories();
  Future<List<ProductEntity>> searchProducts(String query);

  // Addresses
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> addAddress(AddressEntity address);

  // Orders
  Future<List<UserOrderEntity>> getOrders();
  Future<UserOrderEntity> createOrder(
    List<CartItemEntity> items,
    AddressEntity shippingAddress,
    String paymentMethod,
    double totalAmount,
  );

  // Wishlist
  Future<List<ProductEntity>> getWishlist();
  Future<bool> toggleWishlist(ProductEntity product);
}
