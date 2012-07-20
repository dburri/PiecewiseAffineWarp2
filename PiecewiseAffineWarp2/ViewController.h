//
//  ViewController.h
//  PiecewiseAffineWarp
//
//  Created by DINA BURRI on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiecewiseAffineWarp.h"

#import "PDMShapeModel.h"
#import "PDMShape.h"
#import "Shape.h"
#import "View.h"

@interface ViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate > 
{
    IBOutlet View *imageView;
    IBOutlet UISegmentedControl *segControl;
    
    PDMShapeModel *model;
    PiecewiseAffineWarp *PAW;
    
    PDMShape *shape1;
    PDMShape *shape2;
}

@property (retain) IBOutlet View *imageView;
@property (retain) IBOutlet UISegmentedControl *segControl;
@property (nonatomic, retain) PiecewiseAffineWarp *PAW;
@property (retain) PDMShapeModel *model;

@property (retain) PDMShape *shape1;
@property (retain) PDMShape *shape2;

- (IBAction)loadImageLibrary:(id)sender;
- (IBAction)loadImageCamera:(id)sender;
- (IBAction)selectImage:(id)sender;

- (void)setImageView;

@end
