import { requestClient } from '#/api/request';

/**
 * 角色数据类型
 */
export interface Role {
  id?: string;
  roleCode: string;
  roleName: string;
  roleType?: string;
  dataScope?: string;
  status?: string;
  sortOrder?: number;
  remark?: string;
  createTime?: string;
  updateTime?: string;
}

/**
 * 分页查询参数
 */
export interface RolePageParams {
  current?: number;
  size?: number;
  roleName?: string;
  roleCode?: string;
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
 * 角色 API
 */
export const roleApi = {
  /**
   * 分页查询角色列表
   */
  async getRolePage(params: RolePageParams) {
    return requestClient.get<PageResult<Role>>('/system/role/page', { params });
  },

  /**
   * 获取所有角色列表
   */
  async getAllRoles() {
    return requestClient.get<Role[]>('/system/role/list');
  },

  /**
   * 根据ID获取角色
   */
  async getRoleById(id: string) {
    return requestClient.get<Role>(`/system/role/${id}`);
  },

  /**
   * 创建角色
   */
  async createRole(data: Role) {
    return requestClient.post<Role>('/system/role', data);
  },

  /**
   * 更新角色
   */
  async updateRole(id: string, data: Role) {
    return requestClient.put<Role>(`/system/role/${id}`, data);
  },

  /**
   * 删除角色
   */
  async deleteRole(id: string) {
    return requestClient.delete(`/system/role/${id}`);
  },
};

