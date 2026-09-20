import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';
import '../../repo/product_repository.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository productRepository;

  ProductDetailBloc({required this.productRepository})
      : super(const ProductDetailInitial()) {
    on<FetchProductDetailEvent>(_onFetchProductDetail);
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetailEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    try {
      final product = await productRepository.getProductDetail(event.productId);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
