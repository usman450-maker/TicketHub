import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<Genre> _genres = [];
  List<Movie> _movies = [];
  List<Movie> _featuredMovies = [];
  int _selectedGenre = 0;
  int _currentFeatured = 0;
  bool _isLoading = true;
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final genres = await MovieService.getGenres();
      final featured = await MovieService.getNowPlaying();
      final movies = await MovieService.getPopular();

      if (mounted) {
        setState(() {
          _genres = genres;
          _featuredMovies = featured;
          _movies = movies;
          _isLoading = false;

          // Pick random featured on start
          if (_featuredMovies.isNotEmpty) {
            _currentFeatured = Random().nextInt(_featuredMovies.length);
          }
        });

        // Start auto-shuffle every 5 seconds
        _startShuffleTimer();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startShuffleTimer() {
    _shuffleTimer?.cancel();
    _shuffleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _featuredMovies.isNotEmpty) {
        setState(() {
          int newIndex;
          do {
            newIndex = Random().nextInt(_featuredMovies.length);
          } while (newIndex == _currentFeatured && _featuredMovies.length > 1);
          _currentFeatured = newIndex;
        });
      }
    });
  }

  Future<void> _filterByGenre(int index) async {
    setState(() {
      _selectedGenre = index;
      _isLoading = true;
    });

    List<Movie> movies;
    if (index == 0) {
      movies = await MovieService.getPopular();
    } else {
      final genreId = _genres[index - 1].id;
      movies = await MovieService.getMoviesByGenre(genreId);
    }

    if (mounted) {
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    }
  }

  // Play trailer for featured movie
  Future<void> _playFeaturedTrailer() async {
    if (_featuredMovies.isEmpty) return;

    final currentMovie = _featuredMovies[_currentFeatured];

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // Fetch full details to get trailer
    final fullMovie = await MovieService.getMovieDetails(currentMovie.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (fullMovie?.trailerKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No trailer available for this movie'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show trailer
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: _TrailerPlayer(videoKey: fullMovie!.trailerKey!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading && _movies.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'TicketHub',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderGrey),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://i.pravatar.cc/100?img=13',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.person),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Featured Banner (with auto-shuffle)
                      if (_featuredMovies.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _buildFeaturedBanner(
                              _featuredMovies[_currentFeatured],
                              key: ValueKey(_currentFeatured),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),

                      // Genres
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Explore Genres',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _genres.length + 1,
                          itemBuilder: (context, index) {
                            final label = index == 0
                                ? 'All Movies'
                                : _genres[index - 1].name;
                            final selected = _selectedGenre == index;
                            return GestureDetector(
                              onTap: () => _filterByGenre(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF1F3A2E)
                                      : const Color(0xFFBFDCC9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _selectedGenre == 0
                              ? 'Now Playing'
                              : '${_genres[_selectedGenre - 1].name} Movies',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Hand-picked screenings for an elevated experience.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_movies.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildBigMovieCard(_movies[0]),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: _movies.length > 1
                                ? _movies.length - 1
                                : 0,
                            itemBuilder: (context, index) {
                              return _buildSmallMovieCard(_movies[index + 1]);
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFeaturedBanner(Movie movie, {Key? key}) {
    return Container(
      key: key,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: movie.backdropPath.isNotEmpty
                  ? Image.network(
                      movie.fullBackdropUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, error, _) {
                        print('Backdrop error: $error');
                        return Container(color: AppColors.primaryLight);
                      },
                    )
                  : Container(color: AppColors.primaryLight),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (movie.overview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        movie.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Book Now Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.movieDetail,
                            arguments: movie.id,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC49B63),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Book Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Watch Trailer Button (WORKING!)
                      Expanded(
                        child: GestureDetector(
                          onTap: _playFeaturedTrailer,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Watch Trailer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicator dots
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: List.generate(
                  _featuredMovies.length > 5 ? 5 : _featuredMovies.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentFeatured % 5
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.movieDetail,
        arguments: movie.id,
      ),
      child: Container(
        height: 380,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: movie.posterPath.isNotEmpty
                    ? Image.network(
                        movie.fullPosterUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, error, _) {
                          print('Poster error: $error');
                          return Container(color: AppColors.primaryLight);
                        },
                      )
                    : Container(color: AppColors.primaryLight),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFC49B63),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (movie.releaseDate.isNotEmpty)
                      Text(
                        movie.releaseDate.split('-')[0],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.movieDetail,
        arguments: movie.id,
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.posterPath.isNotEmpty
                  ? Image.network(
                      movie.fullPosterUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, error, _) {
                        return Container(color: AppColors.primaryLight);
                      },
                    )
                  : Container(color: AppColors.primaryLight),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFC49B63),
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        movie.rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================
// YOUTUBE TRAILER PLAYER
// ==========================


class _TrailerPlayer extends StatefulWidget {
  final String videoKey;
  const _TrailerPlayer({required this.videoKey});

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoKey,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _controller),
        ),
      ],
    );
  }
}