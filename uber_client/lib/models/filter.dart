import 'bag.dart';

class Filter {
  final bool showSoldOut;
  final List<String> tags;

  Filter({
    this.showSoldOut = true,
    this.tags = const [],
  });

  bool get isEmpty {
    return tags.isEmpty && showSoldOut == true;
  }

  Filter copyWith({
    bool? showSoldOut,
    List<String>? tags,
  }) {
    return Filter(
      showSoldOut: showSoldOut ?? this.showSoldOut,
      tags: tags ?? this.tags,
    );
  }

  Filter toggleTag(String tag) {
    var newTags = tags;
    if (tags.contains(tag)) {
      newTags = tags.where((element) => element != tag).toList();
    } else {
      newTags = [...tags, tag];
    }

    return copyWith(tags: newTags);
  }

  bool check(Bag bag, int quantity) {
    if (tags.isNotEmpty && !tags.any((t) => bag.tags.contains(t))) return false;
    if (!showSoldOut && quantity < 2) return false;

    return true;
  }
}
