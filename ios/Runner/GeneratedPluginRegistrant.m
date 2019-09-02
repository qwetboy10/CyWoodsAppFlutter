//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <background_fetch/BackgroundFetchPlugin.h>
#import <clipboard_manager/ClipboardManagerPlugin.h>
#import <device_id/DeviceIdPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <sensors/SensorsPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <url_launcher/UrlLauncherPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [BackgroundFetchPlugin registerWithRegistrar:[registry registrarForPlugin:@"BackgroundFetchPlugin"]];
  [ClipboardManagerPlugin registerWithRegistrar:[registry registrarForPlugin:@"ClipboardManagerPlugin"]];
  [DeviceIdPlugin registerWithRegistrar:[registry registrarForPlugin:@"DeviceIdPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTSensorsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSensorsPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [FLTUrlLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTUrlLauncherPlugin"]];
}

@end
