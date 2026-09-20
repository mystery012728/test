part of 'order_bloc.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderPlacing extends OrderState {
  const OrderPlacing();
}

class OrderPlacementSuccess extends OrderState {
  final OrderModel order;

  const OrderPlacementSuccess(this.order);
}

class OrderHistoryLoaded extends OrderState {
  final List<OrderModel> orders;

  const OrderHistoryLoaded(this.orders);
}

class OrderHistoryEmpty extends OrderState {
  const OrderHistoryEmpty();
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);
}
