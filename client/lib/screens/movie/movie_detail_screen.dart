import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    final movie = await MovieService.getMovieDetails(widget.movieId);
    if (mounted) {
      setState(() {
        _movie = movie;
        _isLoading = false;
      });
    }
  }

  void _playTrailer() {
    if (_movie?.trailerKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trailer available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: _TrailerPlayer(videoKey: _movie!.trailerKey!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Movie not found')),
      );
    }

    final movie = _movie!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                SizedBox(
                  height: 340,
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
                child: CircularProgressIndicator(color: Colors.white),
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
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (movie.genres != null &&
                                movie.genres!.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: movie.genres!
                                    .take(2)
                                    .map((g) => _buildTag(
                                        g.name.toUpperCase(),
                                        Colors.white.withValues(alpha: 0.2)))
                                    .toList(),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xFFC49B63), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${movie.rating} / 10',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (movie.runtime != null) ...[
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time,
                                      color: Colors.white70, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(movie.runtime! / 60).floor()}h ${movie.runtime! % 60}m',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                GestureDetector(
                                  onTap: _playTrailer,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC49B63),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'The Story',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.overview.isEmpty
                            ? 'No description available.'
                            : movie.overview,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cast
                      if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Principal Cast',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movie.cast!.length,
                            itemBuilder: (context, index) {
                              return _buildCastCard(movie.cast![index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              iconBg: const Color(0xFFBFDCC9),
                              iconColor: AppColors.primary,
                              label: 'RELEASE DATE',
                              value: movie.releaseDate.isNotEmpty
                                  ? movie.releaseDate
                                  : 'Not available',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              iconBg: const Color(0xFFBFDCC9),
                              iconColor: AppColors.primary,
                              label: 'LOCATION',
                              value: 'Grand Cinema Royale',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Starting from',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$24.00',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Limited Availability',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textDark),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.share, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child:ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(
    context,
    RouteNames.selectShowtime,
    arguments: {
      'movieId': movie.id,
      'title': movie.title,
      'poster': movie.fullPosterUrl,
      'backdrop': movie.fullBackdropUrl,
    },
  ),
                    icon: const Icon(Icons.confirmation_number,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'BOOK TICKETS NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

 Widget _buildCastCard(CastMember cast) {
  return Container(
    width: 110,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            cast.fullProfileUrl,
            height: 90,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 90,
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, error, _) {
              return Container(
                height: 90,
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cast.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          cast.character,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGrey,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
        showControls: true,
        showFullscreenButton: true,
        mute: false,
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