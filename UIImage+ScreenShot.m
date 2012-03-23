/*
 
 UIImage+ScreenShot.m
 
 Copyright (c) 2012 Truong Vinh Tran
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import <QuartzCore/QuartzCore.h>

#import "UIImage+ScreenShot.h"

@implementation UIImage (ScreenShot)

+ (UIImage*)takingScreenShot:(UIInterfaceOrientation)orientation{
  
  //scaling for retina display
  float scaling = ([[UIScreen mainScreen] scale] == 2.0)?2.0f:1.0f;
  scaling = 1;
  
  CGSize imageSize = [[UIScreen mainScreen] bounds].size;
  
  imageSize = CGSizeMake(imageSize.width*scaling, imageSize.height*scaling);
  
  if (NULL != UIGraphicsBeginImageContextWithOptions)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
  else
    UIGraphicsBeginImageContext(imageSize);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Iterate over every window from back to front
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
  {
    if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
    {
      // -renderInContext: renders in the coordinate space of the layer,
      // so we must first apply the layer's geometry to the graphics context
      CGContextSaveGState(context);
      // Center the context around the window's anchor point
      CGContextTranslateCTM(context, [window center].x, [window center].y);
      
      // Apply the window's transform about the anchor point
      CGContextConcatCTM(context, [window transform]);
      // Offset by the portion of the bounds left of and above the anchor point
      
      CGContextTranslateCTM(context,
                            -[window bounds].size.width * [[window layer] anchorPoint].x,
                            -[window bounds].size.height * [[window layer] anchorPoint].y);
      
      // Render the layer hierarchy to the current context
      [[window layer] renderInContext:context];
      
      
      // Restore the context
      CGContextRestoreGState(context);
    }
  }
  
  // Retrieve the screenshot image
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  // change orientation if it wasnt portrait mode
  
  // image was for the landscape right
  if (orientation == UIInterfaceOrientationLandscapeRight) {
    image =  [[[UIImage alloc] initWithCGImage: image.CGImage
                                         scale: 1.0
                                   orientation: UIImageOrientationLeft] autorelease];
  }
  
  // image was for the landscape left
  if (orientation==UIInterfaceOrientationLandscapeLeft) {
    image =  [[[UIImage alloc] initWithCGImage: image.CGImage
                                         scale: 1.0
                                   orientation: UIImageOrientationRight] autorelease];
  }

  // image was for the upside down
  if (orientation==UIInterfaceOrientationPortraitUpsideDown) {
    image =  [[[UIImage alloc] initWithCGImage: image.CGImage
                                         scale: 1.0
                                   orientation: UIImageOrientationDown] autorelease];
  }
  
  return image;
}

@end
