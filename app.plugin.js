const { AndroidConfig, withAndroidManifest } = require("expo/config-plugins");
const { getMainApplicationOrThrow } = AndroidConfig.Manifest;

module.exports = (config) => {
  return withAndroidManifest(config, async (config) => {
    const androidManifest = config.modResults;
    const packageName = config.android?.package;
    config.modResults.manifest.queries.push({
      package: [
        {
          $: {
            "android:name": "com.tencent.mm",
          },
        },
      ],
    });
    const mainApplication = getMainApplicationOrThrow(androidManifest);
    mainApplication.activity?.push({
      $: {
        "android:name": ".wxapi.WXEntryActivity",
        "android:label": "@string/app_name",
        "android:theme": "@android:style/Theme.Translucent.NoTitleBar",
        "android:exported": "true",
        "android:taskAffinity": packageName,
        "android:launchMode": "singleTask",
      },
    });
    mainApplication.activity?.push({
      $: {
        "android:name": ".wxapi.WXPayEntryActivity",
        "android:label": "@string/app_name",
        "android:exported": "true",
      },
    });
    return config;
  });
};
