// S16: search the current class's questions by words (accents optional) or
// by number.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/search.dart';
import '../../providers.dart';
import 'question_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  static const _shown = 50;
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cls = ref.watch(currentClassProvider);
    final pool = ref.watch(contentRepoProvider).pool(cls.code);
    final results = searchQuestions(pool, _query);

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm câu hỏi')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppLayout.gutter),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    labelText: 'Từ khóa hoặc số câu',
                    hintText: 'vd: nồng độ cồn, duong cao toc, 145',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Xóa từ khóa',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _controller.clear();
                              _query = '';
                            }),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _query.trim().isEmpty
                    ? ListView(
                        children: [
                          EmptyState(
                            icon: Icons.manage_search,
                            title:
                                'Tìm trong ${pool.length} câu của ${cls.name}',
                            body:
                                'Gõ vài từ trong câu hỏi hoặc đáp án, có dấu hay không dấu đều được. '
                                'Gõ một con số để mở đúng câu đó.',
                          ),
                        ],
                      )
                    : results.isEmpty
                    ? ListView(
                        children: const [
                          EmptyState(
                            icon: Icons.search_off,
                            title: 'Không tìm thấy câu nào',
                            body: 'Thử bớt từ hoặc dùng từ khác.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: AppSpace.s24),
                        itemCount:
                            (results.length > _shown
                                ? _shown
                                : results.length) +
                            1,
                        separatorBuilder: (_, i) =>
                            i == 0 ? const SizedBox.shrink() : const Divider(),
                        itemBuilder: (_, i) => i == 0
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppLayout.gutter,
                                  0,
                                  AppLayout.gutter,
                                  AppSpace.s8,
                                ),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    results.length > _shown
                                        ? '${results.length} câu, hiện $_shown câu đầu. Thêm từ để thu hẹp.'
                                        : '${results.length} câu',
                                    style: AppType.sm.copyWith(
                                      color: c.textMuted,
                                    ),
                                  ),
                                ),
                              )
                            : QuestionRow(question: results[i - 1]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
