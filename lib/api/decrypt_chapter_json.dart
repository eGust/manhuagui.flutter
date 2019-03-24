import 'dart:math';

/*
window["\x65\x76\x61\x6c"](function(p,a,c,k,e,d){e=function(c){return(c<a?"":e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)d[e(c)]=k[c]||e(c);k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1;};while(c--)if(k[c])p=p.replace(RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p;}('c.r({"q":4,"t":"s","n":"4.0","m":p,"o":"5","z":["y.0.2","B.0.2","A.0.2","v.0.2","u.0.2","x.0.2","w.0.2","l.0.2","d.0.2","8.0.2","9.0.2","a.0.2","i.0.2","k.0.2","b.0.2","f.0.2","h.0.2","e.0.2","%3%j%6%3%7%C%3%6%W.0.2","%V%Y%7%3%X%S%R%U%T%13%14%12.0.2"],"Z":10,"11":H,"I":"/J/g/G/5/","D":1,"E":"","F":O,"P":Q,"N":{"K":"L"}}).M();',62,67,'FYBw5gPhDuCmBGIIFECsECMBOATANgGYJAabxwBZA9tQgEEB2CAIQAYIBNagVQAUB9AawD2AVwDOACwCGfITyblZGJgGMBAWyTtu/YeKky5ZBRhXq2nXoNGTps+Uww4TG89qt7bh+6icQAygFkACTMtS10bA1kmLB9NCx1rfTsMAA5YlzDEjwU8HxD4twjk2nTQhPdI+wIfajJ813CkzwwyUoLG7KYmNLUkJQBLABMIRH6lCCUAOwlVWAgCHHt8EaGIftUwABEJABcJCEAbRUBWJ0BhZUBFxMAQt0BGJ0BfTRHp2frMirsmb16n8qLPJlaPuIaWUqTBK/wyXyaUVyYLKhUhXWMHwAZv0ADawESfOGdJjVGHtIGvRwfFIAMQgIj2O1EI1RAiUfB4SnGk1gAA8dgBJYZgYAAR2AgwkYh4GwgiwgIF2YklIjqqkG6HgwCwCNQqAwBAA0psmAB1DUAeVQ/iYvmgkoATrBOZN+jsKaj5jhULQCFgrbAAG7c+YYWioAj0ZB1ahEagsBgAYRQeAgqpoyHjcZRdvEsGGSIkqJEc3Rk0Y6GQHuoGCAA=='['\x73\x70\x6c\x69\x63']('\x7c'),0,{}))
*/

final reWord = RegExp(r'\b\w+\b');

String decryptChapterData(String zippedJson, int base, String lzTable) {
  final dictTable =
      lzDecompressFromBase64(lzTable).split('|').asMap().map((index, value) {
    final str = int2str(index, base);
    return MapEntry(str, value.isEmpty ? str : value);
  });
  return zippedJson.replaceAllMapped(reWord, (m) => dictTable[m[0]]);
}

String lzDecompressFromBase64(String source) =>
    _lzDecompress(source.split('').map((c) => _b64[c]).toList(), 32);

String int2str(int number, int base) {
  final chars = <String>[];
  do {
    var c = number % base;
    if (c < 10) {
      // 0..9
      c += 48;
    } else if (c < 36) {
      // a..z
      c += 87;
    } else {
      // A..Z
      c += 29;
    }
    chars.add(String.fromCharCode(c));
    number ~/= base;
  } while (number > 0);
  return chars.reversed.join('');
}

// logic translated from: https://github.com/pieroxy/lz-string

final _b64Base =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        .split('')
        .asMap();
final _b64 = Map.fromIterables(_b64Base.values, _b64Base.keys);

String _lzDecompress(List<int> source, int resetValue) {
  final size = source.length;
  final dictionary = <String>['', '', ''];
  final result = <String>[];

  int power = 1;
  int maxPower = 4;
  int enlargeIn = 4;
  int dictSize = 4;
  int numBits = 3;
  int bits = 0;
  int res = 0;
  int i;

  String entry;
  String w;
  String c;

  int index = 1;
  int val = source[0];
  int position = resetValue;

  while (power != maxPower) {
    res = val & position;
    position >>= 1;
    if (position == 0) {
      position = resetValue;
      val = source[index++];
    }
    bits |= (res > 0 ? 1 : 0) * power;
    power <<= 1;
  }

  switch (bits) {
    case 0:
      {
        bits = 0;
        maxPower = 256;
        power = 1;
        while (power != maxPower) {
          res = val & position;
          position >>= 1;
          if (position == 0) {
            position = resetValue;
            val = source[index++];
          }
          bits |= (res > 0 ? 1 : 0) * power;
          power <<= 1;
        }
        c = String.fromCharCode(bits);
        break;
      }
    case 1:
      {
        bits = 0;
        maxPower = 65536;
        power = 1;
        while (power != maxPower) {
          res = val & position;
          position >>= 1;
          if (position == 0) {
            position = resetValue;
            val = source[index++];
          }
          bits |= (res > 0 ? 1 : 0) * power;
          power <<= 1;
        }
        c = String.fromCharCode(bits);
        break;
      }
    case 2:
      return "";
  }

  dictionary.add(c);
  w = c;
  result.add(c);

  while (true) {
    if (index > size) return "";

    bits = 0;
    maxPower = pow(2, numBits);
    power = 1;
    while (power != maxPower) {
      res = val & position;
      position >>= 1;
      if (position == 0) {
        position = resetValue;
        val = source[index++];
      }
      bits |= (res > 0 ? 1 : 0) * power;
      power <<= 1;
    }

    switch (i = bits) {
      case 0:
        bits = 0;
        maxPower = 256;
        power = 1;
        while (power != maxPower) {
          res = val & position;
          position >>= 1;
          if (position == 0) {
            position = resetValue;
            val = source[index++];
          }
          bits |= (res > 0 ? 1 : 0) * power;
          power <<= 1;
        }

        dictionary.add(String.fromCharCode(bits));
        i = dictSize++;
        enlargeIn--;
        break;
      case 1:
        bits = 0;
        maxPower = 65536;
        power = 1;
        while (power != maxPower) {
          res = val & position;
          position >>= 1;
          if (position == 0) {
            position = resetValue;
            val = source[index++];
          }
          bits |= (res > 0 ? 1 : 0) * power;
          power <<= 1;
        }
        dictionary.add(String.fromCharCode(bits));
        i = dictSize++;
        enlargeIn--;
        break;
      case 2:
        return result.join('');
    }

    if (enlargeIn == 0) {
      enlargeIn = pow(2, numBits);
      numBits++;
    }

    if (i > 0 && i < dictSize) {
      entry = dictionary[i];
    } else {
      if (i == dictSize) {
        entry = w + w[0];
      } else {
        return null;
      }
    }
    result.add(entry);

    dictionary.add(w + entry[0]);
    dictSize++;
    enlargeIn--;

    w = entry;

    if (enlargeIn == 0) {
      enlargeIn = pow(2, numBits);
      numBits++;
    }
  }
}
