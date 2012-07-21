//
//  ViewController.m
//  PiecewiseAffineWarp
//
//  Created by DINA BURRI on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


#define ARC4RANDOM_MAX      0x100000000

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize segControl;
@synthesize PAW;
@synthesize PAWCPU;
@synthesize model;

@synthesize shape1;
@synthesize shape2;

@synthesize originalImage;
@synthesize warpedImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    model = [[PDMShapeModel alloc] init];
    [model loadModel:@"model_xm" :@"model_v" :@"model_d" :@"model_tri"];
    
    PAW = [[PiecewiseAffineWarp alloc] init];
    PAWCPU = [[PiecewiseAffineWarpCPU alloc] init];
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
    
    originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    shape1 = [model.meanShape getCopy];
    
    // scale and translate shape
    CGRect box = [shape1 getMinBoundingBox];
    float s1 = originalImage.size.width/box.size.width;
    float s2 = originalImage.size.height/box.size.height;
    float s = MIN(s1, s2)/2;
    [shape1 scale:s];
    [shape1 translate:originalImage.size.height/2 :originalImage.size.width/2];
    
    
    shape2 = [shape1 getCopy];
    
    for (int i = 0; i < shape2.num_points; ++i) {
        for(int j = 0; j < 2; ++j) {
            shape2.shape[i].pos[j] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.) - 20;
            //shape2.shape[i].pos[j] -= 20;
        }
    }

    
    {
        NSDate *start = [NSDate date];
        warpedImage = [PAW warpImage:originalImage :shape1 :shape2 :model.triangles];
        NSDate *stop = [NSDate date];
        NSTimeInterval dt = [stop timeIntervalSinceDate:start];
        NSLog(@"Time to perform PAW: %f", dt);
    }
    
    {
        NSDate *start = [NSDate date];
        warpedImage = [PAWCPU warpImage:originalImage :shape1 :shape2 :model.triangles];
        NSDate *stop = [NSDate date];
        NSTimeInterval dt = [stop timeIntervalSinceDate:start];
        NSLog(@"Time to perform PAWCPU: %f", dt);
    }

    
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
            [imageView setNewImage:originalImage :shape1];
            break;
        case 1:
            NSLog(@"show warped image");
            [imageView setNewImage:warpedImage :shape2];
            break;
        default:
            break;
    } 
}

@end
