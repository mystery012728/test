import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/common_empty_state.dart';
import '../../../core/widgets/common_error_state.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../cart/bloc/cart/cart_bloc.dart';
import '../../home/widgets/product_card_widget.dart';
import '../bloc/product_list/product_list_bloc.dart';
import '../widgets/product_skeleton_loader.dart';

class ProductListView extends StatefulWidget {
  final String? category;

  const ProductListView({super.key, this.category});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late final ScrollController _scrollController;

  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<ProductListBloc>().add(
          FetchProductListEvent(category: widget.category),
        );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      context.read<ProductListBloc>().add(const LoadMoreProductsEvent());
    }
  }

  String _formatCategoryTitle(String? raw) {
    if (raw == null || raw.isEmpty) return 'All Products';
    return raw
        .split('-')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _formatCategoryTitle(widget.category);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          displayTitle,
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: AppColors.textDark, size: 22.sp),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final count = cartState.totalItemCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  backgroundColor: AppColors.error,
                  label: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textDark,
                    size: 24.sp,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: BlocBuilder<ProductListBloc, ProductListState>(
            builder: (context, state) {
              if (state is ProductListLoading) {
                return Column(
                  children: [
                    _buildSortBar(context, 'Recommended', 0, isLoading: true),
                    const Expanded(child: ProductListSkeletonLoader(itemCount: 6)),
                  ],
                );
              }

              if (state is ProductListError) {
                return CommonErrorState(
                  message: state.message,
                  onRetry: () {
                    context.read<ProductListBloc>().add(
                          FetchProductListEvent(
                            category: widget.category,
                            isRefresh: true,
                          ),
                        );
                  },
                );
              }

              if (state is ProductListEmpty) {
                return const CommonEmptyState(
                  title: 'No products found',
                  subtitle:
                      'Try browsing other categories or search for an item.',
                  icon: Icons.inventory_2_outlined,
                );
              }

              if (state is ProductListLoaded) {
                return Column(
                  children: [
                    _buildSortBar(
                      context,
                      state.activeSort,
                      state.total,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context.read<ProductListBloc>().add(
                                FetchProductListEvent(
                                  category: widget.category,
                                  isRefresh: true,
                                ),
                              );
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14.w,
                            mainAxisSpacing: 14.h,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return ProductCardWidget(
                              product: product,
                              isHorizontal: false,
                            );
                          },
                        ),
                      ),
                    ),
                    if (state.isLoadingMore)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        color: AppColors.scaffoldBackground,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 18.r,
                                width: 18.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Loading more items...',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSubtle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(
    BuildContext context,
    String activeSort,
    int productCount, {
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item count text
          Text(
            isLoading ? 'Loading...' : '$productCount Items Found',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
            ),
          ),

          // Sort dropdown
          Row(
            children: [
              Icon(
                Icons.sort_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.w),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: activeSort,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18.sp,
                    color: AppColors.textDark,
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  items: _sortOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (newSort) {
                          if (newSort != null) {
                            context.read<ProductListBloc>().add(
                                  ChangeSortEvent(sortOption: newSort),
                                );
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
