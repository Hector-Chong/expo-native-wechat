import {
  NativeWechatConstants,
  NativeWechatShareScene,
  registerApp,
  sendAuthRequest,
  shareText,
} from "expo-native-wechat";
import { useEffect } from "react";
import { Button, StyleSheet, Text, View } from "react-native";

export default function App() {
  const onAuth = async () => {
    const data = await sendAuthRequest({
      scope: "snsapi_userinfo",
    });

    console.log("auth", data);
  };

  const onShareText = async () => {
    const data = await shareText({
      text: "hello",
      scene: NativeWechatShareScene.WXSceneSession,
    });

    console.log("text", data);
  };

  useEffect(() => {
    registerApp({
      appid: "wx4351cdd3d762dfbf",
      universalLink: "https://app.woohelps.com",
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>hello</Text>

      <Button title="auth" onPress={onAuth} />

      <Button title="text" onPress={onShareText} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
