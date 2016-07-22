//
//  ViewController.h
//  TestSocialAPI
//
//  Created by ryuzmukhametov on 22/07/16.
//  Copyright © 2016 Rustam Yuzmukhametov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)loadVKInfoAction:(id)sender;
- (IBAction)loadFBInfoAction:(id)sender;
- (IBAction)showVKFriendsAction:(id)sender;
- (IBAction)showFBFriendsAction:(id)sender;



@end

