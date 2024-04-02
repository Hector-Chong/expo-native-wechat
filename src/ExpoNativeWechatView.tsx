import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ExpoNativeWechatViewProps } from './ExpoNativeWechat.types';

const NativeView: React.ComponentType<ExpoNativeWechatViewProps> =
  requireNativeViewManager('ExpoNativeWechat');

export default function ExpoNativeWechatView(props: ExpoNativeWechatViewProps) {
  return <NativeView {...props} />;
}
