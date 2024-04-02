import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ExpoNativeWechat.web.ts
// and on native platforms to ExpoNativeWechat.ts
import ExpoNativeWechatModule from './ExpoNativeWechatModule';
import ExpoNativeWechatView from './ExpoNativeWechatView';
import { ChangeEventPayload, ExpoNativeWechatViewProps } from './ExpoNativeWechat.types';

// Get the native constant value.
export const PI = ExpoNativeWechatModule.PI;

export function hello(): string {
  return ExpoNativeWechatModule.hello();
}

export async function setValueAsync(value: string) {
  return await ExpoNativeWechatModule.setValueAsync(value);
}

const emitter = new EventEmitter(ExpoNativeWechatModule ?? NativeModulesProxy.ExpoNativeWechat);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ExpoNativeWechatView, ExpoNativeWechatViewProps, ChangeEventPayload };
