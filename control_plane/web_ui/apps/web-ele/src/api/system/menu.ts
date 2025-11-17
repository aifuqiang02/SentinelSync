/**
 * 菜单管理 API
 */
import { requestClient } from '#/api/request';

/**
 * 菜单类型
 */
export interface Menu {
  id?: string;
  parentId?: string;
  menuName: string;
  menuCode: string;
  menuType: string;
  path?: string;
  component?: string;
  permission?: string;
  icon?: string;
  sortOrder?: number;
  visible?: number;
  status: string;
  remark?: string;
  createTime?: string;
  updateTime?: string;
  children?: Menu[];
}

export const menuApi = {
  /**
   * 获取菜单树
   */
  async getMenuTree() {
    return requestClient.get<Menu[]>('/system/menu/tree');
  },

  /**
   * 获取菜单详情
   */
  async getMenuById(id: string) {
    return requestClient.get<Menu>(`/system/menu/${id}`);
  },

  /**
   * 创建菜单
   */
  async createMenu(data: Menu) {
    return requestClient.post<Menu>('/system/menu', data);
  },

  /**
   * 更新菜单
   */
  async updateMenu(id: string, data: Menu) {
    return requestClient.put<Menu>(`/system/menu/${id}`, data);
  },

  /**
   * 删除菜单
   */
  async deleteMenu(id: string) {
    return requestClient.delete(`/system/menu/${id}`);
  },
};

