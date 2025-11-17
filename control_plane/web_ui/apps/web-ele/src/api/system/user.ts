import { requestClient } from '#/api/request';

/**
 * 用户数据类型
 */
export interface User {
  id?: string;
  username: string;
  password?: string;
  realName?: string;
  email?: string;
  phone?: string;
  avatar?: string;
  status?: string;
  deptId?: string;
  position?: string;
  employeeNo?: string;
  gender?: string;
  birthday?: string;
  userType?: string;
  roleIds?: string[];
  remark?: string;
  createTime?: string;
  updateTime?: string;
  lastLoginTime?: string;
  lastLoginIp?: string;
  loginCount?: number;
}

/**
 * 分页查询参数
 */
export interface UserPageParams {
  current?: number;
  size?: number;
  username?: string;
  realName?: string;
  phone?: string;
  deptId?: string;
  status?: string;
}

/**
 * 分页结果
 */
export interface PageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

/**
 * 用户 API
 */
export const userApi = {
  /**
   * 分页查询用户列表
   */
  async getUserPage(params: UserPageParams) {
    return requestClient.get<PageResult<User>>('/system/user/page', { params });
  },

  /**
   * 根据ID获取用户
   */
  async getUserById(id: string) {
    return requestClient.get<User>(`/system/user/${id}`);
  },

  /**
   * 创建用户
   */
  async createUser(data: User) {
    return requestClient.post<User>('/system/user', data);
  },

  /**
   * 更新用户
   */
  async updateUser(id: string, data: User) {
    return requestClient.put<User>(`/system/user/${id}`, data);
  },

  /**
   * 删除用户
   */
  async deleteUser(id: string) {
    return requestClient.delete(`/system/user/${id}`);
  },

  /**
   * 重置用户密码
   */
  async resetPassword(id: string) {
    return requestClient.post(`/system/user/${id}/reset-password`);
  },
};

