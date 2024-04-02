import { StyleSheet, Text, View } from 'react-native';

import * as ExpoNativeWechat from 'expo-native-wechat';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{ExpoNativeWechat.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
