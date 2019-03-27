@interface SBDockIconListView : UIView {}
@end

@interface SBDockIconListView (Drawer) {

}

@end

@interface SBUIController (Drawer) {
    UIView* drawerPullView;
}

//New Stuff
- (void)pan:(UIPanGestureRecognizer *)aPan;

// Old Stuff

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

@end

%hook SBDockIconListView

-(void)layoutSubviews {

    NSLog(@"Layout Subviews: SBDockIconListView");
    SBUIController* uiController = [%c(SBUIController) sharedInstance];
    [self addSubview: [uiController pullView]];


    %orig;

}



%end

%hook SBUIController

%new
-(void)setUpPanGesture {
    SBUIController* uiController = [%c(SBUIController) sharedInstance];

    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:uiController action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [drawerPullView addGestureRecognizer:pan];

}

%new
-(UIView*)pullView {
    drawerPullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
    drawerPullView.backgroundColor = [UIColor clearColor];
    [self addSubview:drawerPullView];
    return pullView;
}

%new
- (void)pan:(UIPanGestureRecognizer *)aPan; {
    NSLog(@"Pan");
    CGPoint currentPoint = [aPan locationInView:self.view];

    CGRect fr = t.frame;

    if ((currentPoint.y - fr.origin.y) < 40 && (fr.size.height <= PAN_MAX) )
    {
        float nh = (currentPoint.y >= self.view.frame.size.height - PAN_MAX) ? self.view.frame.size.height-currentPoint.y : PAN_MAX;
        if (nh < PAN_MIN) {
            nh = PAN_MIN;
        }
        [UIView animateWithDuration:0.01f animations:^{
            [t setFrame:CGRectMake(0, self.view.frame.size.height-nh, t.frame.size.width, nh)];
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

%end
