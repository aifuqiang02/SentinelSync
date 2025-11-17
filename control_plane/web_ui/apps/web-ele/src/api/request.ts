/**
 * 该文件可自行根据业务逻辑进行调整
 */
import type { RequestClientOptions } from '@vben/request';

import { useAppConfig } from '@vben/hooks';
import { preferences } from '@vben/preferences';
import {
  authenticateResponseInterceptor,
  defaultResponseInterceptor,
  errorMessageResponseInterceptor,
  RequestClient,
} from '@vben/request';
import { useAccessStore } from '@vben/stores';

import { ElMessage } from 'element-plus';

import { useAuthStore } from '#/store';

import { refreshTokenApi } from './core';

const { apiURL } = useAppConfig(import.meta.env, import.meta.env.PROD);

/**
 * 生成请求唯一标识 (Request ID)
 * 格式: 时间戳-随机数
 * 用于追踪请求，方便日志关联和问题排查
 */
function generateRequestId(): string {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 9);
  return `${timestamp}-${random}`;
}

function createRequestClient(baseURL: string, options?: RequestClientOptions) {
  const client = new RequestClient({
    ...options,
    baseURL,
  });

  /**
   * 重新认证逻辑
   */
  async function doReAuthenticate() {
    console.warn('Access token or refresh token is invalid or expired. ');
    const accessStore = useAccessStore();
    const authStore = useAuthStore();
    accessStore.setAccessToken(null);
    
    // 清除 localStorage 中所有以 vben 开头的 key
    Object.keys(localStorage).forEach(key => {
      if (key.toLowerCase().startsWith('vben')) {
        localStorage.removeItem(key);
        console.log(`[Auth] 已清除 localStorage key: ${key}`);
      }
    });
    
    if (
      preferences.app.loginExpiredMode === 'modal' &&
      accessStore.isAccessChecked
    ) {
      accessStore.setLoginExpired(true);
    } else {
      await authStore.logout();
    }
  }

  /**
   * 刷新token逻辑
   */
  async function doRefreshToken() {
    const accessStore = useAccessStore();
    const resp = await refreshTokenApi();
    const newToken = resp.data;
    accessStore.setAccessToken(newToken);
    return newToken;
  }

  function formatToken(token: null | string) {
    return token ? `Bearer ${token}` : null;
  }

  // 请求头处理
  client.addRequestInterceptor({
    fulfilled: async (config) => {
      const accessStore = useAccessStore();

      // 1. 添加请求唯一标识 (Request ID)
      const requestId = generateRequestId();
      config.headers['X-Request-ID'] = requestId;

      // 2. 添加认证 Token
      config.headers.Authorization = formatToken(accessStore.accessToken);
      // 也可以使用自定义 header
      if (accessStore.accessToken) {
        config.headers['X-Access-Token'] = accessStore.accessToken;
      }

      // 3. 添加语言和其他自定义 headers
      config.headers['Accept-Language'] = preferences.app.locale;
      config.headers['X-Client-Type'] = 'web'; // 客户端类型
      config.headers['X-Client-Version'] = '1.0.0'; // 客户端版本
      config.headers['X-Platform'] = 'PC'; // 平台标识

      // 4. 打印请求日志（开发环境）
      if (import.meta.env.DEV) {
        console.log(`[Request ${requestId}]`, {
          url: config.url,
          method: config.method?.toUpperCase(),
          params: config.params,
          data: config.data,
          headers: {
            'X-Request-ID': requestId,
            'Authorization': accessStore.accessToken 
              ? `Bearer ${accessStore.accessToken.substring(0, 20)}...` 
              : 'None',
          },
        });
      }

      return config;
    },
  });

  // 响应日志拦截器（开发环境）
  if (import.meta.env.DEV) {
    client.addResponseInterceptor({
      fulfilled: (response: any) => {
        const requestId = response.config?.headers?.['X-Request-ID'];
        console.log(`[Response ${requestId}]`, {
          url: response.config?.url,
          status: response.status,
          data: response.data,
        });
        return response;
      },
      rejected: (error: any) => {
        const requestId = error.config?.headers?.['X-Request-ID'];
        console.error(`[Error ${requestId}]`, {
          url: error.config?.url,
          method: error.config?.method?.toUpperCase(),
          status: error.response?.status,
          message: error.message,
          data: error.response?.data,
        });
        throw error;
      },
    });
  }

  // 处理返回的响应数据格式
  client.addResponseInterceptor(
    defaultResponseInterceptor({
      codeField: 'code',
      dataField: 'data',
      successCode: 200, // 后端成功状态码为 200
    }),
  );

  // token过期的处理（包含业务层 401 和 HTTP 401）
  client.addResponseInterceptor(
    authenticateResponseInterceptor({
      client,
      doReAuthenticate,
      doRefreshToken,
      enableRefreshToken: preferences.app.enableRefreshToken,
      formatToken,
    }),
  );

  // 通用的错误处理,如果没有进入上面的错误处理逻辑，就会进入这里
  client.addResponseInterceptor(
    errorMessageResponseInterceptor((msg: string, error) => {
      // 这里可以根据业务进行定制,你可以拿到 error 内的信息进行定制化处理，根据不同的 code 做不同的提示，而不是直接使用 message.error 提示 msg
      // 当前mock接口返回的错误字段是 error 或者 message
      const responseData = error?.response?.data ?? {};
      const errorMessage = responseData?.error ?? responseData?.message ?? '';
  
      // 如果没有错误信息，则会根据状态码进行提示
      ElMessage.error(errorMessage || msg);
    }),
  );

  return client;
}

export const requestClient = createRequestClient(apiURL, {
  responseReturn: 'data',
});

export const baseRequestClient = new RequestClient({ baseURL: apiURL });
