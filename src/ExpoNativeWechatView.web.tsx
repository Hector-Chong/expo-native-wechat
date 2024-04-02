import * as React from 'react';

import { ExpoNativeWechatViewProps } from './ExpoNativeWechat.types';

export default function ExpoNativeWechatView(props: ExpoNativeWechatViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
