import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/data/models/bannermodel.dart';

import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final AppRepo repository;

  BannerBloc({required this.repository}) : super(BannerInitial()) {
    on<FetchBannersEvent>(_onFetchBanners);
  }

  FutureOr<void> _onFetchBanners(
    FetchBannersEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      emit(BannerLoading());

      final resp = await repository.fetchBannersFromCollections();

      if (resp.error) {
        // Even on error, we show empty list - banners are optional
        emit(BannerSuccess([]));
        return;
      }

      emit(BannerSuccess(resp.data ?? []));
    } catch (e) {
      // Don't show error to user, just return empty banners
      emit(BannerSuccess([]));
    }
  }
}
