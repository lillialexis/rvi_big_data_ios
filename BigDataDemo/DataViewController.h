// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Copyright © 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
//  DataViewController.h
//  BigDataDemo
//
//  Created by Lilli Szafranski on 2/23/16.
//  Copyright © 2016 Jaguar Land Rover. All rights reserved.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end

