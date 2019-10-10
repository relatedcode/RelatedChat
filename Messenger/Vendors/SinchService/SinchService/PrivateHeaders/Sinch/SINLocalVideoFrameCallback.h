#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

@protocol SINLocalVideoFrameCallback <NSObject>

/**
 * This method is called when a new frame is captured from the camera. 
 * The produced video frames are in CVPixelBufferRef format. It provides 
 * the possibility for developer to process the local video frames (e.g.
 * applying filters on the frames), and send the updated video frames to 
 * the remote client.
 *
 * IMPORTANT: the developer needs to retain the CVPixelBuffer object 
 * received from the callback by CVPixelBufferRetain,and to release the 
 * object by CVPixelBufferRelease.
 *
 * @param cvPixelBuffer The video frame captured from the camera.
 * @param completionHandler The completionHandler needs to be invoked with 
 * a cvPixelBuffer object which will be sent to the remote peer.
 * 
 * IMPORTANT: The invocation of the completionHandler is mandatory when 
 * SINLocalVideoFrameCallback is set, otherwise the Sinch SDK will not send
 * any frame to the remote peer in this case.
 */

- (void)onFrame:(CVPixelBufferRef)cvPixelBuffer
    completionHandler:(void (^)(CVPixelBufferRef retCVPixelBuffer))completionHandler;

@end
