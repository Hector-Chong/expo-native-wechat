import {
  AndroidConfig,
  ConfigPlugin,
  withAndroidManifest,
} from "expo/config-plugins";

const { getMainApplicationOrThrow } = AndroidConfig.Manifest;

const withNativeWechatConfig: ConfigPlugin = (config) => {
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

    return config;
  });
};

export default withNativeWechatConfig;
