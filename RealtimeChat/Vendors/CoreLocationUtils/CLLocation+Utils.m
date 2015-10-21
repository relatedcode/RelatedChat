//
//  CLLocation+Utils.m
//  CLLocationUtils
//
//  Created by Fernando Sproviero on 10/07/13.
//  Source code based on http://www.movable-type.co.uk/scripts/latlong.html
//  Copyright (c) 2013 Fernando Sproviero. All rights reserved.
//

#import "CLLocation+Utils.h"
#import <math.h>

static const NSInteger R = 6371000;

@implementation CLLocation (Utils)

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

double degreesToRadians(double degrees)
{
    return degrees / 180 * M_PI;
}

double radiansToDegrees(double radians)
{
    return radians * 180 / M_PI;
}

- (CLLocationRadianCoordinate2D)radianCoordinate {
    CLLocationRadianCoordinate2D radCoord;
    radCoord.latitude = degreesToRadians(self.coordinate.latitude);
    radCoord.longitude = degreesToRadians(self.coordinate.longitude);
    return radCoord;
}

- (id)initWithRadianLatitude:(double)latitude radianLongitude:(double)longitude
{
    return [self initWithLatitude:radiansToDegrees(latitude) longitude:radiansToDegrees(longitude)];
}

- (double)extractCoordinateFromString:(NSString *)str {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@" °'\""]];
    double operands[3];
    char c = [str characterAtIndex:str.length - 1];
    
    [scanner scanDouble:&operands[0]];
    [scanner scanDouble:&operands[1]];
    [scanner scanDouble:&operands[2]];
    
    double result = operands[0] + operands[1] / 60 + operands[2] / 3600;
    if (c == 'N' || c == 'E')
        return result;

    return -result;
}

- (id)initWithPrettyLatitude:(NSString *)latitude prettyLongitude:(NSString *)longitude
{
    NSPredicate *pLat = [NSPredicate predicateWithFormat:@" SELF MATCHES %@", @"\\d+° \\d+\' \\d+\" [NS]"];
    NSPredicate *pLon = [NSPredicate predicateWithFormat:@" SELF MATCHES %@", @"\\d+° \\d+\' \\d+\" [EW]"];
    
    if ( [pLat evaluateWithObject:latitude] && [pLon evaluateWithObject:longitude] ) {
        double lat = [self extractCoordinateFromString:latitude];
        double lon = [self extractCoordinateFromString:longitude];
        return [self initWithLatitude:lat longitude:lon];
    }
    return nil;
}

- (NSString *)prettyLatitude
{
    int latSeconds = (int)round(fabs(self.coordinate.latitude * 3600));
    int latDegrees = latSeconds / 3600;
    latSeconds = latSeconds % 3600;
    int latMinutes = latSeconds / 60;
    latSeconds %= 60;
    
    char latDirection = (self.coordinate.latitude >= 0) ? 'N' : 'S';
    
    return [NSString stringWithFormat:@"%02i° %02i' %02i\" %c", latDegrees, latMinutes, latSeconds, latDirection];
}

- (NSString *)prettyLongitude
{    
    int longSeconds = (int)round(fabs(self.coordinate.longitude * 3600));
    int longDegrees = longSeconds / 3600;
    longSeconds = longSeconds % 3600;
    int longMinutes = longSeconds / 60;
    longSeconds %= 60;
    
    char longDirection = (self.coordinate.longitude >= 0) ? 'E' : 'W';
    
    return [NSString stringWithFormat:@"%02i° %02i' %02i\" %c", longDegrees, longMinutes, longSeconds, longDirection];
}

- (CLLocationDistance)haversineDistanceFromLocation:(const CLLocation *)location
{
    double dLat = degreesToRadians(location.coordinate.latitude - self.coordinate.latitude);
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lat2 = degreesToRadians(location.coordinate.latitude);
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
}

- (CLLocationDistance)sphericalLawOfCosDistanceFromLocation:(const CLLocation *)location
{
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lat2 = degreesToRadians(location.coordinate.latitude);
    return acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(dLon)) * R;
}

- (CLLocationDistance)pythagorasEquirectangularDistanceFromLocation:(const CLLocation *)location
{
    double dLat = degreesToRadians(location.coordinate.latitude - self.coordinate.latitude);
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double sLat = degreesToRadians(location.coordinate.latitude + self.coordinate.latitude);
    double x = dLon * cos(sLat/2);
    return sqrt(x*x + dLat*dLat) * R;
}

- (double)pythagorasDistanceFromLocation:(const CLLocation *)location
{
    double dLat = location.coordinate.latitude - self.coordinate.latitude;
    double dLon = location.coordinate.longitude - self.coordinate.longitude;
    return sqrt(dLon*dLon + dLat*dLat);
}

- (CLLocation *)midpointWithLocation:(const CLLocation *)location
{
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lat2 = degreesToRadians(location.coordinate.latitude);
    double lon1 = degreesToRadians(self.coordinate.longitude);
    
    double Bx = cos(lat2) * cos(dLon);
    double By = cos(lat2) * sin(dLon);
    double lat3 = atan2(sin(lat1) + sin(lat2), sqrt( (cos(lat1)+Bx) * (cos(lat1)+Bx) + By*By ) );
    double lon3 = lon1 + atan2(By, cos(lat1) + Bx);
    
    return [[CLLocation alloc] initWithRadianLatitude:lat3 radianLongitude:lon3];
}

- (double)initialBearingToLocation:(const CLLocation *)location
{
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lat2 = degreesToRadians(location.coordinate.latitude);
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double brng = radiansToDegrees( atan2(y, x) );
    return fmod(brng + 360, 360);
}

- (double)finalBearingToLocation:(const CLLocation *)location
{
    double dLon = degreesToRadians(self.coordinate.longitude - location.coordinate.longitude);
    double lat2 = degreesToRadians(self.coordinate.latitude);
    double lat1 = degreesToRadians(location.coordinate.latitude);
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double brng = radiansToDegrees( atan2(y, x) );
    return fmod(brng + 180, 360);
}

- (CLLocation *)destinationLocationWithInitialBearing:(double)bearing distance:(CLLocationDistance)distance {
    double angularDistance = distance/R;
    double brng = degreesToRadians(bearing);
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lon1 = degreesToRadians(self.coordinate.longitude);
    
    double lat2 = asin( sin(lat1) * cos(angularDistance) +
                        cos(lat1) * sin(angularDistance) * cos(brng) );
    double lon2 = lon1 + atan2( sin(brng) * sin(angularDistance) * cos(lat1),
                                cos(angularDistance) - sin(lat1) * sin(lat2) );
    lon2 = fmod( lon2 + 3 * M_PI, 2 * M_PI ) - M_PI;  // normalise to -180..+180º
    
    return [[CLLocation alloc] initWithRadianLatitude:lat2 radianLongitude:lon2];
}

- (CLLocation *)pythagorasDestinationLocationWithInitialBearing:(double)bearing pythagorasDistance:(double)distance {
    double lon1 = distance * sin(degreesToRadians(bearing)) + self.coordinate.longitude;
    double lat1 = distance * cos(degreesToRadians(bearing)) + self.coordinate.latitude;
    return [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
}

- (double)angleWithLocation:(const CLLocation *)location
{
    double lat1 = degreesToRadians(self.coordinate.latitude);
    double lat2 = degreesToRadians(location.coordinate.latitude);
    double lon1 = degreesToRadians(self.coordinate.longitude);
    double lon2 = degreesToRadians(location.coordinate.longitude);
    
    double theta = atan2(lon2 - lon1, lat2 - lat1);
    
    double angle = radiansToDegrees( theta );
    
    // convert to positive range [0-360)
    // since we want to prevent negative angles, adjust them now.
    // we can assume that atan2 will not return a negative value
    // greater than one partial rotation
    if (angle < 0) {
        angle += 360;
    }
    return angle;
}

+ (BOOL)angle:(double)angle betweenAngle:(double)angle0 andAngle:(double)angle1
{
    double n = fmod(360 + (fmod(angle,360)),360);
    double a = fmod((3600000 + angle0), 360);
    double b = fmod((3600000 + angle1), 360);
    
    if (a < b)
        return a <= n && n <= b;
    
    return a <= n || n <= b;
}

- (CLLocation *)intersectionWithSelfBearing:(double)bearing1 toLocation:(const CLLocation *)location bearing:(double)bearing2
{
    double lat1 = self.radianCoordinate.latitude;
    double lon1 = self.radianCoordinate.longitude;
    double lat2 = location.radianCoordinate.latitude;
    double lon2 = location.radianCoordinate.longitude;
    double brng13 = degreesToRadians(bearing1);
    double brng23 = degreesToRadians(bearing2);
    double dLat = lat2-lat1;
    double dLon = lon2-lon1;
    
    double dist12 = 2*asin( sqrt( sin(dLat/2)*sin(dLat/2) +
                                    cos(lat1)*cos(lat2)*sin(dLon/2)*sin(dLon/2) ) );
    if (dist12 == 0) return nil;
    
    // initial/final bearings between points
    double brngA = acos( ( sin(lat2) - sin(lat1)*cos(dist12) ) /
                      ( sin(dist12)*cos(lat1) ) );
    if (isnan(brngA)) brngA = 0;  // protect against rounding
    double brngB = acos( ( sin(lat1) - sin(lat2)*cos(dist12) ) /
                      ( sin(dist12)*cos(lat2) ) );
    
    double brng12, brng21;
    if (sin(lon2-lon1) > 0) {
        brng12 = brngA;
        brng21 = 2*M_PI - brngB;
    } else {
        brng12 = 2*M_PI - brngA;
        brng21 = brngB;
    }
    
    double alpha1 = fmod(brng13 - brng12 + M_PI, 2*M_PI) - M_PI;  // angle 2-1-3
    double alpha2 = fmod(brng21 - brng23 + M_PI, 2*M_PI) - M_PI;  // angle 1-2-3
    
    if (sin(alpha1)==0 && sin(alpha2)==0) return nil;  // infinite intersections
    if (sin(alpha1)*sin(alpha2) < 0) return nil;       // ambiguous intersection
    
    //alpha1 = fabs(alpha1);
    //alpha2 = fabs(alpha2);
    // ... Ed Williams takes abs of alpha1/alpha2, but seems to break calculation?
    
    double alpha3 = acos( -cos(alpha1)*cos(alpha2) +
                       sin(alpha1)*sin(alpha2)*cos(dist12) );
    double dist13 = atan2( sin(dist12)*sin(alpha1)*sin(alpha2),
                          cos(alpha2)+cos(alpha1)*cos(alpha3) );
    double lat3 = asin( sin(lat1)*cos(dist13) +
                     cos(lat1)*sin(dist13)*cos(brng13) );
    double dLon13 = atan2( sin(brng13)*sin(dist13)*cos(lat1),
                        cos(dist13)-sin(lat1)*sin(lat3) );
    double lon3 = lon1+dLon13;
    lon3 = fmod(lon3+3*M_PI, 2*M_PI) - M_PI;  // normalise to -180..+180º
    
    return [[CLLocation alloc] initWithRadianLatitude:lat3 radianLongitude:lon3];
}

- (CLLocationDistance)rhumbDistanceFromLocation:(const CLLocation *)location
{
    double dLat = degreesToRadians(location.coordinate.latitude - self.coordinate.latitude);
    double dLon = degreesToRadians(fabs(location.coordinate.longitude - self.coordinate.longitude));
    double lat1 = self.radianCoordinate.latitude;
    double lat2 = location.radianCoordinate.latitude;
    
    double dPhi = log(tan(lat2/2+M_PI_4)/tan(lat1/2+M_PI_4));
    double q = (isfinite(dLat/dPhi)) ? dLat/dPhi : cos(lat1);  // E-W line gives dPhi=0
    
    // if dLon over 180° take shorter rhumb across anti-meridian:
    if (fabs(dLon) > M_PI) {
        dLon = dLon>0 ? -(2*M_PI-dLon) : (2*M_PI+dLon);
    }
    
    return sqrt(dLat*dLat + q*q*dLon*dLon) * R;
}

- (double)rhumbBearingToLocation:(const CLLocation *)location
{
    double dLon = degreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
    double lat1 = self.radianCoordinate.latitude;
    double lat2 = location.radianCoordinate.latitude;

    double dPhi = log(tan(lat2/2+M_PI_4)/tan(lat1/2+M_PI_4));
    if (fabs(dLon) > M_PI) dLon = dLon>0 ? -(2*M_PI-dLon) : (2*M_PI+dLon);
    double brng = atan2(dLon, dPhi);
    
    return fmod(radiansToDegrees(brng)+360, 360);
}

- (CLLocation *)rhumbDestinationLocationWithBearing:(double)bearing distance:(CLLocationDistance)distance {
    double d = distance/R;  // d = angular distance covered on earth’s surface
    double lat1 = self.radianCoordinate.latitude;
    double lon1 = self.radianCoordinate.longitude;
    double brng = degreesToRadians(bearing);
    
    double dLat = d*cos(brng);
    // nasty kludge to overcome ill-conditioned results around parallels of latitude:
    if (fabs(dLat) < 1e-10) dLat = 0; // dLat < 1 mm
    
    double lat2 = lat1 + dLat;
    double dPhi = log(tan(lat2/2+M_PI_4)/tan(lat1/2+M_PI_4));
    double q = (isfinite(dLat/dPhi)) ? dLat/dPhi : cos(lat1);  // E-W line gives dPhi=0
    double dLon = d*sin(brng)/q;
    
    // check for some daft bugger going past the pole, normalise latitude if so
    if (fabs(lat2) > M_PI_2) lat2 = lat2>0 ? M_PI-lat2 : -M_PI-lat2;
    
    double lon2 = fmod(lon1+dLon+3*M_PI, 2*M_PI) - M_PI;
    
    return [[CLLocation alloc] initWithRadianLatitude:lat2 radianLongitude:lon2];
}

- (CLLocation *)rhumbMidpointWithLocation:(const CLLocation *)location
{
    double lat1 = self.radianCoordinate.latitude;
    double lon1 = self.radianCoordinate.longitude;
    double lat2 = location.radianCoordinate.latitude;
    double lon2 = location.radianCoordinate.longitude;

    if (fabs(lon2-lon1) > M_PI) lon1 += 2*M_PI; // crossing anti-meridian
    
    double lat3 = (lat1+lat2)/2;
    double f1 = tan(M_PI_4 + lat1/2);
    double f2 = tan(M_PI_4 + lat2/2);
    double f3 = tan(M_PI_4 + lat3/2);
    double lon3 = ( (lon2-lon1)*log(f3) + lon1*log(f2) - lon2*log(f1) ) / log(f2/f1);
    
    if (!isfinite(lon3)) lon3 = (lon1+lon2)/2; // parallel of latitude
    
    lon3 = fmod(lon3+3*M_PI, 2*M_PI) - M_PI;  // normalise to -180..+180º
    
    return [[CLLocation alloc] initWithRadianLatitude:lat3 radianLongitude:lon3];
}

@end
