import 'package:flame/components.dart';
import 'package:flame/geometry.dart' as geometry;
import 'package:flame/src/geometry/circle.dart';
import 'package:flame/src/geometry/line_segment.dart';
import 'package:flame/src/geometry/line.dart';
import 'package:test/test.dart';

void main() {
  group('LineSegment.isPointOnSegment tests', () {
    test('Can catch simple point', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0.5);
      assert(segment.containsPoint(point), "Point should be on segment");
    });

    test('Should not catch point outside of segment, but on line', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(3);
      assert(!segment.containsPoint(point), "Point should not be on segment");
    });

    test('Should not catch point outside of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2(3, 2);
      assert(!segment.containsPoint(point), "Point should not be on segment");
    });

    test('Point on end of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(1);
      assert(segment.containsPoint(point), "Point should be on segment");
    });

    test('Point on beginning of segment', () {
      final segment = LineSegment(
        Vector2.all(0),
        Vector2.all(1),
      );
      final point = Vector2.all(0);
      assert(segment.containsPoint(point), "Point should be on segment");
    });
  });

  group('LineSegment.intersections tests', () {
    test('Simple intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 0));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('No intersection', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2(0, 1), Vector2(1, 2));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isEmpty, "Should not have any intersection");
    });

    test('Same line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2.all(1));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0.5, 0.5)");
      assert(intersection.first == Vector2.all(0.5));
    });

    test('Overlapping line segments', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0.5), Vector2.all(1.5));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should intersect at (0.75, 0.75)");
      assert(intersection.first == Vector2.all(0.75));
    });

    test('One pixel overlap in different angles', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(0), Vector2(1, -1));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (0, 0)");
      assert(intersection.first == Vector2.all(0));
    });

    test('One pixel parallel overlap in same angle', () {
      final segmentA = LineSegment(Vector2.all(0), Vector2.all(1));
      final segmentB = LineSegment(Vector2.all(1), Vector2.all(2));
      final intersection = segmentA.intersections(segmentB);
      assert(intersection.isNotEmpty, "Should have intersection at (1, 1)");
      assert(intersection.first == Vector2.all(1));
    });
  });

  group('Line.intersections tests', () {
    test('Simple line intersection', () {
      const line1 = const Line(1, -1, 0);
      const line2 = const Line(1, 1, 0);
      final intersection = line1.intersections(line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2.all(0));
    });

    test('Lines with c value', () {
      const line1 = const Line(1, 1, 1);
      const line2 = const Line(1, -1, 1);
      final intersection = line1.intersections(line2);
      assert(intersection.isNotEmpty, 'Should have intersection');
      assert(intersection.first == Vector2(1, 0));
    });

    test('Does not catch parallel lines', () {
      const line1 = const Line(1, 1, -3);
      const line2 = const Line(1, 1, 6);
      final intersection = line1.intersections(line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });

    test('Does not catch same line', () {
      const line1 = const Line(1, 1, 1);
      const line2 = const Line(1, 1, 1);
      final intersection = line1.intersections(line2);
      assert(intersection.isEmpty, 'Should not have intersection');
    });
  });

  group('LinearEquation.fromPoints tests', () {
    test('Simple line from points', () {
      final line = Line.fromPoints(Vector2.zero(), Vector2.all(1));
      assert(line.a == 1.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == 0.0, "c value is not correct");
    });

    test('Line not going through origo', () {
      final line = Line.fromPoints(Vector2(-2, 0), Vector2(0, 2));
      assert(line.a == 2.0, "a value is not correct");
      assert(line.b == -2.0, "b value is not correct");
      assert(line.c == -4.0, "c value is not correct");
    });

    test('Straight vertical line', () {
      final line = Line.fromPoints(Vector2.all(1), Vector2(1, -1));
      assert(line.a == -2.0, "a value is not correct");
      assert(line.b == 0.0, "b value is not correct");
      assert(line.c == -2.0, "c value is not correct");
    });

    test('Straight horizontal line', () {
      final line = Line.fromPoints(Vector2.all(1), Vector2(2, 1));
      assert(line.a == 0.0, "a value is not correct");
      assert(line.b == -1.0, "b value is not correct");
      assert(line.c == -1.0, "c value is not correct");
    });
  });

  group('LineSegment.pointsAt tests', () {
    test('Simple pointing', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });

    test('Is not pointed at when crossed', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(3));
      const line = const Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(!isPointingAt, 'Line should not be pointed at');
    });

    test('Is not pointed at when parallel', () {
      final segment = LineSegment(Vector2.zero(), Vector2(1, -1));
      const line = const Line(1, 1, 3);
      final isPointingAt = segment.pointsAt(line);
      assert(!isPointingAt, 'Line should not be pointed at');
    });

    test('Horizonal line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const Line(0, 1, 2);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });

    test('Vertical line can be pointed at', () {
      final segment = LineSegment(Vector2.zero(), Vector2.all(1));
      const line = const Line(1, 0, 2);
      final isPointingAt = segment.pointsAt(line);
      assert(isPointingAt, 'Line should be pointed at');
    });
  });

  group('Polygon intersections tests', () {
    test('Simple polygon collision', () {
      final polygonA = Polygon([
        Vector2(2, 2),
        Vector2(3, 1),
        Vector2(2, 0),
        Vector2(1, 1),
      ]);
      final polygonB = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      assert(
        intersections.contains(Vector2(1.5, 0.5)),
        "Missed one intersection",
      );
      assert(
        intersections.contains(Vector2(1.5, 1.5)),
        "Missed one intersection",
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });

    test('Collision on shared line segment', () {
      final polygonA = Polygon([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = Polygon([
        Vector2(2, 1),
        Vector2(2, 2),
        Vector2(3, 2),
        Vector2(3, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      assert(
          intersections.containsAll([
            Vector2(2.0, 2.0),
            Vector2(2.0, 1.5),
            Vector2(2.0, 1.0),
          ]),
          "Does not have all the correct intersection points");
      assert(intersections.length == 3, "Wrong number of intersections");
    });

    test('One point collision', () {
      final polygonA = Polygon([
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(2, 2),
        Vector2(2, 1),
      ]);
      final polygonB = Polygon([
        Vector2(2, 2),
        Vector2(2, 3),
        Vector2(3, 3),
        Vector2(3, 2),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      assert(
        intersections.contains(Vector2(2.0, 2.0)),
        "Does not have all the correct intersection points",
      );
      assert(intersections.length == 1, "Wrong number of intersections");
    });

    test('Collision while no corners are inside the other body', () {
      final polygonA = Polygon.fromDefinition(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        size: Vector2(2, 4),
      );
      final polygonB = Polygon.fromDefinition(
        [
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
          Vector2(-1, 1),
        ],
        position: Vector2.zero(),
        size: Vector2(4, 2),
      );
      final intersections = geometry.intersections(polygonA, polygonB);
      assert(
        intersections.containsAll([
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, 1),
          Vector2(-1, -1),
        ]),
        "Does not have all the correct intersection points",
      );
      assert(intersections.length == 4, "Wrong number of intersections");
    });

    test('Collision with advanced hitboxes in different quadrants', () {
      final polygonA = Polygon([
        Vector2(0, 0),
        Vector2(-1, 1),
        Vector2(0, 3),
        Vector2(2, 2),
        Vector2(1.5, 0.5),
      ]);
      final polygonB = Polygon([
        Vector2(-2, -2),
        Vector2(-3, 0),
        Vector2(-2, 3),
        Vector2(1, 2),
        Vector2(2, 1),
      ]);
      final intersections = geometry.intersections(polygonA, polygonB);
      intersections.containsAll([
        Vector2(-0.2857142857142857, 2.4285714285714284),
        Vector2(1.7500000000000002, 1.2500000000000002),
        Vector2(1.5555555555555556, 0.6666666666666667),
        Vector2(1.1999999999999997, 0.39999999999999997),
      ]);
      assert(intersections.length == 4, "Wrong number of intersections");
    });
  });

  group('Rectangle intersections tests', () {
    test('Simple intersection', () {
      final rectangleA = Rectangle(
        position: Vector2(4, 0),
        size: Vector2.all(4),
      );
      final rectangleB = Rectangle(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(rectangleA, rectangleB);
      assert(
        intersections.containsAll([
          Vector2(2, -2),
          Vector2(2, 0),
          Vector2(2, 2),
        ]),
        "Missed intersections",
      );
      assert(intersections.length == 3, "Wrong number of intersections");
    });
  });

  group('Circle intersections tests', () {
    test('Simple collision', () {
      final circleA = Circle.fromDefinition(
        position: Vector2(4, 0),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      assert(
        intersections.contains(Vector2(2, 0)),
        "Missed one intersection",
      );
      assert(intersections.length == 1, "Wrong number of intersections");
    });

    test('Two point collision', () {
      final circleA = Circle.fromDefinition(
        position: Vector2(3, 0),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      assert(
        intersections.contains(Vector2(1.5, -1.3228756555322954)),
        "Missed one intersection",
      );
      assert(
        intersections.contains(Vector2(1.5, 1.3228756555322954)),
        "Missed one intersection",
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });

    test('Same size and position', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      assert(
        intersections.containsAll([
          Vector2(5, 3),
          Vector2(3, 5),
          Vector2(3, 1),
          Vector2(1, 3),
        ]),
        "Missed intersections",
      );
      assert(intersections.length == 4, "Wrong number of intersections");
    });

    test('Not overlapping', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(3),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB);
      assert(intersections.isEmpty, "Should not have any intersections");
    });

    test('In third quadrant', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(2),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(-2),
        size: Vector2.all(2),
      );
      final intersections = geometry.intersections(circleA, circleB).toList();
      assert(
        intersections.any((v) => v.distanceTo(Vector2(-1, -2)) < 0.000001),
      );
      assert(
        intersections.any((v) => v.distanceTo(Vector2(-2, -1)) < 0.000001),
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });

    test('In different quadrants', () {
      final circleA = Circle.fromDefinition(
        position: Vector2.all(-1),
        size: Vector2.all(4),
      );
      final circleB = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(4),
      );
      final intersections = geometry.intersections(circleA, circleB).toList();
      assert(
        intersections.any((v) => v.distanceTo(Vector2(1, -1)) < 0.000001),
      );
      assert(
        intersections.any((v) => v.distanceTo(Vector2(-1, 1)) < 0.000001),
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });
  });

  group('Circle-Polygon intersections tests', () {
    test('Simple circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2.zero(),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      assert(
        intersections.containsAll([Vector2(0, 1), Vector2(1, 0)]),
        "Missed intersections",
      );
      assert(intersections.length == 2, "Wrong number of intersections");
    });

    test('Single point circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2(-1, 1),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      assert(
        intersections.contains(Vector2(0, 1)),
        "Missed intersections",
      );
      assert(intersections.length == 1, "Wrong number of intersections");
    });

    test('Four point circle-polygon intersection', () {
      final circle = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(2),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      assert(
        intersections.containsAll([
          Vector2(1, 2),
          Vector2(2, 1),
          Vector2(1, 0),
          Vector2(0, 1),
        ]),
        "Missed intersections",
      );
      assert(intersections.length == 4, "Wrong number of intersections");
    });

    test('Polygon within circle, no intersections', () {
      final circle = Circle.fromDefinition(
        position: Vector2.all(1),
        size: Vector2.all(2.1),
      );
      final polygon = Polygon([
        Vector2(1, 2),
        Vector2(2, 1),
        Vector2(1, 0),
        Vector2(0, 1),
      ]);
      final intersections = geometry.intersections(circle, polygon);
      assert(intersections.isEmpty, "Should not be any intersections");
    });
  });
}
