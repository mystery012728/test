import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_empty_state.dart';
import '../../../core/widgets/common_error_state.dart';
import '../../home/widgets/product_card_widget.dart';
import '../bloc/search/search_bloc.dart';
import '../widgets/product_skeleton_loader.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _searchController;

  static const List<String> _popularKeywords = [
    'iPhone',
    'Sneakers',
    'Watch',
    'Perfume',
    'Laptop',
    'Sunglasses',
    'Beauty',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<SearchBloc>().add(const LoadSearchInitialEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      _searchController.text = trimmed;
      context.read<SearchBloc>().add(SearchQuerySubmittedEvent(trimmed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _triggerSearch,
          decoration: InputDecoration(
            hintText: 'Search products, brands...',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSubtle,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_rounded, color: AppColors.textSubtle, size: 20.sp),
            onPressed: () {
              _searchController.clear();
              context.read<SearchBloc>().add(const ClearSearchEvent());
            },
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: AppColors.primary, size: 22.sp),
            onPressed: () => _triggerSearch(_searchController.text),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return const ProductListSkeletonLoader(itemCount: 6);
              }

              if (state is SearchError) {
                return CommonErrorState(
                  message: state.message,
                  onRetry: () {
                    context.read<SearchBloc>().add(
                          SearchQuerySubmittedEvent(_searchController.text.trim()),
                        );
                  },
                );
              }

              if (state is SearchEmpty) {
                return CommonEmptyState(
                  title: 'No results for "${state.query}"',
                  subtitle:
                      'Try checking spelling or use more general terms.',
                  icon: Icons.search_off_rounded,
                );
              }

              if (state is SearchLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: Text(
                        'Found ${state.results.length} results for "${state.query}"',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.w,
                          mainAxisSpacing: 14.h,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          return ProductCardWidget(
                            product: state.results[index],
                            isHorizontal: false,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              // Initial State: Render Last 3 Recent Searches and Trending Searches from BLoC state
              final lastThreeSearches = state.recentSearches.take(3).toList();

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last 3 Recent Searches Section
                    if (lastThreeSearches.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<SearchBloc>().add(
                                    const ClearRecentSearchesEvent(),
                                  );
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ...lastThreeSearches.map((search) {
                        return InkWell(
                          onTap: () => _triggerSearch(search),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 4.w),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 18.sp, color: AppColors.textSubtle),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    search,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.north_west_rounded,
                                    size: 14.sp, color: AppColors.textSubtle),
                              ],
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 12.h),
                      const Divider(color: AppColors.border),
                      SizedBox(height: 16.h),
                    ],

                    // Trending Searches Section
                    Text(
                      'Trending Searches',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _popularKeywords.map((keyword) {
                        return ActionChip(
                          avatar: Icon(Icons.trending_up_rounded,
                              size: 14.sp, color: AppColors.primary),
                          label: Text(keyword),
                          labelStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: () => _triggerSearch(keyword),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
