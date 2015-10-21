//
//  CLLocation+Utils.h
//  CLLocationUtils
//
//  Created by Fernando Sproviero on 10/07/13.
//  Source code based on http://www.movable-type.co.uk/scripts/latlong.html
//  Copyright (c) 2013 Fernando Sproviero. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/*
 *  CLLocationRadianCoordinate2D
 *
 *  Discussion:
 *    A structure that contains a geographical coordinate.
 *
 *  Fields:
 *    latitude:
 *      The latitude in radians.
 *    longitude:
 *      The longitude in radians.
 */
typedef struct {
	double latitude;
	double longitude;
} CLLocationRadianCoordinate2D;

@interface CLLocation (Utils)
/*
 *  initWithCoordinate2D:coordinate
 *
 *  Discussion:
 *    Initialize with a CLLocationCoordinate2D struct only.
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/*
 *  initWithRadianLatitude:radianLongitude
 *
 *  Discussion:
 *    Initialize with the specified latitude and longitude in radians.
 */
- (id)initWithRadianLatitude:(double)latitude radianLongitude:(double)longitude;

/*
 *  initWithPrettyLatitude:prettyLongitude
 *
 *  Discussion:
 *    Initialize with the specified pretty latitude and pretty longitude.
 *    e.g. latitude = @"34° 36' 12\" N" longitude = @"34° 36' 12\" W" 
 */
- (id)initWithPrettyLatitude:(NSString *)latitude prettyLongitude:(NSString *)longitude;

/*
 *  prettyLatitude:
 *
 *  Discussion:
 *    Returns the latitude coordinate in a pretty format.
 *    e.g. 34° 36' 12" S
 */
- (NSString *)prettyLatitude;

/*
 *  prettyLongitude:
 *
 *  Discussion:
 *    Returns the longitude coordinate in a pretty format.
 *    e.g. 58° 22' 54" W
 */
- (NSString *)prettyLongitude;

/*
 *  radianCoordinate
 *
 *  Discussion:
 *    Returns the coordinate of the current location in radians.
 */
- (CLLocationRadianCoordinate2D)radianCoordinate;

/*
 *  haversineDistanceFromLocation:
 *
 *  Discussion:
 *    Returns the distance (in meters) between two locations using the Haversine formula.
 *
 *    from: Haversine formula - R. W. Sinnott, "Virtues of the Haversine",
 *                              Sky and Telescope, vol 68, no 2, 1984
 */
- (CLLocationDistance)haversineDistanceFromLocation:(const CLLocation *)location;

/*
 *  sphericalLawOfCosDistanceFromLocation:
 *
 *  Discussion:
 *    Returns the distance (in meters) between two locations using the Spherical Law of cosines formula.
 */
- (CLLocationDistance)sphericalLawOfCosDistanceFromLocation:(const CLLocation *)location;

/*
 *  pythagorasDistanceFromLocation:
 *
 *  Discussion:
 *    Returns the distance (in coordinate units) between two locations using the Pythagoras formula.
 */
- (double)pythagorasDistanceFromLocation:(const CLLocation *)location;

/*
 *  pythagorasEquirectangularDistanceFromLocation:
 *
 *  Discussion:
 *    Returns the distance (in meters) between two locations using the Pythagoras formula (equirectangular projection)
 */
- (CLLocationDistance)pythagorasEquirectangularDistanceFromLocation:(const CLLocation *)location;

/*
 *  midpointWithLocation:
 *
 *  Discussion:
 *    Returns the half-way location along a great circle path between two locations.
 *
 *    see http://mathforum.org/library/drmath/view/51822.html for derivation
 */
- (CLLocation *)midpointWithLocation:(const CLLocation *)location;

/*
 *  initialBearingToLocation:
 *
 *  Discussion:
 *    Returns the (initial) bearing from this location to the supplied location.
 *
 *    see http://williams.best.vwh.net/avform.htm#Crs
 */
- (double)initialBearingToLocation:(const CLLocation *)location;

/*
 *  finalBearingToLocation:
 *
 *  Discussion:
 *    Returns final bearing arriving at supplied location from this location; the final bearing
 *    will differ from the initial bearing by varying degrees according to distance and latitude.
 */
- (double)finalBearingToLocation:(const CLLocation *)location;

/*
 *  destinationLocationWithInitialBearing:distance
 *
 *  Discussion:
 *     Returns the destination location from this location having travelled the given distance (in meters) on the
 *     given initial bearing in degrees (bearing may vary before destination is reached).
 *
 *     see http://williams.best.vwh.net/avform.htm#LL
 */
- (CLLocation *)destinationLocationWithInitialBearing:(double)bearing distance:(CLLocationDistance)distance;

/*
 *  pythagorasDestinationLocationWithInitialBearing:pythagorasDistance
 *
 *  Discussion:
 *     Returns the destination location from this location having travelled the given distance (in coordinate units) on the
 *     given initial bearing in degrees.
 */
- (CLLocation *)pythagorasDestinationLocationWithInitialBearing:(double)bearing pythagorasDistance:(double)distance;

/*
 *  intersectionWithSelfBearing:toLocation:bearing:
 *
 *  Discussion:
 *    Returns the point of intersection of two paths defined by point and bearing.
 *
 *    see http://williams.best.vwh.net/avform.htm#Intersection
 */
- (CLLocation *)intersectionWithSelfBearing:(double)bearing1 toLocation:(const CLLocation *)location bearing:(double)bearing2;

/*
 *  rhumbDistanceFromLocation:
 *
 *  Discussion:
 *    Returns the distance (in meters) from this point to the supplied location, travelling along a rhumb line.
 *
 *   see http://williams.best.vwh.net/avform.htm#Rhumb
 */
- (CLLocationDistance)rhumbDistanceFromLocation:(const CLLocation *)location;

/*
 *  rhumbBearingToLocation:
 *
 *  Discussion:
 *    Returns the bearing from this location to the supplied location along a rhumb line, in degrees.
 */
- (double)rhumbBearingToLocation:(const CLLocation *)location;

/*
 *  rhumbDestinationLocationWithBearing:distance:
 *  
 *  Discussion:
 *    Returns the destination location from this location having travelled the given distance on the
 *    given bearing along a rhumb line.
 */
- (CLLocation *)rhumbDestinationLocationWithBearing:(double)bearing distance:(CLLocationDistance)distance;

/*
 *  rhumbMidpointWithLocation:
 *
 *  Discussion:
 *    Returns the loxodromic midpoint (along a rhumb line) between this location and the supplied location.
 *
 *    see http://mathforum.org/kb/message.jspa?messageID=148837
 */
- (CLLocation *)rhumbMidpointWithLocation:(const CLLocation *)location;

/*
 *  angleWithLocation:
 *
 *  Discussion:
 *    Returns the angle between two locations of a mercator projection (plain map)
 *    North is reference (0 degrees) and angle is clockwise (between 0 and 360).
 */
- (double)angleWithLocation:(const CLLocation *)location;

/*
 *  angle:betweenAngle:andAngle
 *
 *  Discussion:
 *    Utility method that returns TRUE if the angle is between angle0 and angle1
 *    or FALSE in other case.
 */
+ (BOOL)angle:(double)angle betweenAngle:(double)angle0 andAngle:(double)angle1;

@end
