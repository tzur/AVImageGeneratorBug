// Copyright (c) 2017 Lightricks. All rights reserved.
// Created by Zur Tene.

#import "DemoViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DemoViewController ()

@property (readonly, nonatomic) NSArray<UIImageView *> *thumbnailViews;

@property (readonly, nonatomic) NSArray<AVAssetImageGenerator *> *generators;

@end

@implementation DemoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor redColor];

  [self setupThumbnailView];
  [self setupGenerators];
  [self loadThumbnails];
}

- (void)setupThumbnailView {
  NSMutableArray<UIImageView *> *thumbnails = [NSMutableArray array];
  for (NSInteger j = 0; j < 4; j++) {
    for (NSInteger i = 0; i < 10; i++) {
      UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
      thumbnailView.frame = CGRectMake((i * (self.view.bounds.size.width / 9)),
                                       (j * (self.view.bounds.size.height / 9)),
                                       self.view.bounds.size.width / 10,
                                       self.view.bounds.size.height / 10);
      [self.view addSubview:thumbnailView];
      [thumbnails addObject:thumbnailView];
    }
  }
  _thumbnailViews = [thumbnails copy];
}

- (void)setupGenerators {
  NSMutableArray<AVAssetImageGenerator *> *generators = [NSMutableArray array];
  NSURL *clipURL = [[NSBundle mainBundle] URLForResource:@"city" withExtension:@"mp4"];
  for (NSInteger i = 0; i < 40; i++) {
    AVAsset *asset = [AVAsset assetWithURL:clipURL];
    [generators addObject:[[AVAssetImageGenerator alloc] initWithAsset:asset]];
  }
  _generators = [generators copy];
}

- (void)loadThumbnails {
  __weak DemoViewController *weak_self = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    for (NSInteger i = 0; i < 40; i++) {
      CMTime time = CMTimeMake(i * 3, 10);
      [self.generators[i] generateCGImagesAsynchronouslyForTimes:@[
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time],
                                                                 [NSValue valueWithCMTime:time]]
                                             completionHandler:^(CMTime requestedTime,
                                                                 CGImageRef  _Nullable image,
                                                                 CMTime actualTime,
                                                                 AVAssetImageGeneratorResult result,
                                                                 NSError * _Nullable error) {
        if (!image) {
          return;
        }
        CGRect imageRect = CGRectMake(0, 0,CGImageGetWidth(image), CGImageGetHeight(image));
        UIGraphicsBeginImageContext(imageRect.size);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, imageRect.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), imageRect, image);
        UIImage *copiedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
          weak_self.thumbnailViews[i].image = copiedImage;
        });
      }];
    }
  });
}

@end
