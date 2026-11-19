// Tips (S13) and FAQ (S14): own writing, built into assets/content/articles.json
// by tool/content/build_content.py, which checks every number against the bank.
import 'dart:convert';

import 'package:flutter/services.dart';

class TipPoint {
  const TipPoint(this.text, this.refs);
  final String text;

  /// Question numbers worth practising with this point.
  final List<int> refs;
}

class Tip {
  const Tip({
    required this.id,
    required this.title,
    required this.summary,
    required this.points,
    this.topicId,
  });
  final String id;
  final String title;
  final String summary;
  final List<TipPoint> points;
  final int? topicId;
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.widget,
  });
  final String id;
  final String question;
  final String answer;

  /// Extra content drawn from data, e.g. 'class_table'.
  final String? widget;
}

class FaqGroup {
  const FaqGroup(this.title, this.items);
  final String title;
  final List<FaqItem> items;
}

class Articles {
  const Articles({required this.tips, required this.faq});
  final List<Tip> tips;
  final List<FaqGroup> faq;

  static const empty = Articles(tips: [], faq: []);

  Tip? tip(String id) {
    for (final t in tips) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Future<Articles> load([AssetBundle? bundle]) async =>
      Articles.fromJson(
        jsonDecode(
          await (bundle ?? rootBundle).loadString(
            'assets/content/articles.json',
          ),
        ) as Map<String, dynamic>,
      );

  factory Articles.fromJson(Map<String, dynamic> json) => Articles(
    tips: [
      for (final t in json['tips'] as List)
        Tip(
          id: t['id'],
          title: t['title'],
          summary: t['summary'],
          topicId: t['topic'],
          points: [
            for (final p in t['points'] as List)
              TipPoint(p['text'], [
                for (final r in (p['refs'] as List?) ?? const []) r as int,
              ]),
          ],
        ),
    ],
    faq: [
      for (final g in json['faq'] as List)
        FaqGroup(g['title'], [
          for (final i in g['items'] as List)
            FaqItem(
              id: i['id'],
              question: i['q'],
              answer: i['a'],
              widget: i['widget'],
            ),
        ]),
    ],
  );
}
