//
//  AirBoxEngine.m
//
//  Ours, not upstream's: the two dozen lines that let AirBox hand the process to a guest. Everything
//  it calls is LiveContainer's, unmodified.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import "AirBoxEngine.h"

// Defined in LCBootstrap.m. Upstream's own main() reaches it through a dlsym of the shared framework;
// we link the same code in, so it is a plain call.
int LiveContainerMain(int argc, char *argv[]);

int AirBoxRunGuest(const char *guestBundlePath, int argc, char *argv[], char *envp[])
{
    NSString *bundlePath = [NSString stringWithUTF8String:guestBundlePath];
    if (bundlePath.length == 0) { return 1; }

    // The engine looks for guests under <LC_HOME_PATH>/Documents/Applications/<selected>, so the home
    // is derived from where the guest actually is instead of being assumed.
    NSString *applications = bundlePath.stringByDeletingLastPathComponent;
    NSString *name = bundlePath.lastPathComponent;
    NSString *home = applications.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    setenv("LC_HOME_PATH", home.UTF8String, 1);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"selected"];
    [defaults synchronize];

    return LiveContainerMain(argc, argv);
}
