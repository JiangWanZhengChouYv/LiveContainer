//
//  AirBoxZSign.h
//  LiveContainer (AirStore fork)
//
//  The one entry the store needs from zsign. Declared here so the Swift side can `import ZSign`; the
//  implementation lives in AirBoxZSignShim.mm, which also keeps the ObjC classes reachable from a static
//  library -- a target made of classes alone can be stripped away as unreferenced.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/// Signs a whole .app with zsign, the way upstream LiveContainer signs a guest: zsign builds the
/// CodeDirectory and the CMS itself, from `p12` and `password`.
NSProgress * _Nullable AirBoxZSignBundle(NSString *appPath,
                                         NSString *bundleIdentifier,
                                         NSData *p12,
                                         NSString *password,
                                         void (^completion)(BOOL success, NSError * _Nullable error));

/// Non-nil when zsign is actually in this binary, so a log line can say so instead of guessing.
NSString *AirBoxZSignPresence(void);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
