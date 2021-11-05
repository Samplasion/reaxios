// ignore_for_file: lines_longer_than_80_chars
library reaxios;

class Encrypter {
  static var rc4Base = [111, 225, 122, 187, 8, 19, 15, 189, 152, 26, 32, 44, 39, 100, 249, 218, 71, 93, 75, 88, 1, 165, 239, 160, 240, 129, 29, 30, 200, 0, 3, 184, 230, 91, 174, 46, 156, 49, 78, 56, 211, 98, 248, 41, 163, 197, 50, 106, 232, 61, 115, 214, 109, 158, 68, 231, 202, 149, 178, 180, 244, 62, 148, 7, 228, 45, 83, 171, 12, 136, 206, 169, 22, 168, 87, 175, 144, 145, 188, 216, 81, 123, 210, 90, 74, 47, 86, 17, 107, 127, 92, 40, 82, 99, 226, 167, 181, 125, 227, 128, 220, 118, 241, 117, 205, 25, 182, 132, 34, 242, 65, 14, 170, 247, 213, 73, 143, 69, 252, 96, 80, 250, 166, 155, 138, 27, 70, 204, 172, 5, 219, 120, 2, 103, 104, 31, 21, 113, 243, 235, 142, 229, 161, 185, 209, 23, 59, 139, 159, 157, 208, 221, 18, 20, 95, 55, 101, 173, 234, 151, 154, 137, 124, 53, 112, 77, 72, 233, 186, 198, 192, 179, 133, 162, 102, 194, 60, 114, 190, 237, 76, 4, 135, 43, 201, 191, 10, 105, 236, 212, 110, 16, 176, 245, 195, 28, 215, 79, 203, 67, 126, 251, 66, 97, 199, 94, 255, 36, 33, 64, 134, 38, 196, 224, 54, 37, 217, 116, 140, 84, 89, 11, 130, 52, 141, 223, 57, 150, 58, 253, 9, 147, 246, 85, 119, 131, 183, 108, 13, 51, 6, 63, 222, 146, 24, 153, 238, 193, 35, 164, 48, 121, 207, 42, 177, 254];

  static final List<int> base64DecodeChars = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1];
  static final String b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  static List<int> getRC4() {
    return [...Encrypter.rc4Base];
  }

  static var key = "ppepsflssc05102017";

  /// Ciphers and deciphers using RC4
  ///
  /// rc4(rc4("hello")) == "hello"
  ///
  /// @param data stringa da codificare/decodificare
  /// Return la stringa codificata/decodificata
  static _rc4(String data) {
    var rc4 = Encrypter.getRC4();
    var length = data.length;
    int i = 0;
    int j = 0;
    int x;
    List<String> c = new List.filled(length, "");
    for (var y = 0; y < length; y++) {
      i = (i + 1) % 256;
      j = (j + rc4[i]) % 256;
      x = rc4[i];
      rc4[i] = rc4[j];
      rc4[j] = x;
      c[y] = String.fromCharCode(data.codeUnitAt(y) ^ rc4[(rc4[i] + rc4[j]) % 256]);
    }
    return c.join("");
  }

  // static _encodeURIComponent(str: string) {
  //     return str.replaceAll("\\+", "%20")
  //         .replaceAll("%21", "!")
  //         .replaceAll("%27", "'")
  //         .replaceAll("%28", "(")
  //         .replaceAll("%29", ")")
  //         .replaceAll("%7E", "~");
  // }

  /// Base64 to ASCII
  static String _atob(String str) {
    int c1, c2, c3, c4, i = 0, len = str.length;
    String out = "";
    while (i < len) {
      do {
        c1 = base64DecodeChars[codepoint(str, i++) & 0xff];
      } while (i < len && c1 == -1);
      if (c1 == -1) break;
      do {
        c2 = base64DecodeChars[codepoint(str, i++) & 0xff];
      } while (i < len && c2 == -1);
      if (c2 == -1) break;
      out += String.fromCharCode((c1 << 2) | ((c2 & 0x30) >> 4));
      do {
        c3 = codepoint(str, i++) & 0xff;
        if (c3 == 61) return out.toString();
        c3 = base64DecodeChars[c3];
      } while (i < len && c3 == -1);
      if (c3 == -1) break;
      out += String.fromCharCode(((c2 & 0XF) << 4) | ((c3 & 0x3C) >> 2));
      do {
        c4 = codepoint(str, i++) & 0xff;
        if (c4 == 61) return out.toString();
        c4 = base64DecodeChars[c4];
      } while (i < len && c4 == -1);
      if (c4 == -1) break;
      out += String.fromCharCode(((c3 & 0x03) << 6) | c4);
    }
    return out.toString();
  }

  /// ASCII to Base64
  static String _btoa(String string) {
    int bitmap;
    int a;
    int b;
    int c;
    String result = "";
    int i = 0;
    int stringLen = string.length;
    int rest = stringLen % 3;
    while (i < stringLen) {
      if ((a = codepoint(string, i++)) > 255 || (b = codepoint(string, i++)) > 255 || (c = codepoint(string, i++)) > 255) return "";
      bitmap = (a << 16) | (b << 8) | c;
      result += (b64[bitmap >> 18 & 63]) + (b64[bitmap >> 12 & 63]) + (b64[bitmap >> 6 & 63]) + (b64[bitmap & 63]);
    }
    return rest != 0 ? result.substring(0, result.length - (rest - 3).abs()) + "===".substring(rest) : result.toString();
  }

  static int codepoint(String str, int index) {
    if (index < 0 || index >= str.length) return 0;
    return str.codeUnitAt(index);
  }

  /// Decripta i dati ricevuti dai server Axios
  /// All'interno della stringa codificata ci sono delle virgolette (") all'inizio e alla fine che devono essere ignorate
  ///
  /// decrypt(encrypt("ciao")) == "ciao"
  ///
  static String decrypt(String input) {
    final uriDecoded = Uri.decodeComponent(input.replaceAll('"', '')).replaceAll('\\/', '/');
    final ascii = Encrypter._atob(uriDecoded);
    final rc4d = Encrypter._rc4(ascii);
    return rc4d;
  }

  /// Cripta i dati per essere inviati ai server Axios
  static String encrypt(String input) {
    // if (!input)
    //     throw new Error("Must pass input to Encrypter.encrypt()")
    return Uri.encodeComponent(Encrypter._btoa(Encrypter._rc4(input)));
  }

  /// Cripta i dati per essere inviati ai server Axios in POST
  static String encryptPost(String input) {
    return Encrypter._btoa(Encrypter._rc4(input));
  }
}
