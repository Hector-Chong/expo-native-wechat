/** @type {import('expo/config-plugins').AndroidConfig} */
const { AndroidConfig, withAndroidManifest, withDangerousMod } = require("expo/config-plugins");
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');

const { getMainApplicationOrThrow } = AndroidConfig.Manifest;

const withAndroidActivity = (config) => {
  const relativePath = ['app', 'src', 'main', 'java']
  if (!config.android?.package) {
    throw new Error('Missing Android package name in app config. Please set it in app.json or app.config.js.');
  }

  relativePath.push(...(config.android?.package?.split('.') || []))
  return withDangerousMod(config, [
    'android',
    async (config) => {
      const filePath = path.join(config.modRequest.platformProjectRoot, ...relativePath);
      fs.mkdirSync(path.join(filePath, 'wxapi'), { recursive: true });
      
      const entryActivityFilePath = path.join(filePath, 'wxapi', 'WXEntryActivity.java');
      const entryActivityContent = `
        package ${config.android?.package}.wxapi;

        import android.app.Activity;
        import android.content.Intent;
        import android.os.Bundle;

        public class WXEntryActivity extends Activity {
          @Override
          public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            try {
              Intent intent = getIntent();
              Intent intentToBroadcast = new Intent();

              intentToBroadcast.setAction("com.hector.nativewechat.ACTION_REDIRECT_INTENT");
              intentToBroadcast.putExtra("intent", intent);

              sendBroadcast(intentToBroadcast);

              finish();
            } catch (Exception e) {
              e.printStackTrace();
            }
          }
        }
        `;

      await fsp.writeFile(entryActivityFilePath, entryActivityContent, 'utf-8');
      console.log(`Created WXEntryActivity.java at ${entryActivityFilePath}`);

      const payActivityFilePath = path.join(filePath, 'wxapi', 'WXPayEntryActivity.java');
      const payActivityContent = `
        package ${config.android?.package}.wxapi;

        import android.app.Activity;
        import android.os.Bundle;

        public class WXPayEntryActivity extends Activity {
          @Override
          public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            try {
              Intent intent = getIntent();
              Intent intentToBroadcast = new Intent();

              intentToBroadcast.setAction("com.hector.nativewechat.ACTION_REDIRECT_INTENT");
              intentToBroadcast.putExtra("intent", intent);

              sendBroadcast(intentToBroadcast);

              finish();
            } catch (Exception e) {
              e.printStackTrace();
            }
          }
        }
        `;

      await fsp.writeFile(payActivityFilePath, payActivityContent, 'utf-8');
      console.log(`Created WXPayEntryActivity.java at ${payActivityFilePath}`);
      
      return config;
    },
  ]);
}

const withNativeWechatConfig = (config) => {
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
        "android:exported": "true",
        "android:label": "@string/app_name",
      }
    })

    return config;
  });
};

const withConfig = (config) => {
  config = withNativeWechatConfig(config);
  config = withAndroidActivity(config);

  return config;
};

module.exports = withConfig;
