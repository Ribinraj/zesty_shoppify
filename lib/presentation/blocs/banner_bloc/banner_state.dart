part of 'banner_bloc.dart';

@immutable
sealed class BannerState {}

final class BannerInitial extends BannerState {}
class BannerLoading extends BannerState {}

class BannerSuccess extends BannerState {
  final List<BannerModel> banners;

  BannerSuccess(this.banners);
}

class BannerError extends BannerState {
  final String message;

  BannerError(this.message);
}