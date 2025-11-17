import type { UserInfo } from '@vben/types';

import { requestClient } from '#/api/request';

/**
 * 获取用户信息
 */
export async function getUserInfoApi() {
  const response = await requestClient.get<any>('/auth/user/info');
  
  // 适配后端返回的用户信息格式
  return {
    userId: response.id,
    username: response.username,
    realName: response.realName,
    avatar: response.avatar,
    email: response.email,
    phone: response.phone,
    remark: response.remark,
    roles: ['admin'], // TODO: 从后端获取角色
    homePath: '/dashboard/analytics',
  } as UserInfo;
}
