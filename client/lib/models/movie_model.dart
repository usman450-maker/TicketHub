class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final int? runtime;
  final List<CastMember>? cast;
  final String? trailerKey;
  final List<Genre>? genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    this.runtime,
    this.cast,
    this.trailerKey,
    this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      runtime: json['runtime'],
      genres: json['genres'] != null
          ? (json['genres'] as List).map((g) => Genre.fromJson(g)).toList()
          : null,
    );
  }

  String get fullPosterUrl {
    if (posterPath.isEmpty) return '';
    // Ensure path starts with /
    final path = posterPath.startsWith('/') ? posterPath : '/$posterPath';
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  String get fullBackdropUrl {
    if (backdropPath.isEmpty) return '';
    final path = backdropPath.startsWith('/') ? backdropPath : '/$backdropPath';
    return 'https://image.tmdb.org/t/p/original$path';
  }

  String get rating => voteAverage.toStringAsFixed(1);
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }

  String get fullProfileUrl {
    if (profilePath.isEmpty) {
      return 'https://ui-avatars.com/api/?name=$name&background=6B8E7B&color=fff&size=200';
    }
    final path = profilePath.startsWith('/') ? profilePath : '/$profilePath';
    return 'https://image.tmdb.org/t/p/w500$path';
  }
}