import type { RouteRecordStringComponent } from '@vben/types';

import { requestClient } from '#/api/request';

/**
 * 后端菜单数据结构
 */
interface BackendMenu {
  id: string;
  parentId?: string;
  menuName: string;
  menuCode: string;
  menuType: string;
  path: string;
  component?: string;
  icon?: string;
  sortOrder?: number;
  visible?: number;
  status: string;
  children?: BackendMenu[];
}

/**
 * 将后端菜单转换为前端路由格式
 */
function transformMenuToRoute(menu: BackendMenu): RouteRecordStringComponent {
  const route: RouteRecordStringComponent = {
    path: menu.path,
    name: menu.menuCode,
    meta: {
      title: menu.menuName,
      icon: menu.icon,
      order: menu.sortOrder,
    },
  };

  // 处理组件路径
  if (menu.component) {
    if (menu.component === 'LAYOUT') {
      // 父级菜单使用布局组件
      route.component = 'BasicLayout';
    } else {
      // 去掉 #/ 前缀，因为 @vben 会自动处理
      route.component = menu.component.replace(/^#\//, '');
    }
  }

  // 递归处理子菜单
  if (menu.children && menu.children.length > 0) {
    route.children = menu.children.map((child) => transformMenuToRoute(child));
  }

  return route;
}

/**
 * 获取用户所有菜单（从后端动态获取）
 */
export async function getAllMenusApi() {
  try {
    // 从后端获取菜单树
    const menuData = await requestClient.get<BackendMenu[]>('/system/menu/routes');
    
    // 转换为前端路由格式
    const routes = menuData.map((menu) => transformMenuToRoute(menu));
    
    console.log('📋 动态菜单数据:', menuData);
    console.log('🔄 转换后的路由:', routes);
    
    return routes;
  } catch (error) {
    console.error('❌ 获取菜单失败:', error);
    throw error;
  }
}
