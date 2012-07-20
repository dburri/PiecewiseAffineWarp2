//
//  ViewShape.m
//  ShapeAdjustment2
//
//  Created by DINA BURRI on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "View.h"

#define ARC4RANDOM_MAX      0x100000000

@implementation View

@synthesize shape;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"View:initWithFrame");
        activeTouches = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        NSLog(@"View:initWithCoder");
        activeTouches = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc
{
    
}

- (void)setNewImage:(UIImage*)img :(PDMShape*)newShape
{
    NSLog(@"Set a new image to view with size = %f x %f", img.size.width, img.size.height);
    
    CGSize viewSize = self.frame.size;
    
    float s1 = img.size.width/viewSize.width;
    float s2 = img.size.height/viewSize.height;
    scale = 1/MAX(s1,s2);
    
    CGSize imgSize = CGSizeMake(scale*img.size.width, scale*img.size.height);
    
    UIGraphicsBeginImageContext(imgSize);
    [img drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    self.shape = newShape;
    
    
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Draw Rect");
    
    CGRect imgRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:imgRect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    for(int i = 0; i < shape.num_points; ++i) 
    {
        CGPoint p = CGPointMake(shape.shape[i].pos[0]*scale, shape.shape[i].pos[1]*scale);
        CGContextFillEllipseInRect(context, CGRectMake(p.x-2.5, p.y-2.5, 5, 5));
    }
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{   
    NSArray *touchesArray = [touches allObjects];
    for(NSInteger j = 0; j < [touchesArray count]; ++j) {
        if (![activeTouches containsObject:[touchesArray objectAtIndex:j]]) {
            [activeTouches addObject:[touchesArray objectAtIndex:j]];
        };
    }
    
    int touchesCount = [activeTouches count];
    NSLog(@"Touch Count = %i", touchesCount);
    
    if(touchesCount == 1) {
        firstTouchStart = [NSDate date];
    }
    NSDate *touchTime = [NSDate date];
    double dt = [touchTime timeIntervalSinceDate:firstTouchStart];

    
    if(touchesCount == 1 && touchMode == TOUCH_NONE)
    {
        NSLog(@"set mode to one touche");
        touchMode = TOUCH_ONE;
        UITouch * touch = [touches anyObject];
        touchStartPos = [touch locationInView:self];
    }
    
    if(touchesCount == 2 && dt < 0.5)
    {
        NSLog(@"set mode to two touches");
        touchMode = TOUCH_TWO;
        UITouch *touch1 = [activeTouches objectAtIndex:0];
        UITouch *touch2 = [activeTouches objectAtIndex:1];
        
        CGPoint p1 = [touch1 locationInView:self];
        CGPoint p2 = [touch2 locationInView:self];
        
        touchStartPos = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
        touchStartDistance = sqrtf( powf(p1.x-p2.x,2) + powf(p1.y-p2.y,2));
        touchStartAngle = atan2f(p1.x-p2.x, p1.y-p2.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touchMode == TOUCH_ONE)
    {
        NSLog(@"one touche...");
        UITouch *touch = [activeTouches objectAtIndex:0];
        CGPoint p = [touch locationInView:self];
        
        float dx = (p.x-touchStartPos.x)/scale;
        float dy = -(p.y-touchStartPos.y)/scale;
    }
    
    else if(touchMode == TOUCH_TWO)
    {
        NSLog(@"two touches...");
    
        UITouch *touch1 = [activeTouches objectAtIndex:0];
        UITouch *touch2 = [activeTouches objectAtIndex:1];
        
        CGPoint p1 = [touch1 locationInView:self];
        CGPoint p2 = [touch2 locationInView:self];
        CGPoint p = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
        
        float dx = (p.x-touchStartPos.x)/scale;
        float dy = -(p.y-touchStartPos.y)/scale;
        
        float touchDistance = sqrtf( powf(p1.x-p2.x,2) + powf(p1.y-p2.y,2));
        float s = touchDistance/touchStartDistance;
        float touchAngle = atan2f(p1.x-p2.x, p1.y-p2.y);
        float a = touchAngle - touchStartAngle;
    }
    
    [self setNeedsDisplay];
    
}

/**
 Called when a touch ends
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // remove the touch from the list of active touches
    NSArray *touchesArray = [touches allObjects];
    for(NSInteger j = 0; j < [touchesArray count]; ++j) {
        NSUInteger ind = [activeTouches indexOfObject:[touchesArray objectAtIndex:j]];
        
        if(ind == 0 && touchMode == TOUCH_ONE)
            touchMode = TOUCH_NONE;
        
        if((ind == 0 || ind == 1) && touchMode == TOUCH_TWO)
            touchMode = TOUCH_NONE;

        if(ind != NSNotFound)
            [activeTouches removeObjectAtIndex:ind];
    }
}

@end
