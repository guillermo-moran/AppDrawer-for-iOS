#import <Preferences/Preferences.h>
#import <Preferences/Preferences.h>
#import <UIKit/UITableViewCell+Private.h>

@interface indexprefsListController: PSListController {
}
@end

@implementation indexprefsListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"indexprefs" target:self] retain];
	}
	return _specifiers;
}

-(void)visitWebsite {
    NSString *url = @"http://gmoran.me/";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)twitter {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=fr0st"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=fr0st"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/fr0st"]];
    }
}

-(void)email {
    NSString *url = @"mailto:guillermo@gmoran.me?&subject=AppDrawer%20Support";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)respring {
    system("killall -9 SpringBoard");
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && [cell respondsToSelector:@selector(_setDrawsSeparatorAtTopOfSection:)]) {
        cell._drawsSeparatorAtTopOfSection = NO;
        cell._drawsSeparatorAtBottomOfSection = NO;
    }
}


@end

// vim:ft=objc
