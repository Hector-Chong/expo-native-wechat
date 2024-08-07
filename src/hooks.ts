import {useEffect, useState} from 'react';
import {isWechatInstalled} from './index';

export const useWechatInstalled = () => {
  const [hasInstalledWechat, setHasInstalledWechat] = useState(false);

  useEffect(() => {
    isWechatInstalled()
      .then(() => setHasInstalledWechat(true))
      .catch(() => setHasInstalledWechat(false));
  }, []);

  return hasInstalledWechat;
};
