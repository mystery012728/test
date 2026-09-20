import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../repo/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(const OrderInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<LoadOrderHistoryEvent>(_onLoadOrderHistory);
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderPlacing());
    try {
      final order = await orderRepository.placeOrder(event.order);
      emit(OrderPlacementSuccess(order));
    } catch (e) {
      emit(OrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistoryEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const OrderLoading());
    }

    try {
      final orders = await orderRepository.fetchOrders();
      if (orders.isEmpty) {
        emit(const OrderHistoryEmpty());
      } else {
        emit(OrderHistoryLoaded(orders));
      }
    } catch (e) {
      emit(OrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
