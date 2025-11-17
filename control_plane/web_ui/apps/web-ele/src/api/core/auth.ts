import { baseRequestClient, requestClient } from '#/api/request';

export namespace AuthApi {
  /** 登录接口参数 */
  export interface LoginParams {
    password?: string;
    username?: string;
    userType?: string;
  }

  /** 登录接口返回值 */
  export interface LoginResult {
    token: string;
    tokenType: string;
    expiresIn: number;
    userId: string;
    username: string;
    realName: string;
    userType: string;
    avatar?: string;
  }

  export interface RefreshTokenResult {
    data: string;
    status: number;
  }
}

/**
 * 登录
 */
export async function loginApi(data: AuthApi.LoginParams) {
  // 添加默认用户类型为 ADMIN
  const params = {
    ...data,
    userType: data.userType || 'ADMIN'
  };
  
  const response = await requestClient.post<AuthApi.LoginResult>('/auth/login', params);
  
  // 适配后端返回格式：返回 accessToken 字段以兼容现有代码
  return {
    ...response,
    accessToken: response.token
  };
}

/**
 * 刷新accessToken
 */
export async function refreshTokenApi() {
  return baseRequestClient.post<AuthApi.RefreshTokenResult>('/auth/refresh', {
    withCredentials: true,
  });
}

/**
 * 退出登录
 */
export async function logoutApi() {
  return requestClient.post('/auth/logout');
}

/**
 * 获取用户权限码
 */
export async function getAccessCodesApi() {
  // TODO: 实现权限码接口
  return Promise.resolve(['*:*:*']); // 临时返回所有权限
}
