#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef PoseDecoder_h
#define PoseDecoder_h

@interface PoseDecoder : NSObject

-(UIImage*) detection: (float *) data
            dataSize: (int) dataSize
            uiImage: (UIImage*) uiImage
           modelWidth: (int) modelWidth
          modelHeight: (int) modelHeight
                scale: (CGPoint) scale
;

-(UIImage*) resizeImageExt: (UIImage*) uiImage
                modelWidth: (int) modelWidth
               modelHeight: (int) modelHeight
                     scale: (CGPoint *) scale
;

@end

#endif /* PoseDecoder_h */
