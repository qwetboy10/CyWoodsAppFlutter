package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;
import com.mranuran.clipboardmanager.ClipboardManagerPlugin;
import com.notrait.deviceid.DeviceIdPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sensors.SensorsPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    BackgroundFetchPlugin.registerWith(registry.registrarFor("com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin"));
    ClipboardManagerPlugin.registerWith(registry.registrarFor("com.mranuran.clipboardmanager.ClipboardManagerPlugin"));
    DeviceIdPlugin.registerWith(registry.registrarFor("com.notrait.deviceid.DeviceIdPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    SensorsPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sensors.SensorsPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    UrlLauncherPlugin.registerWith(registry.registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
