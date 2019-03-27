/*
                      _____
    /\               |  __ \
   /  \   _ __  _ __ | |  | |_ __ __ ___      _____ _ __
  / /\ \ | '_ \| '_ \| |  | | '__/ _` \ \ /\ / / _ \ '__|
 / ____ \| |_) | |_) | |__| | | | (_| |\ V  V /  __/ |
/_/    \_\ .__/| .__/|_____/|_|  \__,_| \_/\_/ \___|_|
         | |   | |
         |_|   |_|

Started January 2015
Finally fucking finished this on November 22 2015

S/o to @_mxms for the idea. Which I actually stole from you and Surenix.
Also really proud of myself for getting this to work.

*/
#import <SpringBoard/SpringBoard.h>

#define registerNotification(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce);

#define PREFS_DOMAIN @"com.gmoran.index_prefs"
#define PREFS_CHANGED_NOTIF "com.gmoran.index.prefs-changed"

#define PREFS_FILE_PATH @"/var/mobile/Library/Preferences/com.gmoran.index.plist"

#define DRAWER_ID @"com.gmoran.index"
#define kBundlePath @"/Library/Application Support/AppDrawer/IndexBundle.bundle"

#define APP_SUPPORT_PATH @"/Library/Application Support/AppDrawer"
#define ICON_PREFS_PATH @"/Library/Application Support/AppDrawer/icon.plist"
#define ICON_FOLDER [[NSArray arrayWithContentsOfFile:@"/Library/Application Support/AppDrawer/icon.plist"] objectAtIndex:0]

//Preferences

static BOOL preferencesChanged = NO;

static NSDictionary *prefs = nil;

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

    // reload prefs
    [prefs release];

    //Delete old prefs file

    if ((prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE_PATH]) == nil) {

        //NSLog(@"CREATING PREFERENCE FILE");

        //prefs = @{@"HorizontalScrollingEnabled": @NO};

        [prefs writeToFile:PREFS_FILE_PATH atomically:YES];
        prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE_PATH];

    }

    preferencesChanged = YES;
}

/*
static BOOL verticalScrollingEnabled(void) {
    return (prefs) ? [prefs[@"HorizontalScrollingEnabled"] boolValue] : NO;
}
*/

static BOOL verticalScrollingEnabled = NO;

//Icon Stuffs

@interface SBDrawerIcon : SBLeafIcon
-(id)initWithIdentifier:(NSString *)identifier;

@end

@interface SBIconModel : NSObject {}
-(void)addIcon:(id)icon;
-(void)loadAllIcons;
@end

@interface SBDrawerIconView : SBIconView
@end

@interface SBIconImageView (iOS7)
@property (nonatomic, retain) SBIcon *icon;
@end

@interface SBDrawerIconImageView : SBIconImageView
@end

@interface SBFolderIconBackgroundView : UIView
-(id)initWithDefaultSize;
-(void)setWallpaperRelativeCenter:(CGPoint)wallpaperRelativeCenter;
@end


//SpringBoard Stuffs

@interface SBUIController : NSObject {
    UIView* _contentView;
}
+(id)sharedInstance;
-(id)contentView;
-(void)activateApplicationAnimated:(id)animated;
-(void)activateApplication:(id)application; //iOS 9


@end

@interface SBApplication : NSObject
-(id)bundleIdentifier;
@end

//Party Starts

%subclass SBDrawerIcon : SBLeafIcon

%new
- (id)initWithIdentifier:(NSString *)identifier
{

    if ([self respondsToSelector:@selector(initWithLeafIdentifier:applicationBundleID:)]) {

        self = [self initWithLeafIdentifier:identifier applicationBundleID:identifier];

    }
    else {
        self = [self initWithLeafIdentifier:identifier]; //iOS 6
    }

    return self;
}


- (void)dealloc {
    %orig();
}


- (UIImage *)getGenericIconImage:(int)image {

    NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
    //dlopen("/Library/MobileSubstrate/DynamicLibraries/WinterBoard.dylib", RTLD_NOW);
    //NSBundle* imageBundle = [NSBundle bundleWithIdentifier:@"me.gmoran.appdrawer"];
    NSString *imagePath = [bundle pathForResource:@"DrawerIcon" ofType:@"png"];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];

    [bundle release];
    //[imageBundle release];


    return iconImage;

    /*
    if ([[NSFileManager defaultManager] fileExistsAtPath:ICON_PREFS_PATH]) {

        NSString *imagePath = [NSString stringWithFormat:@"%@/%@/AppDrawer.png", APP_SUPPORT_PATH, ICON_FOLDER];
        UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];
        return iconImage;
    }

    else {
        NSString *imagePath = [NSString stringWithFormat:@"%@/Default Icon/AppDrawer.png", APP_SUPPORT_PATH];
        UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];
        return iconImage;
    }
    */
}

- (UIImage *)generateIconImage:(int)image {

    NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
    //dlopen("/Library/MobileSubstrate/DynamicLibraries/WinterBoard.dylib", RTLD_NOW);
    //NSBundle* imageBundle = [NSBundle bundleWithIdentifier:@"me.gmoran.appdrawer"];
    NSString *imagePath = [bundle pathForResource:@"DrawerIcon" ofType:@"png"];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];

    [bundle release];
    //[imageBundle release];


    return iconImage;

  /*
  if ([[NSFileManager defaultManager] fileExistsAtPath:ICON_PREFS_PATH]) {

      NSString *imagePath = [NSString stringWithFormat:@"%@/%@/AppDrawer.png", APP_SUPPORT_PATH, ICON_FOLDER];
      UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];
      return iconImage;
  }

  else {
      NSString *imagePath = [NSString stringWithFormat:@"%@/Default Icon/AppDrawer.png", APP_SUPPORT_PATH];
      UIImage *iconImage = [UIImage imageWithContentsOfFile:imagePath];
      return iconImage;
  }
  */

}

- (void)launchFromViewSwitcher
{
    SBUIController* uiController = [%c(SBUIController) sharedInstance];
    [uiController openAppDrawer];
}

- (void)launch
{
    SBUIController* uiController = [%c(SBUIController) sharedInstance];
    [uiController openAppDrawer];
}

- (void)launchFromLocation:(int)location
{
    SBUIController* uiController = [%c(SBUIController) sharedInstance];
    [uiController openAppDrawer];
}

//iOS 8.4
- (void)launchFromLocation:(int)location context:(id)context {
    SBUIController* uiController = [%c(SBUIController) sharedInstance];
    [uiController openAppDrawer];
}

- (BOOL)launchEnabled
{
    return YES;
}

- (NSString *)displayName
{
    return @"Apps";
}

- (id)displayNameForLocation:(int)location {
    //This is for iOS 9
    return @"Apps";
}

- (BOOL)canEllipsizeLabel
{
    return NO;
}

- (NSString *)folderFallbackTitle
{
    return @"Index";
}

- (NSString *)applicationBundleID
{
    return DRAWER_ID;
}

-(id)description {
    return @"Application Drawer";
}

- (Class)iconViewClassForLocation:(int)location
{
    return %orig;
}

- (Class)iconImageViewClassForLocation:(int)location
{
    return %orig;
}



%end


%hook SBIconModel

- (void)addIcon:(id)icon {

    NSArray* hiddenApps = [[NSMutableArray alloc] init];

    id allApps = [[%c(SBApplicationController) sharedInstance] allApplications];

    NSMutableDictionary* appsDictionary = [[NSMutableDictionary alloc] init];


    for (SBApplication* app in allApps) {
      //[installedApps addObject: [app bundleIdentifier]];

        BOOL applicationIsHiddenFromSB = [[prefs objectForKey:[@"HiddenSBApps-" stringByAppendingString:[app bundleIdentifier]]] boolValue];

        if (applicationIsHiddenFromSB) {

            @try {
              [appsDictionary setObject:[app displayName] forKey:[app bundleIdentifier]];
            }
            @catch (NSException *e) {
              //fuck you
            }
          }
    }

    NSArray *sortedKeys = [appsDictionary keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];

    hiddenApps = sortedKeys;
    [appsDictionary release];


	   if (![hiddenApps containsObject:[icon leafIdentifier]]) {
		     %orig;
    }
}

- (void)_addNewIconToDesignatedLocation:(id)icon {
  NSArray* hiddenApps = [[NSMutableArray alloc] init];

  id allApps = [[%c(SBApplicationController) sharedInstance] allApplications];

  NSMutableDictionary* appsDictionary = [[NSMutableDictionary alloc] init];


  for (SBApplication* app in allApps) {
      //[installedApps addObject: [app bundleIdentifier]];

      BOOL applicationIsHiddenFromSB = [[prefs objectForKey:[@"HiddenSBApps-" stringByAppendingString:[app bundleIdentifier]]] boolValue];

      if (applicationIsHiddenFromSB) {

          @try {
              [appsDictionary setObject:[app displayName] forKey:[app bundleIdentifier]];
          }
          @catch (NSException *e) {
              //fuck you
          }
      }
  }

  NSArray *sortedKeys = [appsDictionary keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];

  hiddenApps = sortedKeys;
  [appsDictionary release];


	if (![hiddenApps containsObject:[icon leafIdentifier]]) {
		%orig;
  }
}

- (void)dealloc
{
    %orig();
}



- (void)loadAllIcons {

    %orig();

    //NSLog(@"Adding App Drawer to SpringBoard");

    //Load Drawer Icon
    SBDrawerIcon *icon = [[%c(SBDrawerIcon) alloc] initWithIdentifier:DRAWER_ID];
    [self addIcon:icon];
    [icon release];


}

%end

@interface SBUIController (Drawer) {}

-(void)openAppDrawer;
-(void)dismissAppDrawer;
-(void)launchAppFromDrawer:(id)application;

-(void)loadAppDrawer;

-(int)iconColumns;
-(int)iconPadding;
-(int)currentOrientation;

-(void)loadBlurView;
-(void)loadInstalledApps;
-(void)loadAppButtons;
-(void)loadMainDrawerView;
-(void)loadFavoriteApps;

-(UIScrollView*)drawerAppsView;
-(UIScrollView*)favoriteAppsView;

-(UIView*)drawerAppIconWithIdentifier:(id)kek;

-(UIColor*)drawerAppLabelColor;

// Gesture Recognizers
- (void)didSwipe:(UISwipeGestureRecognizer*)swipe;
//2.0
//-(void)setUpDragView;
//-(int)dockHeight;
//-(int)initialDragPosition;

@end

//SBUIController

#define HORIZONTAL_PAGING_ENABLED verticalScrollingEnabled

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_OS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height < 568)

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0)

#define IS_STANDARD_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0)

#define IS_ZOOMED_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 568.0)

#define IS_STANDARD_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 667.0)

static UIView* mainDrawerView = nil;

static UIScrollView* drawerAppsView = nil;
static UIScrollView* favoriteAppsView = nil;

static UIButton* appsTab;
static UIButton* favoritesTab;

static UIView* blurView = nil;

static NSArray* installedApps = nil;
static NSArray* favoriteApps = nil;
static NSMutableArray* appButtons = nil;
static NSMutableArray* favoriteButtons = nil;

static int something = 0;
static int tabIndex = 0;

static BOOL drawerIsShowing = NO;

static int previousOrientation = 0;

//static UIView* dragView = nil;


%hook SBUIController

// Just an idea. Ignore me.

/*
#define PAN_MIN 20
#define PAN_MAX 600
#define INITIAL_POSITION [self initialDragPosition]

%new
-(int)initialDragPosition {
    UIView* uiContentView = [self contentView];
    return (uiContentView.frame.size.height - [self dockHeight]);
}

%new
-(int)dockHeight {
    return 95;
}

%new
-(void)setUpDragView {
    UIView* uiContentView = (UIView*)[self contentView];
    int dockHeight = [self dockHeight];
    dragView = [[UIView alloc] initWithFrame:CGRectMake(0, uiContentView.frame.size.height - dockHeight, uiContentView.frame.size.width, 10)];
    dragView.backgroundColor = [UIColor redColor];
    [uiContentView addSubview:dragView];

    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDrawer:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [dragView addGestureRecognizer:pan];


}



%new
- (void)panDrawer:(UIPanGestureRecognizer *)aPan {
    //NSLog(@"Pan");

    UIView* uiContentView = (UIView*)[self contentView];

    CGPoint currentPoint = [aPan locationInView:uiContentView];

    CGRect fr = dragView.frame;

    if ((currentPoint.y - fr.origin.y) < 40 && (fr.size.height <= PAN_MAX) )
    {
        float nh = (currentPoint.y >= (int)INITIAL_POSITION - PAN_MAX) ? (int)INITIAL_POSITION-currentPoint.y : PAN_MAX;
        if (nh < PAN_MIN) {
            nh = PAN_MIN;
        }
        [UIView animateWithDuration:0.01f animations:^{
            [dragView setFrame:CGRectMake(0, INITIAL_POSITION - nh, dragView.frame.size.width, nh)];
        }];
        if (nh == PAN_MAX) {
            //[t setUserInteractionEnabled:YES];
        }
        else
        {
            //[t setUserInteractionEnabled:NO];
        }
    }

    if(aPan.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Pan Stopped");
    }

}
*/

%new
-(UIColor*)drawerAppLabelColor {
    if (IS_OS_8_OR_LATER) {
        return [UIColor whiteColor];
    }
    else {
        if ([[prefs objectForKey:@"nightModeEnabled"] boolValue] == YES) {
            return [UIColor whiteColor];
        }
        else {
            return [UIColor blackColor];
        }
    }
    return [UIColor whiteColor];
}

%new
-(int)currentOrientation {

    int lel;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown)) {

        lel = 0; //Portait
    }
    else {
        lel= 1; //Landscape
    }

    return lel;
}


%new
-(int)iconPadding {
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return 20;
    }
    if (IS_STANDARD_IPHONE_6) {
        return 25;
    }
    else { //6+
        return 30;
    }
}

%new
-(int)iconColumns {

    if ([self currentOrientation] == 0) {
        return 4;
    }

    return 6; //classic.
}

static int timesDrawerOpened = 0;
%new
- (void)openAppDrawer {

    if (([self currentOrientation] != previousOrientation) || preferencesChanged) {

        [self loadAppDrawer];

        previousOrientation = [self currentOrientation];

        if (preferencesChanged) {
            preferencesChanged = NO;
        }
    }
    timesDrawerOpened++;


    //[self loadAppDrawer];

    //NSLog(@"Opening Drawer");
    UIView* mainView = [self contentView];

    /*
    [mainView addSubview:mainDrawerView];

    [UIView animateWithDuration:0.5 animations:^{

        [mainDrawerView setAlpha:1];

        if (tabIndex == 0) {
            [drawerAppsView setAlpha:1];
            [favoriteAppsView setAlpha:0];
        }
        else {
            [drawerAppsView setAlpha:0];
            [favoriteAppsView setAlpha:1];
        }

        //mainDrawerView.transform = CGAffineTransformMakeScale(1,1);
    }];
    */

    mainDrawerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);

    [mainView addSubview:mainDrawerView];
    [mainDrawerView setAlpha:1];

    if (tabIndex == 0) {
        [drawerAppsView setAlpha:1];
        [favoriteAppsView setAlpha:0];
    }
    else {
        [drawerAppsView setAlpha:0];
        [favoriteAppsView setAlpha:1];
    }

    [UIView animateWithDuration:0.3/1.5 animations:^{
        mainDrawerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2.5 animations:^{
            mainDrawerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.97, 0.97);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2.5 animations:^{
            mainDrawerView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];

    drawerIsShowing = YES;
}

%new
- (void)dismissAppDrawer {

    [UIView animateWithDuration:0.3/1.5 animations:^{

        mainDrawerView.transform = CGAffineTransformMakeScale(0.01,0.01);

        [mainDrawerView setAlpha:0];
        [drawerAppsView setAlpha:0];
        [favoriteAppsView setAlpha:0];

    }];

    drawerIsShowing = NO;

}

%new
-(void)switchTabs:(id)sender {
    if (sender == appsTab) {
        tabIndex = 0;

        [UIView animateWithDuration:0.5 animations:^{
            [drawerAppsView setAlpha:1];
            [favoriteAppsView setAlpha:0];
        }];

        [appsTab setTintColor:[UIColor whiteColor]];
        [favoritesTab setTintColor:[UIColor grayColor]];
    }
    if (sender == favoritesTab) {
        tabIndex = 1;

        [UIView animateWithDuration:0.5 animations:^{
            [drawerAppsView setAlpha:0];
            [favoriteAppsView setAlpha:1];
        }];

        [appsTab setTintColor:[UIColor grayColor]];
        [favoritesTab setTintColor:[UIColor whiteColor]];
    }
}

%new
-(void)loadBlurView {

    if (blurView) {
        //[blurView release];
    }

    UIVisualEffect *blurEffect;

    if ([[prefs objectForKey:@"nightModeEnabled"] boolValue] == YES) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.alpha = 1;

    if ([self currentOrientation] == 0) {
        blurView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
    }
    else {
        blurView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_WIDTH);
    }

}

%new
-(void)loadMainDrawerView {

    mainDrawerView = [[UIView alloc] init];

    UIView* mainView = [self contentView];

    mainDrawerView.frame = CGRectMake(0,0,mainView.bounds.size.width,mainView.bounds.size.height);

    //mainDrawerView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);


    mainDrawerView.alpha = 0;
    //mainDrawerView.transform =CGAffineTransformMakeScale(0,0);

    if (IS_OS_8_OR_LATER) {
        if(![blurView isDescendantOfView:mainDrawerView]) {
            [mainDrawerView addSubview:blurView];
        }

    }
    else {
        if ([[prefs objectForKey:@"nightModeEnabled"] boolValue] == YES) {
            [mainDrawerView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.9]];
        }
        else {
            [mainDrawerView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0]];
        }
    }

    // DRM Stuff

    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/org.thebigboss.appdrawer.list"]) {

        UILabel* label = [[UILabel alloc] init];

        label.text = @"TRIAL VERSION";
        label.font = [UIFont systemFontOfSize:50];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0.6;
        [label setFrame:CGRectMake(0,0,400,90)];
        [label setCenter:CGPointMake(mainDrawerView.frame.size.width / 2, mainDrawerView.frame.size.height / 2)];
        [mainDrawerView addSubview: label];
        [label release];

    }

    // End DRM Stuff

    [mainDrawerView addSubview:drawerAppsView];

    [mainDrawerView addSubview:favoriteAppsView];

    if (tabIndex == 0) {
      [favoriteAppsView setAlpha:0];
      [drawerAppsView setAlpha:1];
    }
    else {
      [favoriteAppsView setAlpha:1];
      [drawerAppsView setAlpha:0];
    }


    if (!HORIZONTAL_PAGING_ENABLED) {
        drawerAppsView.center = CGPointMake(mainDrawerView.center.x, drawerAppsView.center.y);
        favoriteAppsView.center = CGPointMake(mainDrawerView.center.x, drawerAppsView.center.y);
    }

    UIView* separatorView = [[UIView alloc] init];
    [separatorView setFrame:CGRectMake(0,90, SCREEN_WIDTH-20, 3)];
    [separatorView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:163/255.0f blue:235/255.0f alpha:1.0f]];

    [mainDrawerView addSubview:separatorView];
    [separatorView release];

    //////

    appsTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [appsTab addTarget:self action:@selector(switchTabs:) forControlEvents:UIControlEventTouchUpInside];
    [appsTab setTitle:@"Apps" forState:UIControlStateNormal];

    if (tabIndex == 0) {
        [appsTab setTintColor:[UIColor whiteColor]];
    }
    else {
        [appsTab setTintColor:[UIColor grayColor]];
    }

    appsTab.frame = CGRectMake(0.0, 45.0, 70.0, 60.0);
    appsTab.titleLabel.font = [UIFont systemFontOfSize:18];
    [mainDrawerView addSubview:appsTab];

    //////

    favoritesTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [favoritesTab addTarget:self action:@selector(switchTabs:) forControlEvents:UIControlEventTouchUpInside];
    [favoritesTab setTitle:@"Favorites" forState:UIControlStateNormal];

    if (tabIndex == 0) {
        [favoritesTab setTintColor:[UIColor grayColor]];
    }
    else {
        [favoritesTab setTintColor:[UIColor whiteColor]];
    }

    favoritesTab.frame = CGRectMake(80.0, 45.0, 90.0, 60.0);
    favoritesTab.titleLabel.font = [UIFont systemFontOfSize:18];
    [mainDrawerView addSubview:favoritesTab];

    //////

    /*
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Apps";

    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFrame:CGRectMake(0,60,70,30)];

    [mainDrawerView addSubview:titleLabel];
    [titleLabel release];
    */

    //[backgroundView release];


}

#define PADDING [self iconPadding]
#define HORIZONTAL_PADDING PADDING + 5
#define COLUMNS [self iconColumns]
#define LS_COLUMNS 8

#define WIDTH 65
#define HEIGHT 65

#if verticalScrollingEnabled
    #define X 5
    #define Y 0
#else
    #define X 0
    #define Y 0
#endif


#define TOTALBUTTONS [installedApps count]

%new
-(void)loadDrawerAppsView {

    if (drawerAppsView) {
        //[drawerAppsView release];
    }

    drawerAppsView = [[UIScrollView alloc] init];
    [drawerAppsView setShowsHorizontalScrollIndicator:NO];
    [drawerAppsView setShowsVerticalScrollIndicator:NO];
    //mainDrawerView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);

    int viewWidth = ((WIDTH + PADDING) * COLUMNS) - PADDING;
    int viewHeight = SCREEN_HEIGHT;


    if (HORIZONTAL_PAGING_ENABLED) {
        drawerAppsView.frame = CGRectMake(0,100,SCREEN_WIDTH,viewHeight);
    }
    else {
        drawerAppsView.frame = CGRectMake(0,100,viewWidth,viewHeight);
    }


    [drawerAppsView setBackgroundColor:[UIColor clearColor]];
    drawerAppsView.pagingEnabled = NO;


    //unsigned int roundedHeight = 20.5 * [[self installedApps] count];

    int roundedHeight = ((HEIGHT + HORIZONTAL_PADDING + Y) * ([installedApps count] / COLUMNS)) + 95;

    if (([installedApps count] % [self iconColumns]) != 0) {
        roundedHeight = roundedHeight + 95;
    }



    int roundedWidth = ((WIDTH + PADDING) * COLUMNS);


    if (HORIZONTAL_PAGING_ENABLED) {
        [drawerAppsView setContentSize:CGSizeMake(roundedWidth, viewHeight)];
    }
    else {
        [drawerAppsView setContentSize:CGSizeMake(viewWidth, roundedHeight)];
    }



    for (UIButton* appIcon in appButtons) {
        if ([[drawerAppsView subviews] count] <= [appButtons count]) {

            [drawerAppsView addSubview:appIcon];

        }
    }

    drawerAppsView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight);
}

%new
-(void)loadFavoriteAppsView {


    favoriteAppsView = [[UIScrollView alloc] init];
    //mainDrawerView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);

    int viewWidth = ((WIDTH + PADDING) * COLUMNS) - PADDING;
    int viewHeight = SCREEN_HEIGHT;


    if (HORIZONTAL_PAGING_ENABLED) {
        favoriteAppsView.frame = CGRectMake(0,100,SCREEN_WIDTH,viewHeight);
    }
    else {
        favoriteAppsView.frame = CGRectMake(0,100,viewWidth,viewHeight);
    }


    [favoriteAppsView setBackgroundColor:[UIColor clearColor]];
    favoriteAppsView.pagingEnabled = NO;


    //unsigned int roundedHeight = 20.5 * [[self installedApps] count];

    int roundedHeight = ((HEIGHT + HORIZONTAL_PADDING + Y) * ([favoriteApps count] / COLUMNS)) + 95;

    if (([favoriteApps count] % [self iconColumns]) != 0) {
        roundedHeight = roundedHeight + 95;
    }



    int roundedWidth = ((WIDTH + PADDING) * COLUMNS);


    if (HORIZONTAL_PAGING_ENABLED) {
        [favoriteAppsView setContentSize:CGSizeMake(roundedWidth, viewHeight)];
    }
    else {
        [favoriteAppsView setContentSize:CGSizeMake(viewWidth, roundedHeight)];
    }



    for (UIButton* appIcon in favoriteButtons) {
        if ([[favoriteAppsView subviews] count] <= [appButtons count]) {

            [favoriteAppsView addSubview:appIcon];

        }
    }

    favoriteAppsView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight);
}

%new
-(UIView*)drawerAppIconWithIdentifier:(id)kek {

    //NSLog(@"CREATING ICON FOR: %@", kek);

    int buttonsInRow = COLUMNS;

    SBApplication* app;

    if (IS_OS_9_OR_LATER) {
        app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:kek];
    }
    else {
        app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:kek];
    }

    NSString* displayName = [app displayName];

    SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
    UIButton* drawerAppIcon = [UIButton buttonWithType:UIButtonTypeCustom];

    //[drawerAppIcon setFrame:CGRectMake(X+((WIDTH + PADDING) * (something%buttonsInRow)), Y + (HEIGHT + PADDING)*(something/buttonsInRow), WIDTH, HEIGHT)];

    [drawerAppIcon setFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];

    [drawerAppIcon addTarget:self  action:@selector(launchAppFromDrawer:) forControlEvents:UIControlEventTouchUpInside];
    [drawerAppIcon setImage:[icon generateIconImage:2] forState:UIControlStateNormal];
    [drawerAppIcon setTitle:[icon leafIdentifier] forState:UIControlStateNormal];
    [drawerAppIcon setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];


    //Button Container View
    UIView* buttonContainerView = [[UIView alloc] init];
    [buttonContainerView setBackgroundColor:[UIColor clearColor]];

    [buttonContainerView setFrame:CGRectMake(X+((WIDTH + PADDING) * (something%buttonsInRow)), Y + (HEIGHT + HORIZONTAL_PADDING)*(something/buttonsInRow), WIDTH+PADDING, HEIGHT+PADDING)];


    UILabel *displayNameLabel = [[UILabel alloc] init];

    displayNameLabel.text = displayName;
    displayNameLabel.font = [UIFont systemFontOfSize:14];
    displayNameLabel.numberOfLines = 1;
    displayNameLabel.adjustsFontSizeToFitWidth = YES;
    displayNameLabel.backgroundColor = [UIColor clearColor];
    displayNameLabel.textColor = [self drawerAppLabelColor];
    displayNameLabel.textAlignment = NSTextAlignmentCenter;

    [displayNameLabel setFrame:CGRectMake(0, HEIGHT-5, WIDTH, PADDING)];


    [buttonContainerView addSubview:drawerAppIcon];
    [buttonContainerView addSubview:displayNameLabel];



    if ([kek isEqualToString:@"com.apple.mobilecal"]) {


        NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];

        // Get Date
        [dateFormatter setDateFormat:@"dd"];
        NSString* date = [dateFormatter stringFromDate:[NSDate date]];

        UILabel* dateLabel = [[UILabel alloc] init];
        dateLabel.text = date;

        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];

        dateLabel.adjustsFontSizeToFitWidth=YES;
        dateLabel.minimumScaleFactor=0.5;

        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        [dateLabel setFrame:CGRectMake(0,0,WIDTH,HEIGHT-10)];
        dateLabel.center = CGPointMake(drawerAppIcon.center.x, drawerAppIcon.center.y + 4);
        [buttonContainerView addSubview:dateLabel];
        [dateLabel release];

        //Get Day of week
        [dateFormatter setDateFormat:@"EEEE"];
        NSString* dayOfWeek = [dateFormatter stringFromDate:[NSDate date]];

        UILabel* dayLabel = [[UILabel alloc] init];
        dayLabel.text = dayOfWeek;

        dayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];

        dayLabel.adjustsFontSizeToFitWidth=YES;
        dayLabel.minimumScaleFactor=0.5;

        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.textColor = [UIColor redColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        [dayLabel setFrame:CGRectMake(0,0,WIDTH - 7,10)];
        dayLabel.center = CGPointMake(drawerAppIcon.center.x, dayLabel.center.y + 7);
        [buttonContainerView addSubview:dayLabel];
        [dayLabel release];

        [dateFormatter release];

    }

    drawerAppIcon.tag = something + 1;

    [displayNameLabel release];
    //[buttonContainerView release];

    return buttonContainerView;

}

%new
-(void)loadFavoriteButtons {

    something = 0;

    favoriteButtons  = [[NSMutableArray alloc] init];

    for (id kek in favoriteApps) {
        if ([favoriteButtons count] <= [favoriteApps count]) {

            [favoriteButtons addObject:[self drawerAppIconWithIdentifier:kek]];
            something++;

        }
    }
}

%new
-(void)loadAppButtons {

    something = 0;

    appButtons = [[NSMutableArray alloc] init];

    for (id kek in installedApps) {
        if ([appButtons count] <= [installedApps count]) {

            [appButtons addObject:[self drawerAppIconWithIdentifier:kek]];

            something++;
        }
    }
}

%new
-(void)loadInstalledApps {

    if (installedApps) {
        //[installedApps release];
    }

    installedApps = [[NSMutableArray alloc] init];

    id allApps = [[%c(SBApplicationController) sharedInstance] allApplications];

    NSMutableDictionary* appsDictionary = [[NSMutableDictionary alloc] init];


    for (SBApplication* app in allApps) {
        //[installedApps addObject: [app bundleIdentifier]];

        BOOL applicationIsHiddenFromDrawer = [[prefs objectForKey:[@"HiddenApps-" stringByAppendingString:[app bundleIdentifier]]] boolValue];

        if (!applicationIsHiddenFromDrawer) {

            @try {
                [appsDictionary setObject:[app displayName] forKey:[app bundleIdentifier]];
            }
            @catch (NSException *e) {
                //fuck you
            }


        }

    }

    //return installedApps;

    if ([appsDictionary objectForKey:@"com.apple.CompassCalibrationViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.CompassCalibrationViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.mobilesms.compose"]) {
        [appsDictionary removeObjectForKey:@"com.apple.mobilesms.compose"];
    }
    if ([appsDictionary objectForKey:@"com.apple.PhotosViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.PhotosViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.Diagnostics"]) {
        [appsDictionary removeObjectForKey:@"com.apple.Diagnostics"];
    }
    if ([appsDictionary objectForKey:@"com.apple.SharedWebCredentialViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.SharedWebCredentialViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.gamecenter.GameCenterUIService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.gamecenter.GameCenterUIService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI"]) {
        [appsDictionary removeObjectForKey:@"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI"];
    }
    if ([appsDictionary objectForKey:@"com.apple.PassbookUIService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.PassbookUIService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.datadetectors.DDActionsService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.datadetectors.DDActionsService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.iosdiagnostics"]) {
        [appsDictionary removeObjectForKey:@"com.apple.iosdiagnostics"];
    }
    if ([appsDictionary objectForKey:@"com.apple.AccountAuthenticationDialog"]) {
        [appsDictionary removeObjectForKey:@"com.apple.AccountAuthenticationDialog"];
    }
    if ([appsDictionary objectForKey:@"com.apple.WebViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.WebViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.CoreAuthUI"]) {
        [appsDictionary removeObjectForKey:@"com.apple.CoreAuthUI"];
    }
    if ([appsDictionary objectForKey:@"com.apple.TrustMe"]) {
        [appsDictionary removeObjectForKey:@"com.apple.TrustMe"];
    }
    if ([appsDictionary objectForKey:@"com.apple.PreBoard"]) {
        [appsDictionary removeObjectForKey:@"com.apple.PreBoard"];
    }
    if ([appsDictionary objectForKey:@"com.apple.mobileme.fmip1"]) {
        [appsDictionary removeObjectForKey:@"com.apple.mobileme.fmip1"];
    }
    if ([appsDictionary objectForKey:@"com.apple.GameController"]) {
        [appsDictionary removeObjectForKey:@"com.apple.GameController"];
    }
    if ([appsDictionary objectForKey:@"com.apple.ios.StoreKitUIService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.ios.StoreKitUIService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.MusicUIService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.MusicUIService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.SiriViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.SiriViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.share"]) {
        [appsDictionary removeObjectForKey:@"com.apple.share"];
    }
    if ([appsDictionary objectForKey:@"com.apple.DemoApp"]) {
        [appsDictionary removeObjectForKey:@"com.apple.DemoApp"];
    }
    if ([appsDictionary objectForKey:@"com.apple.AdSheetPhone"]) {
        [appsDictionary removeObjectForKey:@"com.apple.AdSheetPhone"];
    }
    if ([appsDictionary objectForKey:@"com.apple.uikit.PrintStatus"]) {
        [appsDictionary removeObjectForKey:@"com.apple.uikit.PrintStatus"];
    }
    if ([appsDictionary objectForKey:@"com.apple.appleaccount.AACredentialRecoveryDialog"]) {
        [appsDictionary removeObjectForKey:@"com.apple.appleaccount.AACredentialRecoveryDialog"];
    }
    if ([appsDictionary objectForKey:@"com.apple.PrintKit.Print-Center"]) {
        [appsDictionary removeObjectForKey:@"com.apple.PrintKit.Print-Center"];
    }
    if ([appsDictionary objectForKey:@"com.apple.mobilesms.notification"]) {
        [appsDictionary removeObjectForKey:@"com.apple.mobilesms.notification"];
    }
    if ([appsDictionary objectForKey:@"com.apple.quicklook.quicklookd"]) {
        [appsDictionary removeObjectForKey:@"com.apple.quicklook.quicklookd"];
    }
    if ([appsDictionary objectForKey:@"com.apple.WebSheet"]) {
        [appsDictionary removeObjectForKey:@"com.apple.WebSheet"];
    }
    if ([appsDictionary objectForKey:@"com.apple.MailCompositionService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.MailCompositionService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.InCallService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.InCallService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.family"]) {
        [appsDictionary removeObjectForKey:@"com.apple.family"];
    }
    if ([appsDictionary objectForKey:@"com.apple.TencentWeiboAccountMigrationDialog"]) {
        [appsDictionary removeObjectForKey:@"com.apple.TencentWeiboAccountMigrationDialog"];
    }
    if ([appsDictionary objectForKey:@"com.apple.AskPermissionUI"]) {
        [appsDictionary removeObjectForKey:@"com.apple.AskPermissionUI"];
    }
    if ([appsDictionary objectForKey:@"com.apple.iad.iAdOptOut"]) {
        [appsDictionary removeObjectForKey:@"com.apple.iad.iAdOptOut"];
    }
    if ([appsDictionary objectForKey:@"com.apple.CompassCalibrationViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.CompassCalibrationViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.HealthPrivacyService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.HealthPrivacyService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.webapp1"]) {
        [appsDictionary removeObjectForKey:@"com.apple.webapp1"];
    }
    if ([appsDictionary objectForKey:@"com.apple.webapp"]) {
        [appsDictionary removeObjectForKey:@"com.apple.webapp"];
    }
    if ([appsDictionary objectForKey:@"com.apple.fieldtest"]) {
        [appsDictionary removeObjectForKey:@"com.apple.fieldtest"];
    }
    if ([appsDictionary objectForKey:@"com.apple.FacebookAccountMigrationDialog"]) {
        [appsDictionary removeObjectForKey:@"com.apple.FacebookAccountMigrationDialog"];
    }
    if ([appsDictionary objectForKey:@"com.apple.purplebuddy"]) {
        [appsDictionary removeObjectForKey:@"com.apple.purplebuddy"];
    }
    if ([appsDictionary objectForKey:@"com.apple.MobileReplayer"]) {
        [appsDictionary removeObjectForKey:@"com.apple.MobileReplayer"];
    }
    if ([appsDictionary objectForKey:@"com.apple.Diagnostics.Mitosis"]) {
        [appsDictionary removeObjectForKey:@"com.apple.Diagnostics.Mitosis"];
    }
    if ([appsDictionary objectForKey:@"com.apple.CloudKit.ShareBear"]) {
        [appsDictionary removeObjectForKey:@"com.apple.CloudKit.ShareBear"];
    }
    if ([appsDictionary objectForKey:@"com.apple.SafariViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.SafariViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.ServerDocuments"]) {
        [appsDictionary removeObjectForKey:@"com.apple.ServerDocuments"];
    }
    if ([appsDictionary objectForKey:@"com.apple.social.SLGoogleAuth"]) {
        [appsDictionary removeObjectForKey:@"com.apple.social.SLGoogleAuth"];
    }
    if ([appsDictionary objectForKey:@"com.apple.social.SLYahooAuth"]) {
        [appsDictionary removeObjectForKey:@"com.apple.social.SLYahooAuth"];
    }
    if ([appsDictionary objectForKey:@"com.apple.StoreDemoViewService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.StoreDemoViewService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.Home.HomeUIService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.Home.HomeUIService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.managedconfiguration.MDMRemoteAlertService"]) {
        [appsDictionary removeObjectForKey:@"com.apple.managedconfiguration.MDMRemoteAlertService"];
    }
    if ([appsDictionary objectForKey:@"com.apple.DataActivation"]) {
        [appsDictionary removeObjectForKey:@"com.apple.DataActivation"];
    }

    // Call Bar
    if ([appsDictionary objectForKey:@"net.limneos.callbarviewservice"]) {
        [appsDictionary removeObjectForKey:@"net.limneos.callbarviewservice"];
    }

    NSArray *sortedKeys = [appsDictionary keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];

    installedApps = sortedKeys;
    [appsDictionary release];

    //NSLog(@"THE FUCKING KEYS: %@", installedApps);

    //[installedApps sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

}

%new
-(void)loadFavoriteApps {

    if (favoriteApps) {
        //[installedApps release];
    }

    favoriteApps = [[NSMutableArray alloc] init];

    id allApps = [[%c(SBApplicationController) sharedInstance] allApplications];

    NSMutableDictionary* appsDictionary = [[NSMutableDictionary alloc] init];


    for (SBApplication* app in allApps) {
        //[installedApps addObject: [app bundleIdentifier]];

        BOOL applicationIsFavorite = [[prefs objectForKey:[@"FavoriteApps-" stringByAppendingString:[app bundleIdentifier]]] boolValue];

        if (applicationIsFavorite) {

            @try {
                [appsDictionary setObject:[app displayName] forKey:[app bundleIdentifier]];
            }
            @catch (NSException *e) {
                //fuck you
            }


        }

    }

    NSArray *sortedKeys = [appsDictionary keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];

    favoriteApps = sortedKeys;
    [appsDictionary release];
    //NSLog(@"THE FUCKING KEYS: %@", installedApps);

    //[installedApps sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

}

%new
-(void)launchAppFromDrawer:(id)application {

    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/org.thebigboss.appdrawer.list"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ahoy, Matey!"
                                                message:@"Creating tweaks takes time and effort. Please support your developers by purchasing AppDrawer on the Cydia Store, or contact @fr0st to make arrangements. \n\nThanks!"
                                                delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

    SBApplication* app;

    if (IS_OS_9_OR_LATER) {
        app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[application titleLabel].text];
    }
    else {
        app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:[application titleLabel].text];
    }



    [self dismissAppDrawer];

    if (IS_OS_9_OR_LATER) {
        [self activateApplication:app];
    }
    else {
        [self activateApplicationAnimated:app];
    }


}

%new
-(void)loadAppDrawer {

    something = 0;

    if (blurView != nil) {
        blurView = nil;
        [blurView release];
    }

    if (IS_OS_8_OR_LATER) {
        [self loadBlurView];
    }

    /////////////////////////////////////////

    if (favoriteApps != nil) {
      favoriteApps = nil;
      [favoriteApps release];
    }

    [self loadFavoriteApps];

    /////////////////////////////////////////

    if (installedApps != nil) {
        installedApps = nil;
        [installedApps release];
    }

    [self loadInstalledApps];

    /////////////////////////////////////////

    if (appButtons != nil) {
        appButtons = nil;
        [appButtons release];
    }
    [self loadAppButtons];

    /////////////////////////////////////////

    if (favoriteButtons != nil) {
        favoriteButtons = nil;
        [favoriteButtons release];
    }
    [self loadFavoriteButtons];

    /////////////////////////////////////////

    if (drawerAppsView != nil) {
        drawerAppsView = nil;
        [drawerAppsView release];
    }
    [self loadDrawerAppsView];

    /////////////////////////////////////////

    if (favoriteAppsView != nil) {
        favoriteAppsView = nil;
        [favoriteAppsView release];
    }
    [self loadFavoriteAppsView];

    /////////////////////////////////////////

    if (mainDrawerView != nil) {
        mainDrawerView = nil;
        [mainDrawerView release];
    }
    [self loadMainDrawerView];

    ////////////////////////////////////////
    // Set Up Gesture Recognizers
    ////////////////////////////////////////

    // Swipe Left for favorites view
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [drawerAppsView addGestureRecognizer:swipeLeft];

    // Swipe Right for All Apps View
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [favoriteAppsView addGestureRecognizer:swipeRight];

}

%new
- (void)didSwipe:(UISwipeGestureRecognizer*)swipe {

    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) { //Show Favorites (left to right)

        tabIndex = 1;

        [UIView animateWithDuration:0.5 animations:^{
            [drawerAppsView setAlpha:0];
            [favoriteAppsView setAlpha:1];
        }];



        [appsTab setTintColor:[UIColor lightGrayColor]];
        [favoritesTab setTintColor:[UIColor whiteColor]];
    }
    else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) { //Show All Apps (right to left)

        tabIndex = 0;

        [UIView animateWithDuration:0.5 animations:^{
            [drawerAppsView setAlpha:1];
            [favoriteAppsView setAlpha:0];
        }];


        [appsTab setTintColor:[UIColor whiteColor]];
        [favoritesTab setTintColor:[UIColor lightGrayColor]];
    }
}

//iOS 9
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {

    %orig;
    //NSLog(@"Setting Orientation: %i", arg1);

    if (arg3 == 1) {
        previousOrientation = 0;
    }
    else {
        previousOrientation = 1;
    }

    [self dismissAppDrawer];

}

//iOS 8
-(void)window:(id)arg1 didRotateFromInterfaceOrientation:(long long)arg2 {

    %orig;
    //NSLog(@"Setting Orientation: %i", arg1);

    if (arg2 == 1) {
        previousOrientation = 0;
    }
    else {
        previousOrientation = 1;
    }

    [self dismissAppDrawer];

}

-(BOOL)clickedMenuButton {

    BOOL homeButton = %orig;

    if (drawerIsShowing) {
        [self dismissAppDrawer];

        return nil;
    }

    return homeButton;
}

//iOS 7+
-(void)finishLaunching {
    //load everything

    [self loadAppDrawer];
    //[self setUpDragView];
    %orig;
}

//iOS 6
- (void)finishedUnscattering {
    //load everything

    [self loadAppDrawer];
    %orig;
}

-(void)dealloc {

  if (blurView != nil) {
      blurView = nil;
      [blurView release];
  }
  /////////////////////////////////////////
  if (favoriteApps != nil) {
    favoriteApps = nil;
    [favoriteApps release];
  }
  /////////////////////////////////////////
  if (installedApps != nil) {
      installedApps = nil;
      [installedApps release];
  }
  /////////////////////////////////////////
  if (appButtons != nil) {
      appButtons = nil;
      [appButtons release];
  }
  /////////////////////////////////////////
  if (favoriteButtons != nil) {
      favoriteButtons = nil;
      [favoriteButtons release];
  }
  /////////////////////////////////////////
  if (drawerAppsView != nil) {
      drawerAppsView = nil;
      [drawerAppsView release];
  }
  /////////////////////////////////////////
  if (favoriteAppsView != nil) {
      favoriteAppsView = nil;
      [favoriteAppsView release];
  }
  /////////////////////////////////////////
  if (mainDrawerView != nil) {
      mainDrawerView = nil;
      [mainDrawerView release];
  }

    %orig;
}

%end

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    prefsChanged(NULL, NULL, NULL, NULL, NULL);
    registerNotification(prefsChanged, PREFS_CHANGED_NOTIF);

    //dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
    //[[objc_getClass("ISIconSupport") sharedInstance] addExtension:@"com.gmoran.index"];

    [pool release];
}
