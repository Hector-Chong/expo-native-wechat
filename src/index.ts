import { EventEmitter } from "expo-modules-core";

import NativeModule from "./module";
import Notification from "./notification";
import {
  NativeWechatModuleConstants,
  NativeWechatResponse,
  SendAuthRequestResponse,
  LaunchMiniProgramResponse,
  UniversalLinkCheckingResponse,
} from "./typing";
import { executeNativeFunction } from "./utils";
export * from "./hooks";

const emitter = new EventEmitter(NativeModule);

const notification = new Notification();

let registered = false;

const generateError = (response: NativeWechatResponse) =>
  new Error(`[Native Wechat]: (${response.errorCode}) ${response.errorStr}`);

const assertRegisteration = (name: string) => {
  if (!registered) {
    throw new Error(`Please register SDK before invoking ${name}`);
  }
};

export const checkUniversalLinkReady = () => {
  return new Promise<UniversalLinkCheckingResponse>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.checkUniversalLinkReady)();

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const registerApp = (request: {
  appid: string;
  universalLink?: string;
  log?: boolean;
  logPrefix?: string;
}) => {
  if (registered) {
    return;
  }

  emitter.addListener("ResponseData", (response: NativeWechatResponse) => {
    const error = response.errorCode ? generateError(response) : null;

    notification.dispatch(response.id!, error, response);
  });

  emitter.addListener(
    "ResponseFromNotification",
    (response: NativeWechatResponse) => {
      const error = response.errorCode ? generateError(response) : null;

      notification.dispatch(response.type!, error, response);
    },
  );

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.registerApp)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      registered = true;

      resolve(data);
    });
  });
};

export const isWechatInstalled = () => {
  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.isWechatInstalled)();

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const sendAuthRequest = (
  request: { scope: string; state?: string } = {
    scope: "snsapi_userinfo",
    state: "",
  },
) => {
  assertRegisteration("sendAuthRequest");

  return new Promise<SendAuthRequestResponse>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.sendAuthRequest)(request);

    notification.once(id, (error) => {
      if (error) {
        return reject(error);
      }

      notification.once("SendAuthResp", (error, data) => {
        if (error) {
          return reject(error);
        }

        return resolve(data);
      });
    });
  });
};

export const shareText = (request: { text: string; scene: number }) => {
  assertRegisteration("shareText");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.shareText)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const shareImage = (request: { src: string; scene: number }) => {
  assertRegisteration("shareImage");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.shareImage)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const shareVideo = (request: {
  title?: string;
  description?: string;
  scene: number;
  videoUrl: string;
  videoLowBandUrl?: string;
  coverUrl?: string;
}) => {
  assertRegisteration("shareVideo");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.shareVideo)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const shareWebpage = (request: {
  title?: string;
  description?: string;
  scene: number;
  webpageUrl: string;
  coverUrl?: string;
}) => {
  assertRegisteration("shareWebpage");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.shareWebpage)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const shareMiniProgram = (request: {
  userName: string;
  path: string;
  miniprogramType: number;
  webpageUrl: string;
  withShareTicket?: boolean;
  title?: string;
  description?: string;
  coverUrl?: string;
}) => {
  assertRegisteration("shareMiniProgram");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.shareMiniProgram)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const requestPayment = (request: {
  partnerId: string;
  prepayId: string;
  nonceStr: string;
  timeStamp: string;
  sign: string;
}) => {
  assertRegisteration("requestPayment");

  return new Promise<SendAuthRequestResponse>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.requestPayment)(request);

    notification.once(id, (error) => {
      if (error) {
        return reject(error);
      }

      notification.once("PayResp", (error, data) => {
        if (error) {
          return reject(error);
        }

        return resolve(data);
      });
    });
  });
};

export const requestSubscribeMessage = (request: {
  scene: number;
  templateId: string;
  reserved?: string;
}) => {
  assertRegisteration("requestSubscribeMessage");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.requestSubscribeMessage)(
      request,
    );

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const openCustomerService = (request: {
  corpid: string;
  url: string;
}) => {
  assertRegisteration("openCustomerService");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.openCustomerService)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const launchMiniProgram = (request: {
  userName: string;
  path: string;
  miniProgramType: number;
  onNavBack?: (res: LaunchMiniProgramResponse) => void;
}) => {
  assertRegisteration("launchMiniProgram");

  return new Promise<boolean>((resolve, reject) => {
    const id = executeNativeFunction(NativeModule.launchMiniProgram)(request);

    notification.once(id, (error, data) => {
      if (error) reject(error);

      resolve(data);
    });
  });
};

export const NativeWechatConstants =
  NativeModule.getConstants() as NativeWechatModuleConstants;

export const NativeWechatShareScene = {
  WXSceneSession: NativeWechatConstants.WXSceneSession,
  WXSceneTimeline: NativeWechatConstants.WXSceneTimeline,
  WXSceneFavorite: NativeWechatConstants.WXSceneFavorite,
};

export const NativeWechatMiniprogramType = {
  WXMiniProgramTypeRelease: NativeWechatConstants.WXMiniProgramTypeRelease,
  WXMiniProgramTypeTest: NativeWechatConstants.WXMiniProgramTypeTest,
  WXMiniProgramTypePreview: NativeWechatConstants.WXMiniProgramTypePreview,
};
