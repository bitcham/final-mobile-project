import 'package:movie_rating/models/cast_member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CastMember', () {
    test('parses cast member data from JSON', () {
      final castMember = CastMember.fromJson({
        'id': 'elias-thorne',
        'name': 'Elias Thorne',
        'roleName': 'Kaelen',
      });

      expect(castMember.id, 'elias-thorne');
      expect(castMember.name, 'Elias Thorne');
      expect(castMember.roleName, 'Kaelen');
    });

    test('serializes to the movies.json cast key shape', () {
      const castMember = CastMember(
        id: 'elias-thorne',
        name: 'Elias Thorne',
        roleName: 'Kaelen',
      );

      expect(castMember.toJson(), {
        'id': 'elias-thorne',
        'name': 'Elias Thorne',
        'roleName': 'Kaelen',
      });
    });

    test('defaults missing values to empty strings', () {
      final castMember = CastMember.fromJson({});

      expect(castMember.id, '');
      expect(castMember.name, '');
      expect(castMember.roleName, '');
    });
  });
}
