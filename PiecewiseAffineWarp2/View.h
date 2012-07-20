//
//  ViewShape.h
//  ShapeAdjustment2
//
//  Created by DINA BURRI on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shape.h"

typedef enum  {
    TOUCH_NONE,
    TOUCH_ONE,
    TOUCH_TWO
} TouchMode;

@interface View : UIView {
    UIImage *image;
    float scale;
    
    TouchMode touchMode;
    CGPoint touchStartPos;
    float touchStartDistance;
    float touchStartAngle;
    
    NSMutableArray *activeTouches;
    NSDate *firstTouchStart;
    
    PDMShape *shape;
}

@property (retain) PDMShape *shape;

- (void)setNewImage:(UIImage*)img :(PDMShape*)newShape;

@end
