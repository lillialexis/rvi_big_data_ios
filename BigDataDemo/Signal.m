/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    Signal.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "Signal.h"


@implementation Signal
{

}

- (id)initWithSignalName:(NSString *)signalName
{
    if (signalName == nil)
        return nil;

    if ((self = [super init]))
    {
        _signalName = [signalName copy];
    }

    return self;
}

+ (id)signalWithSignalName:(NSString *)signalName
{
    return [[Signal alloc] initWithSignalName:signalName];
}

@end
