//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <MapKit/MapKit.h>
#import "ProgressHUD.h"
#import "CLLocation+Utils.h"

#import "utilities.h"

#import "MapsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MapsView()
{
	NSMutableArray *users1;
	NSMutableDictionary *users2;
	NSMutableDictionary *userIds;

	CLLocationManager *locationManager;
	CLLocationCoordinate2D coordinate;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MapsView

@synthesize delegate, mapView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Maps";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	mapView.delegate = self;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users1 = [[NSMutableArray alloc] init];
	users2 = [[NSMutableDictionary alloc] init];
	userIds = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self locationManagerStart];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadUsers];
	}
	else LoginUser(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (id annotation in mapView.selectedAnnotations)
	{
		[mapView deselectAnnotation:annotation animated:NO];
	}
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];

	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
	[query1 whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];

	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
	[query2 whereKey:PF_USER_LOCATION nearGeoPoint:geoPoint withinMiles:1.0];
	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users1 removeAllObjects];
			[users2 removeAllObjects];
			[userIds removeAllObjects];
			for (PFUser *user in objects)
			{
				[users1 addObject:user];
				[users2 setObject:user forKey:user.objectId];
			}
			[self createUsers];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[mapView removeAnnotations:mapView.annotations];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *user in users1)
	{
		PFGeoPoint *geoPoint = user[PF_USER_LOCATION];
		CLLocationCoordinate2D coordinateUser = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);

		MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
		annotation.coordinate = coordinateUser;
		annotation.title = user[PF_USER_FULLNAME];

		NSNumber *hash = [NSNumber numberWithUnsignedInteger:annotation.hash];
		userIds[hash] = user.objectId;

		[mapView addAnnotation:annotation];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id<MKAnnotation>)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSNumber *hash = [NSNumber numberWithUnsignedInteger:annotation.hash];
	NSString *userId = userIds[hash];

	MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
	if (pinView == nil) pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];

	pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	pinView.canShowCallout = YES;

	[self loadPicture:pinView UserId:userId];

	return pinView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView_ annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSNumber *hash = [NSNumber numberWithUnsignedInteger:view.annotation.hash];
	NSString *userId = userIds[hash];
	PFUser *user = users2[userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil) [delegate didSelectMapsUser:user];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[mapView deselectAnnotation:view.annotation animated:YES];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadPicture:(MKAnnotationView *)pinView UserId:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	pinView.image = [UIImage imageNamed:@"maps_blank"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = users2[userId];
	[AFDownload start:user[PF_USER_THUMBNAIL] complete:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
			UIImage *resized = ResizeImage(image, 25, 25, 2);
			pinView.image = [self roundedImage:resized withRadious:3.5];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage *)roundedImage:(UIImage *)image withRadious:(CGFloat)radious
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (image == nil) return nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat imageWidth = image.size.width;
	CGFloat imageHeight = image.size.height;

	CGRect rect = CGRectMake(0, 0, imageWidth, imageHeight);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 2.0);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM (context, radious, radious);

	CGFloat rectWidth = CGRectGetWidth (rect)/radious;
	CGFloat rectHeight = CGRectGetHeight (rect)/radious;

	CGContextMoveToPoint(context, rectWidth, rectHeight/2.0f);
	CGContextAddArcToPoint(context, rectWidth, rectHeight, rectWidth/2, rectHeight, radious);
	CGContextAddArcToPoint(context, 0, rectHeight, 0, rectHeight/2, radious);
	CGContextAddArcToPoint(context, 0, 0, rectWidth/2, 0, radious);
	CGContextAddArcToPoint(context, rectWidth, 0, rectWidth, rectHeight/2, radious);
	CGContextRestoreGState(context);
	CGContextClosePath(context);
	CGContextClip(context);

	[image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

#pragma mark - Location manager methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (locationManager == nil)
	{
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager requestWhenInUseAuthorization];
	}
	[locationManager startUpdatingLocation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	coordinate = newLocation.coordinate;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	MKCoordinateRegion region;
	region.center.latitude = coordinate.latitude;
	region.center.longitude = coordinate.longitude;
	region.span.latitudeDelta = 0.01;
	region.span.longitudeDelta = 0.01;
	[mapView setRegion:region animated:YES];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

@end
