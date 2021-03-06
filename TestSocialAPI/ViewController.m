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
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKShareKit/FBSDKAppInviteContent.h>
#import <FBSDKShareKit/FBSDKAppInviteDialog.h>

#define kAppID @"put_your_own_app_id"

@interface ViewController ()<VKSdkDelegate, VKSdkUIDelegate>
@property (nonatomic, strong) NSArray *friends;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSString *name = dict[@"name"];
    NSString *photo = dict[@"photo_100"];
    
    if (name.length == 0) {
        name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", name, friendId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}


#pragma mark - Aux
- (void) loadUsers {
    VKRequest *vkUsers = [[VKApi users] get:@{@"fields":@"photo_100,city,verified,sex"}];
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


- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"results = %@", results);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)sendFBMessage {
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://link"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://link"];
    
    // Present the dialog. Assumes self is a view controller
    // which implements the protocol `FBSDKAppInviteDialogDelegate`.
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    
}

- (void)sendVKMessage {
        VKRequest *vkSendMessage = [VKRequest requestWithMethod:@"messages.send" parameters:@{@"user_id":@111, @"message":@"test message"}];
    __weak typeof(self) weakSelf = self;
    [vkSendMessage executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Json result: %@", response.json);
        //[weakSelf processLoadVKFriendsResultByResponse:response];
    } errorBlock:^(NSError * error) {
        NSLog(@"%@", error);
        //[weakSelf processResultByError:error];
    }];

}

- (void)loadFriends {
    VKRequest *vkFriends = [[VKApi friends] get:@{@"count":@1000, @"fields":@"nickname,photo_50"}];
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

- (void)loadPhotoByURL:(NSString*)photoURL {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: photoURL]];
        if (data == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData: data];
        });
    });
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
    NSNumber *sex = json[@"sex"]; // 1 - female, 2 - male
    NSString *gender = sex.integerValue == 1 ? @"femail" : @"male";
    self.nameLabel.text = [NSString stringWithFormat:@"VK: %@ %@ (%@) %@", firstName, lastName, vkId, gender];
    NSString *photoURL = json[@"photo_100"];
    
    [self loadPhotoByURL:photoURL];
}

- (void)loadUsersFromFB {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,email,name,gender,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self updateUIwithFBResponse:result];
            }
        }];
    }
}

- (void)loadFriendsFromFB {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:@{ @"fields" : @"id,name,gender"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self updateUIwithFBFriendsResponse:result];
            }
        }];
    }

    
}

- (void)updateUIwithFBResponse:(id)fbResponse {
    if (![fbResponse isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *json = fbResponse;
    NSString *name = json[@"name"];
    NSString *email = json[@"email"];
    NSString *fbId = json[@"id"];
    NSString *gender = json[@"gender"]; // male or female
    self.nameLabel.text = [NSString stringWithFormat:@"FB: %@ %@ (%@) %@", name, @"", fbId, gender];
    NSString *photoURL = [[[json valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
    self.emailLabel.text = email;
    [self loadPhotoByURL:photoURL];
}

- (void)updateUIwithFBFriendsResponse:(id)fbResponse {
    if (![fbResponse isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray *arr = fbResponse[@"data"];
    self.friends = arr;
    [self.tableView reloadData];
}



#pragma mark - IBActions
- (IBAction)loadVKInfoAction:(id)sender {
    [VKSdk forceLogout];
    VKSdk *vkSdkInstance = [VKSdk initializeWithAppId:kAppID] ;
    
    [vkSdkInstance registerDelegate:self];
    [vkSdkInstance setUiDelegate:self];
    NSArray *scope = @[@"email", @"friends", @"photos", @"messages"];
    
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *err) {
        if (state == VKAuthorizationAuthorized) {
            // authorized
            [self loadUsers];
        } else {
            // auth needed
            [VKSdk authorize:scope];
        }
    }];
    
    
}

- (IBAction)loadFBInfoAction:(id)sender {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        NSLog(@"ok");
        [self loadUsersFromFB];
    } else {
        NSLog(@"!ok");
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
                     fromViewController:self
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"Process error");
                                    } else if (result.isCancelled) {
                                        NSLog(@"Cancelled");
                                    } else {
                                        NSLog(@"Logged in");
                                        [self loadUsersFromFB];
                                    }
                                }];

    }

}

- (IBAction)showVKFriendsAction:(id)sender {
    [self loadFriends];
}

- (IBAction)showFBFriendsAction:(id)sender {
    [self loadFriendsFromFB];
}
@end
