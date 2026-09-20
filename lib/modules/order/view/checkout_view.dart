import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/local/local_preference.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_toast_bar.dart';
import '../../cart/bloc/cart/cart_bloc.dart';
import '../bloc/order_bloc.dart';
import '../models/order_model.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int _selectedPaymentMethod = 0;
  final String _deliveryAddress =
      '4517 Washington Ave. Manchester, Kentucky 39495';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard ending in •••• 4242',
      'icon': Icons.credit_card_rounded,
    },
    {
      'title': 'Apple Pay',
      'subtitle': 'Instant, secure one-touch payment',
      'icon': Icons.apple_rounded,
    },
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay with cash upon package arrival',
      'icon': Icons.local_atm_rounded,
    },
  ];

  void _onPlaceOrder(BuildContext context, CartLoaded cartState) {
    if (cartState.items.isEmpty) {
      CustomToastBar.showWarning(context, 'Your cart is empty.');
      return;
    }

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final order = OrderModel(
      orderId: orderId,
      userId: LocalPreference.userId ?? 'guest',
      items: cartState.items,
      subtotal: cartState.subtotal,
      shippingFee: cartState.shippingFee,
      tax: cartState.tax,
      totalAmount: cartState.grandTotal,
      shippingAddress: _deliveryAddress,
      paymentMethod: _paymentMethods[_selectedPaymentMethod]['title'] as String,
      status: 'Processing',
      createdAt: DateTime.now(),
    );

    context.read<OrderBloc>().add(PlaceOrderEvent(order));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlacementSuccess) {
          // Empty the cart upon successful order placement
          context.read<CartBloc>().add(const ClearCartEvent());
          // Refresh order history in background
          context
              .read<OrderBloc>()
              .add(const LoadOrderHistoryEvent(isRefresh: true));
          // Navigate to Order Success Screen
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.orderSuccess,
            arguments: state.order.orderId,
          );
        } else if (state is OrderError) {
          CustomToastBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            'Checkout',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                if (cartState is! CartLoaded || cartState.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_shopping_cart_outlined,
                              size: 64.sp, color: AppColors.textSubtle),
                          SizedBox(height: 16.h),
                          Text(
                            'No items to checkout',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Back to Cart'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Delivery Address Card
                      Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 22.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Default Shipping Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _deliveryAddress,
                                    style: TextStyle(
                                      color: AppColors.textSubtle,
                                      fontSize: 12.sp,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 22.h),

                      // 2. Payment Method Selector
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...List.generate(
                        _paymentMethods.length,
                        (index) => _buildPaymentTile(
                          index: index,
                          title: _paymentMethods[index]['title'] as String,
                          subtitle: _paymentMethods[index]['subtitle'] as String,
                          icon: _paymentMethods[index]['icon'] as IconData,
                        ),
                      ),
                      SizedBox(height: 22.h),

                      // 3. Items Preview
                      Text(
                        'Order Items (${cartState.totalItemCount})',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: cartState.items.map((item) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x  ${item.title}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 22.h),

                      // 4. Order Summary Breakdown
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Subtotal',
                              '\$${cartState.subtotal.toStringAsFixed(2)}',
                            ),
                            SizedBox(height: 6.h),
                            _buildSummaryRow(
                              'Shipping Fee',
                              cartState.shippingFee == 0.0
                                  ? 'FREE'
                                  : '\$${cartState.shippingFee.toStringAsFixed(2)}',
                              isGreen: cartState.shippingFee == 0.0,
                            ),
                            SizedBox(height: 6.h),
                            _buildSummaryRow(
                              'Tax (8%)',
                              '\$${cartState.tax.toStringAsFixed(2)}',
                            ),
                            Divider(color: AppColors.border, height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  '\$${cartState.grandTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // 5. Place Order Button
                      BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, orderState) {
                          final isPlacing = orderState is OrderPlacing;

                          return SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: isPlacing
                                  ? null
                                  : () => _onPlaceOrder(context, cartState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: isPlacing
                                  ? const CircularProgressIndicator(
                                      color: AppColors.white,
                                    )
                                  : Text(
                                      'Confirm & Place Order (\$${cartState.grandTotal.toStringAsFixed(2)})',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = index);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSubtle,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSubtle),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isGreen ? AppColors.success : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
