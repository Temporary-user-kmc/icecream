import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
    ),
    home: const IcecreamApp()));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  static const ai1 = '🤖 AIゲーム（1つ）';
  static const ai3 = '🎟️ AIゲーム3つセット券';
  final foods = {
    '🎮 体感型ゲーム': 100,
    ai1: 500,
    ai3: 1200,
    '🍹 すだちモクテル（神山）': 700,
    '🥤 ドリンクバー1day': 500,
  };
  final aiGames = [
    '🧱 テトリスAI対戦', '🫧 ぷよぷよAI対戦',
    '🤝 相方AIと協力3D', '🕵️ AI3人とワードウルフ',
  ];
  late final qty = {for (final k in foods.keys) k: 0};
  final games = <String, int>{};
  int order = 0;
  String receipt = '';

  int get slots => qty[ai1]! + qty[ai3]! * 3;
  int get picked => games.values.fold(0, (a, b) => a + b);

  void trimGames() {
    for (final g in games.keys.toList()) {
      while (picked > slots && games[g]! > 0) { games[g] = games[g]! - 1; }
    }
    games.removeWhere((_, n) => n == 0);
  }

  Widget stepper(int n, VoidCallback? minus, VoidCallback? plus) => Row(
    mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: minus, icon: const Icon(Icons.remove)),
      SizedBox(width: 24, child: Text('$n', textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20))),
      IconButton(onPressed: plus, icon: const Icon(Icons.add)),
    ]);

  @override
  Widget build(BuildContext context) {
    final subtotal = foods.keys.fold(0, (a, k) => a + foods[k]! * qty[k]!);
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final photo = Center(child: Text(
      [for (final k in foods.keys) if (qty[k]! > 0) k.split(' ').first].join(),
      style: const TextStyle(fontSize: 50)));
    final products = Column(children: [
      for (final k in foods.keys)
        Row(children: [
          Expanded(child: Text('$k  ${foods[k]}円')),
          stepper(qty[k]!,
            qty[k]! > 0 ? () => setState(() { qty[k] = qty[k]! - 1; trimGames(); }) : null,
            () => setState(() => qty[k] = qty[k]! + 1)),
        ]),
    ]);
    final picker = slots == 0 ? const SizedBox.shrink() : Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(),
        Text('遊ぶゲームを選ぶ（$picked/$slots）'),
        for (final g in aiGames)
          Row(children: [
            Expanded(child: Text(g)),
            stepper(games[g] ?? 0,
              (games[g] ?? 0) > 0 ? () => setState(() {
                games[g] = games[g]! - 1;
                games.removeWhere((_, n) => n == 0);
              }) : null,
              picked < slots ? () => setState(() => games[g] = (games[g] ?? 0) + 1) : null),
          ]),
        const Text('テトリス・ぷよぷよ・協力3DはLv1〜5。Lv5クリアでモクテルプレゼント！'),
      ]);
    final bill = Column(children: [
      Text('税抜 $subtotal 円 / 消費税 $tax 円'),
      Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
    ]);
    final submit = Center(child: FilledButton(
      onPressed: total == 0 || picked != slots ? null : () => setState(() {
        order = Random().nextInt(999) + 1;
        final items = [for (final k in foods.keys) if (qty[k]! > 0) '$k × ${qty[k]}'];
        final played = [for (final g in games.keys) '$g × ${games[g]}'];
        receipt = '${items.join('\n')}\n'
            '${played.isEmpty ? '' : 'ゲーム: ${played.join(' / ')}\n'}'
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
      appBar: AppBar(centerTitle: true, scrolledUnderElevation: 0,
          title: const Text('🍸 ゲームバー toki 注文アプリ')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
        photo,
        const Text('商品を選ぶ'), products,
        picker,
        const Divider(),
        bill,
        submit, ticket,
      ]))),
    );
  }
}
