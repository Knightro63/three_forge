enum SkeletonType { 
  fox, 
  human, 
  bird, 
  dragon, 
  kaiju, 
  spider, 
  snake, 
  fish, 
  error, 
  none;

  /// Parses a string representation into its matching SkeletonType.
  /// Handles case-insensitivity and strips unexpected whitespace.
  static SkeletonType fromString(String? typeStr) {
    if (typeStr == null || typeStr.trim().isEmpty) {
      return SkeletonType.none;
    }

    // Clean up input formatting for robust lookup
    final cleanStr = typeStr.trim().toLowerCase();

    return switch (cleanStr) {
      'fox' => SkeletonType.fox,
      'human' => SkeletonType.human,
      'bird' => SkeletonType.bird,
      'dragon' => SkeletonType.dragon,
      'kaiju' => SkeletonType.kaiju,
      'spider' => SkeletonType.spider,
      'snake' => SkeletonType.snake,
      'fish' => SkeletonType.fish,
      'none' => SkeletonType.none,
      _ => SkeletonType.error, // Safe fallback for unmatched strings
    };
  }
}

enum HandSkeletonType {
  allFingers,
  thumbAndIndex,
  simplifiedHand,
  singleBone,
  standard
}
