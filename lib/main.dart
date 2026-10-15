import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, home: IcecreamApp()));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final foods = {
    '🎮 体感型ゲーム': 100,
    '🤖 AIゲーム（1つ）': 500,
    '🎟️ AIゲーム3つセット券': 1200,
    '🍹 すだちモクテル（神山）': 700,
    '🥤 ドリンクバー1day': 500,
  };
  final aiGames = [
    '🧱 テトリスAI対戦', '🫧 ぷよぷよAI対戦',
    '🤝 相方AIと協力3D', '🕵️ AI3人とワードウルフ',
  ];
  late String food = foods.keys.first;
  final games = <String>{};
  int order = 0;
  String receipt = '';

  int get limit => food.contains('3つ') ? 3 : food.contains('AIゲーム') ? 1 : 0;

  Widget choices(Iterable<String> items, String value,
      void Function(String) change) => Wrap(spacing: 6, children: [
    for (final s in items)
      ChoiceChip(label: Text(s), selected: value == s,
        onSelected: (_) => setState(() => change(s))),
  ]);

  @override
  Widget build(BuildContext context) {
    final subtotal = foods[food]!;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final photo = Center(child: Text(food.split(' ').first,
      style: const TextStyle(fontSize: 90)));
    final products = choices(foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) {
        food = s.substring(0, s.lastIndexOf('  '));
        games.clear();
      });
    final picker = limit == 0 ? const SizedBox.shrink() : Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('遊ぶゲームを$limitつ選ぶ'
            '（${games.length}/$limit）'),
        Wrap(spacing: 6, children: [
          for (final s in aiGames)
            FilterChip(label: Text(s), selected: games.contains(s),
              onSelected: (v) => setState(() {
                if (!v) { games.remove(s); }
                else if (games.length < limit) { games.add(s); }
              })),
        ]),
        const Text('テトリス・ぷよぷよ・協力3DはLv1〜5。Lv5クリアでモクテルプレゼント！'),
      ]);
    final bill = Column(children: [
      Text('税抜 $subtotal 円 / 消費税 $tax 円'),
      Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
    ]);
    final submit = Center(child: FilledButton(onPressed: games.length != limit ? null : () => setState(() {
      order = Random().nextInt(999) + 1;
      receipt = '$food  ${foods[food]}円\n'
          '${games.isEmpty ? '' : 'ゲーム: ${games.join(' / ')}\n'}'
          '税抜: $subtotal 円 / 消費税（10%）: $tax 円\n'
          '合計: $total 円';
    }), child: const Text('注文する')));
    final ticket = order == 0 ? const SizedBox.shrink() : Card(child: Padding(
      padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('注文番号 #$order', style: const TextStyle(fontSize: 26)),
          Text(receipt),
        ],
      ),
    ));

    return Scaffold(
      appBar: AppBar(
          centerTitle: true, title: const Text('🍸 ゲームバー toki 注文アプリ')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: photo),
        const Text('商品を選ぶ'), products,
        picker,
        const Divider(),
        bill,
        submit, ticket,
      ]))),
    );
  }
}
