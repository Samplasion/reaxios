import 'package:flutter_test/flutter_test.dart';
import 'package:reaxios/utils/utils.dart';

void main() {
  group("generateAbbreviation", () {
    test(
      'should generate an abbreviation',
      () {
        expect(Utils.generateAbbreviation(3, "Arte"), "ART");
      },
    );
    test(
      'should generate an abbreviation ignoring words',
      () {
        expect(
          Utils.generateAbbreviation(
            3,
            "Disegno e storia dell'arte",
            ignoreList: ["disegno", "e", "storia", "dell'", "dell"],
          ),
          "ART",
        );
      },
    );
    test(
      'should generate an abbreviation anyways if the whole string only contains ignored words',
      () {
        expect(
            Utils.generateAbbreviation(
              3,
              "Storia del disegno",
              ignoreList: ["storia", "del", "disegno"],
            ),
            "SDD");
      },
    );
  });
}
