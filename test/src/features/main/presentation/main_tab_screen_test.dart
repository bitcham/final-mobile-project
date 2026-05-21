import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';
import 'package:movie_rating/src/features/main/presentation/main_tab_screen.dart';
import 'package:movie_rating/src/features/search/data/search_providers.dart';
import 'package:movie_rating/src/features/search/data/tmdb_api_client.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'
    as launcher_platform;

const _testUser = AppUser(
  id: 1,
  email: 'viewer@example.test',
  passwordHash: 'hash',
  passwordSalt: 'salt',
  realName: 'Test Viewer',
);

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.single
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  testWidgets('renders the essential home search and settings surfaces', (
    tester,
  ) async {
    await _pumpMainTab(tester, onLogout: () {});

    expect(find.text('CINERATE'), findsOneWidget);
    expect(find.text('Deadpool & Wolverine'), findsWidgets);
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('Watch Trailer'), findsOneWidget);
    expect(find.text('Sonic 3'), findsNothing);

    await _openTab(tester, 'SEARCH');
    expect(find.text('search for movies, series,...'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Iron Man'), findsWidgets);
    expect(find.text('Attack on Titan'), findsNothing);

    await _openTab(tester, 'SETTINGS');
    expect(find.text('Test Viewer'), findsOneWidget);
    expect(find.text('@viewer'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('My watchlist'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Add a payment method'), findsNothing);
    expect(find.text('Push notifications'), findsNothing);
    expect(find.text('About us'), findsNothing);
    expect(find.text('Privacy policy'), findsNothing);
    expect(find.text('Terms and conditions'), findsNothing);
    expect(find.text('FAQ'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
  });

  testWidgets('wide browser layout keeps navigation and hero actions visible', (
    tester,
  ) async {
    await _pumpMainTab(tester, viewSize: const Size(1067, 852));

    final frameRect = tester.getRect(
      find.byKey(const ValueKey('main-design-frame')),
    );
    expect(frameRect.size, const Size(1067, 600));

    final homeNavRect = tester.getRect(find.text('HOME'));
    expect(homeNavRect.bottom, lessThanOrEqualTo(600));

    final watchlistRect = tester.getRect(
      find.byKey(const ValueKey('hero-watchlist-Deadpool & Wolverine')),
    );
    expect(watchlistRect.left, greaterThanOrEqualTo(0));
    expect(watchlistRect.right, lessThanOrEqualTo(1067));
  });

  testWidgets('movie actions open trailers save ratings and update history', (
    tester,
  ) async {
    final openedTrailerUrls = <Uri>[];
    await _pumpMainTab(
      tester,
      onOpenTrailer: (trailerUrl) async {
        openedTrailerUrls.add(trailerUrl);
      },
    );

    await tester.tap(find.text('Watch Trailer'));
    await tester.pumpAndSettle();
    expect(openedTrailerUrls.single, Uri.parse(_deadpoolTrailerUrl));

    await tester.tap(find.byKey(const ValueKey('trending-movie-Iron Man')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tony Stark escapes captivity'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hero-watchlist-Iron Man')));
    await tester.pumpAndSettle();
    expect(find.text('Added to watchlist'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hero-rate-Iron Man')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rating-preset-4.5')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save rating'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Watch Trailer'));
    await tester.pumpAndSettle();
    expect(openedTrailerUrls.last, Uri.parse(_ironManTrailerUrl));

    await _openTab(tester, 'SETTINGS');
    await tester.tap(find.text('My watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('Iron Man'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Iron Man - 4.5 ★'), findsOneWidget);
  });

  testWidgets('search filters support rating and year ranges', (tester) async {
    await _pumpMainTab(tester);
    await _openTab(tester, 'SEARCH');

    await _enterQuery(tester, 'iron');
    expect(find.text('Iron Man'), findsWidgets);

    await tester.tap(find.text('Rating'));
    await tester.pumpAndSettle();
    expect(find.text('Rating Range'), findsOneWidget);
    expect(find.text('0.0'), findsWidgets);
    expect(find.text('5.0'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('rating-preset-5.0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('5.0+'), findsOneWidget);
    expect(find.text('No matches'), findsOneWidget);

    await tester.tap(find.text('5.0+'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rating-preset-0.0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('0.0+'), findsOneWidget);
    expect(find.text('Iron Man'), findsWidgets);

    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    expect(find.text('Year Range'), findsOneWidget);
    expect(find.text('1920'), findsWidgets);
    expect(find.text('2026'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('year-preset-2008')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('2008'), findsOneWidget);
    expect(find.text('Iron Man'), findsWidgets);
  });

  testWidgets('light mode keeps hero text and settings dialogs readable', (
    tester,
  ) async {
    await _pumpMainTab(tester);
    expect(_scaffoldBackground(tester), const Color(0xFF2A2A2A));

    await _openTab(tester, 'SETTINGS');
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(_scaffoldBackground(tester), const Color(0xFFF5F6F8));
    expect(
      tester.widget<Text>(find.text('Dark mode')).style?.color,
      const Color(0xFF161A22),
    );

    await tester.tap(find.byKey(const ValueKey('edit-bio-button')));
    await tester.pumpAndSettle();
    expect(find.text('Edit bio'), findsOneWidget);
    expect(
      CupertinoTheme.brightnessOf(tester.element(find.text('Edit bio'))),
      Brightness.light,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await _openTab(tester, 'HOME');
    expect(
      tester
          .widget<Text>(find.textContaining('homeworld is threatened').first)
          .style
          ?.color,
      CupertinoColors.white,
    );
  });

  testWidgets('default trailer launcher opens YouTube in a new web tab', (
    tester,
  ) async {
    final previousLauncher = launcher_platform.UrlLauncherPlatform.instance;
    final fakeLauncher = _FakeUrlLauncherPlatform();
    launcher_platform.UrlLauncherPlatform.instance = fakeLauncher;
    addTearDown(() {
      launcher_platform.UrlLauncherPlatform.instance = previousLauncher;
    });

    await _pumpMainTab(tester);

    await tester.tap(find.text('Watch Trailer'));
    await tester.pumpAndSettle();

    expect(fakeLauncher.launchedUrl, _deadpoolTrailerUrl);
    expect(
      fakeLauncher.launchOptions?.mode,
      launcher_platform.PreferredLaunchMode.platformDefault,
    );
    expect(fakeLauncher.launchOptions?.webOnlyWindowName, '_blank');
  });
}

Future<void> _pumpMainTab(
  WidgetTester tester, {
  AppUser user = _testUser,
  VoidCallback? onLogout,
  TrailerLauncherCallback? onOpenTrailer,
  Size viewSize = const Size(393, 852),
}) async {
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tmdbApiClientProvider.overrideWithValue(_FakeTmdbApiClient()),
      ],
      child: CupertinoApp(
        home: MainTabScreen(
          user: user,
          onLogout: onLogout,
          onOpenTrailer: onOpenTrailer,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Applies the typed query, waiting out the search-field debounce.
Future<void> _enterQuery(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(CupertinoTextField), query);
  await tester.pump(const Duration(milliseconds: 450));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Color? _scaffoldBackground(WidgetTester tester) {
  return tester
      .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold))
      .backgroundColor;
}

const _deadpoolTrailerUrl = 'https://www.youtube.com/watch?v=73_1biulkYk';
const _ironManTrailerUrl = 'https://www.youtube.com/watch?v=8ugaeA-nMTc';

/// In-memory TMDB stand-in so search tests stay offline and deterministic.
class _FakeTmdbApiClient extends TmdbApiClient {
  static const _catalog = [
    MovieView(
      title: 'Iron Man',
      synopsis: 'Tony Stark escapes captivity and builds an armored suit.',
      rating: 4.0,
      genres: ['ACTION'],
      year: 2008,
    ),
    MovieView(
      title: 'The Avengers',
      synopsis: 'Earth\'s mightiest heroes assemble.',
      rating: 4.0,
      genres: ['ACTION'],
      year: 2012,
    ),
    MovieView(
      title: 'Top Tier',
      synopsis: 'A flawless five-star showcase.',
      rating: 5.0,
      genres: ['DRAMA'],
      year: 2020,
    ),
  ];

  @override
  Future<TmdbPage> searchMovies({
    required String query,
    int page = 1,
    int? year,
  }) async {
    final lower = query.toLowerCase();
    final movies = _catalog
        .where((m) => m.title.toLowerCase().contains(lower))
        .where((m) => year == null || m.year == year)
        .toList();
    return TmdbPage(movies: movies, page: 1, totalPages: 1);
  }

  @override
  Future<TmdbPage> discoverMovies({
    int page = 1,
    int? year,
    double minRating = 0.0,
    bool sortByRating = false,
  }) async {
    final movies = _catalog
        .where((m) => year == null || m.year == year)
        .where((m) => m.rating >= minRating)
        .toList();
    return TmdbPage(movies: movies, page: 1, totalPages: 1);
  }
}

class _FakeUrlLauncherPlatform extends launcher_platform.UrlLauncherPlatform {
  String? launchedUrl;
  launcher_platform.LaunchOptions? launchOptions;

  @override
  get linkDelegate => null;

  @override
  Future<bool> launchUrl(
    String url,
    launcher_platform.LaunchOptions options,
  ) async {
    launchedUrl = url;
    launchOptions = options;
    return true;
  }
}
