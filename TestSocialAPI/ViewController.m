//
//  ViewController.m
//  TestSocialAPI
//
//  Created by ryuzmukhametov on 22/07/16.
//  Copyright © 2016 Rustam Yuzmukhametov. All rights reserved.
//

#import "ViewController.h"
#import <VKSdk.h>
#import "AppDelegate.h"

#define kAppID @"5557468"

@interface ViewController ()<VKSdkDelegate, VKSdkUIDelegate>
@property (nonatomic, strong) VKSdk *vkSdkInstance;
@property (nonatomic, strong) NSArray *scope;
@property (nonatomic, strong) NSArray *friends;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    VKSdk *vkSdkInstance = [VKSdk initializeWithAppId:kAppID] ;
    [vkSdkInstance registerDelegate:self];
    [vkSdkInstance setUiDelegate:self];
    self.vkSdkInstance = vkSdkInstance;
    
    NSArray *scope = @[@"email", @"friends", @"photos"];
    self.scope = scope;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

#pragma mark - VKSdkDelegate
- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    
    NSLog(@"%@", result.token.email); // self loadUsers
    self.emailLabel.text = result.token.email;
    [self loadUsers];
}

- (void)vkSdkUserAuthorizationFailed {
    NSLog(@"error");
}

#pragma mark - VKSdkUIDelegate
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    
}

- (void)vkSdkWillDismissViewController:(UIViewController *)controller
{
    NSLog(@"vkSdkWillDismissViewController");
}

- (void)vkSdkDidDismissViewController:(UIViewController *)controller
{
    NSLog(@"vkSdkDidDismissViewController");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *dict = self.friends[indexPath.row];
    NSString *firstName = dict[@"first_name"];
    NSString *lastName = dict[@"last_name"];
    NSString *friendId = dict[@"id"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", firstName, lastName, friendId];
    return cell;
}

#pragma mark - Aux
- (void) loadUsers {
    VKRequest *vkUsers = [[VKApi users] get:@{@"fields":@"photo_100,city,verified"}];
    [vkUsers executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Json result: %@", response.json);
        [self updateUIwithVKResponse:response];
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

//
// https://new.vk.com/dev/users
// https://new.vk.com/dev/friends

- (void)loadFriends {
    VKRequest *vkFriends = [[VKApi friends] get:@{@"count":@1000, @"fields":@"nickname"}];
    [vkFriends executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Json result: %@", response.json);
        [self updateUIwithFriendsVKResponse:response];
        //[self updateUIwithVKResponse:response];
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

- (void)updateUIwithFriendsVKResponse:(VKResponse*)vkResponse {
    if (![vkResponse.json isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray *arr = vkResponse.json[@"items"];
    self.friends = arr;
    [self.tableView reloadData];
}

- (void)updateUIwithVKResponse:(VKResponse*)vkResponse {
    if (![vkResponse.json isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *arr = vkResponse.json;
    if (arr.count == 0) {
        return;
    }
    NSDictionary *json = vkResponse.json[0];
    NSString *firstName = json[@"first_name"];
    NSString *lastName = json[@"last_name"];
    NSString *vkId = json[@"id"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", firstName, lastName, vkId];
    NSString *photoURL = json[@"photo_100"];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: photoURL]];
        if (data == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData: data];
        });
        
    });
    
    //    "" = "https://pp.vk.me/c608617/v608617231/1fc1/scUkukVtuN8.jpg";
    //    verified = 0;
}


#pragma mark - IBActions
- (IBAction)loadVKInfoAction:(id)sender {
    [VKSdk wakeUpSession:self.scope completeBlock:^(VKAuthorizationState state, NSError *err) {
        if (state == VKAuthorizationAuthorized) {
            // authorized
            [self loadUsers];
        } else {
            // auth needed
            [VKSdk authorize:self.scope];
        }
    }];
    
    
}

- (IBAction)loadFBInfoAction:(id)sender {
}

- (IBAction)showVKFriendsAction:(id)sender {
    //[self performSegueWithIdentifier:@"ShowFriends" sender:self];
    [self loadFriends];
}

- (IBAction)showFBFriendsAction:(id)sender {
    //[self performSegueWithIdentifier:@"ShowFriends" sender:self];
}
@end
