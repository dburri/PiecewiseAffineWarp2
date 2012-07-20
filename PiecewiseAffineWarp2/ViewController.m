//
//  ViewController.m
//  PiecewiseAffineWarp
//
//  Created by DINA BURRI on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize segControl;
@synthesize PAW;
@synthesize model;

@synthesize shape1;
@synthesize shape2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     model = [[PDMShapeModel alloc] init];
    [model loadModel:@"model_xm" :@"model_v" :@"model_d" :@"model_tri"];
    [model printTriangles];
    
    PAW = [[PiecewiseAffineWarp alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


// UIImagePickerControl callback
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    shape1 = [model.meanShape getCopy];
    
    // scale and translate shape
    CGRect box = [shape1 getMinBoundingBox];
    float s1 = image.size.width/box.size.width;
    float s2 = image.size.height/box.size.height;
    float s = MIN(s1, s2)/2;
    [shape1 scale:s];
    [shape1 translate:image.size.height/2 :image.size.width/2];
    
    
    shape2 = [shape1 getCopy];
    
    
    [shape1 printShapeValues];
    
    
    
    
    [PAW setImage:image :shape1 :shape2 :model.triangles];
    [self setImageView];
}


- (IBAction)loadImageLibrary:(id)sender {
    NSLog(@"Load Image From Library");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	[self presentModalViewController:picker animated:YES];
    
}

- (IBAction)loadImageCamera:(id)sender {
    NSLog(@"Load Image From Camera");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:picker animated:YES];
    
}

- (IBAction)selectImage:(id)sender
{
    NSLog(@"Select image to display");
    [self setImageView];
}

- (void)setImageView
{
    switch (segControl.selectedSegmentIndex) {
        case 0:
            NSLog(@"show original image, PAW.originalImage = %@", PAW.originalImage);
            [imageView setNewImage:PAW.originalImage];
            break;
        case 1:
            NSLog(@"show warped image");
            [imageView setNewImage:PAW.warpedImage];
            break;
        default:
            break;
    } 
}

@end
