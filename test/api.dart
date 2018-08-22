import 'dart:async';
import 'dart:convert';

import '../lib/models.dart';

Future<ComicBook> testBook(ComicBook book) async {
  print("Comic ${book.bookId}");
  await book.refresh();
  print("  name: ${book.name}");
  print("  url: ${book.url}");
  book.chapterGroups.forEach((grp) {
    print("  [$grp]");
    book.groupedChapterIdListMap[grp].forEach((chId) {
      final ch = book.chapterMap[chId];
      print("     ${ch.chapterId}\t=> ${ch.title}");
    });
  });
  return book;
}

void main() async {
  final meta = WebsiteMetaData();
  await meta.refresh();
  print(jsonEncode(meta));
  final selector = SelectorMeta(
      filterGroups: meta.comicFilterGroupList.where((grp) => grp.key != 'letter').toList(),
      orders: meta.comicListOrders,
    ).createListSelector();
  print("$selector");

  selector.selectFilter(link: 'japan');
  selector.selectFilter(link: '2012');
  selector.order = 'view';
  selector.page = 2;
  print("$selector");

  final doc = await selector.fetchDom();
  final covers = ComicCover.parseList(doc);
  print("Covers: ${covers.length}");

  // await testBook(ComicBook.fromCover(covers[4]));
  // await testBook(ComicBook('4740')); // 进击的巨人
  final book = await testBook(ComicBook('4125'));
  final ch = book.chapterMap['222478']; // 源君物语
  await ch.refresh();
  print(ch);
}
