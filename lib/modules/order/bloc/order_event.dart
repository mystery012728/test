part of 'order_bloc.dart';

abstract class OrderEvent {
  const OrderEvent();
}

class PlaceOrderEvent extends OrderEvent {
  final OrderModel order;

  const PlaceOrderEvent(this.order);
}

class LoadOrderHistoryEvent extends OrderEvent {
  final bool isRefresh;

  const LoadOrderHistoryEvent({this.isRefresh = false});
}
