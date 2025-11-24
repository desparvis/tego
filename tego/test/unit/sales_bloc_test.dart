import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/presentation/bloc/sales_bloc.dart';
import '../../lib/domain/usecases/add_sale_usecase.dart';
import '../../lib/domain/entities/sale.dart';
import '../../lib/core/error/failures.dart';
import '../../lib/core/utils/either.dart';

@GenerateMocks([AddSaleUseCase])
import 'sales_bloc_test.mocks.dart';

void main() {
  group('SalesBloc Unit Tests', () {
    late SalesBloc salesBloc;
    late MockAddSaleUseCase mockAddSaleUseCase;

    setUp(() {
      mockAddSaleUseCase = MockAddSaleUseCase();
      salesBloc = SalesBloc(mockAddSaleUseCase);
    });

    tearDown(() {
      salesBloc.close();
    });

    test('initial state is SalesInitial', () {
      expect(salesBloc.state, equals(const SalesInitial()));
    });

    blocTest<SalesBloc, SalesState>(
      'emits [SalesLoading, SalesSuccess] when AddSaleEvent succeeds',
      build: () {
        when(mockAddSaleUseCase.execute(any, any))
            .thenAnswer((_) async => const Right(null));
        return salesBloc;
      },
      act: (bloc) => bloc.add(AddSaleEvent(amount: 1000, date: '01-01-2024')),
      expect: () => [
        const SalesLoading(),
        isA<SalesSuccess>(),
      ],
    );

    blocTest<SalesBloc, SalesState>(
      'emits [SalesLoading, SalesError] when AddSaleEvent fails',
      build: () {
        when(mockAddSaleUseCase.execute(any, any))
            .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));
        return salesBloc;
      },
      act: (bloc) => bloc.add(AddSaleEvent(amount: 1000, date: '01-01-2024')),
      expect: () => [
        const SalesLoading(),
        const SalesError('Network error', isRetryable: true),
      ],
    );

    blocTest<SalesBloc, SalesState>(
      'emits SalesInitial when ResetSalesStateEvent is added',
      build: () => salesBloc,
      act: (bloc) => bloc.add(ResetSalesStateEvent()),
      expect: () => [const SalesInitial()],
    );
  });
}