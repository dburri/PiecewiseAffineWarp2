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

@synthesize shape1;
@synthesize shape2;

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    shape1 = [[Shape alloc] initWithTestShape:image.size];
    shape2 = [[Shape alloc] initByRandomModifyGivenShape:shape1];
    
    [PAW setImage:image :shape1 :shape2];
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
