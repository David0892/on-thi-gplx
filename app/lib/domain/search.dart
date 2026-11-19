// Question search (S16): accent-insensitive text match or a question number.
import 'models.dart';

const _from =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
const _to =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
final _map = {for (var i = 0; i < _from.length; i++) _from[i]: _to[i]};

/// Lower case, Vietnamese accents removed ("Biển" → "bien", "đường" → "duong"),
/// runs of whitespace collapsed, so "duong cao toc" finds "đường cao tốc".
String foldVietnamese(String s) {
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    b.write(_map[ch] ?? ch);
  }
  return b
      .toString()
      .replaceAll(_combining, '') // input typed as base letter + accent mark
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final _combining = RegExp('[\u0300-\u036f]');

final _numberQuery = RegExp(r'^(?:cau\s*)?(\d{1,3})$');

/// Questions from [pool] matching [query], in bank order.
///
/// "145" or "câu 145" finds that question by number. Otherwise every word of
/// the query must appear in the question text or one of its options.
List<Question> searchQuestions(List<Question> pool, String query) {
  final q = foldVietnamese(query);
  if (q.isEmpty) return const [];
  final number = _numberQuery.firstMatch(q);
  if (number != null) {
    final n = int.parse(number.group(1)!);
    return [
      for (final x in pool)
        if (x.number == n) x,
    ];
  }
  final words = q.split(' ');
  return [
    for (final x in pool)
      if (_matches(foldVietnamese('${x.text} ${x.options.join(' ')}'), words))
        x,
  ];
}

bool _matches(String haystack, List<String> words) =>
    words.every(haystack.contains);
