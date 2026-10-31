//
//  AirBoxEngine.h
//
//  The only thing AirStore's AirBox calls into. Everything else in this directory is upstream's.
//

#ifndef AirBoxEngine_h
#define AirBoxEngine_h

/// Loads the guest whose bundle lives at `guestBundlePath` and hands it the process: this never
/// returns. Mirrors what LiveContainer's own main() does through its shared framework.
int AirBoxRunGuest(const char *guestBundlePath, int argc, char *argv[], char *envp[]);

#endif /* AirBoxEngine_h */
