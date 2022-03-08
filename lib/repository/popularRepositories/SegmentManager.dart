import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Segment.dart';
import 'package:flutter/foundation.dart';

class SegmentManager extends ChangeNotifier {
  static final SegmentManager _manager = SegmentManager._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory SegmentManager() {
    return _manager;
  }

  SegmentManager._initializer();

  List<Segment> _segments = [];
  List<Segment> get segments => _segments;

  void addSegment(Segment segment) {
    if (_segments == null || _segments.length == 0) {
      _segments = [segment];
    } else {
      if (!_segments.contains(segment)) _segments.add(segment);
    }
  }

  Future<List<Segment>> fetchSegments() async {
    if (_segments == null || _segments.length == 0)
      return await refreshSegments();
    return _segments;
  }

  Future<List<Segment>> refreshSegments() async {
    final resp = await _connector.getContent('/api/v1/SegmentoProduto/list');
    Segment.fromJSONList(resp.returnBody!);
    _segments.sort((seg1, seg2) => seg1.order!.compareTo(seg2.order!));
    return _segments;
  }
}
