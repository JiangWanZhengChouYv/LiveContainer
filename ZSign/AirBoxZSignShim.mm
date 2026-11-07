//
//  AirBoxZSignShim.mm
//  LiveContainer (AirStore fork)
//

#import "include/AirBoxZSign.h"
#import "zsigner.h"

NSProgress *AirBoxZSignBundle(NSString *appPath, NSString *bundleIdentifier, NSData *p12, NSString *password,
                              void (^completion)(BOOL, NSError *))
{
    return [ZSigner signWithAppPath:appPath bundleId:bundleIdentifier cert:p12 pass:password completionHandler:completion];
}

NSString *AirBoxZSignPresence(void)
{
    return NSStringFromClass([ZSigner class]);
}
