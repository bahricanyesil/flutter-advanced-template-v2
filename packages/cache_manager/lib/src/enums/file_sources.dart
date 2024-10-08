/// Enum representing different sources for files.
///
/// The [FileSources] enum defines the possible sources for files
/// in the cache storage.
/// It includes the following sources:
/// - [cache]: Files stored in the cache.
/// - [network]: Files fetched from the network.
/// - [memory]: Files stored in memory.
/// - [unknown]: Unknown source for files.
enum FileSources {
  /// Files stored in the cache.
  cache,

  /// Files fetched from the network.
  network,

  /// Files stored in memory.
  memory,

  /// Unknown source for files.
  unknown,
}
