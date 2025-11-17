import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:settings',
      order: 1000,
      title: $t('page.system.title'),
    },
    name: 'System',
    path: '/system',
    children: [
      {
        name: 'SystemUser',
        path: 'user',
        component: () => import('#/views/system/user/index.vue'),
        meta: {
          icon: 'lucide:users',
          title: $t('page.system.user'),
        },
      },
      {
        name: 'SystemRole',
        path: 'role',
        component: () => import('#/views/system/role/index.vue'),
        meta: {
          icon: 'lucide:user-check',
          title: $t('page.system.role'),
        },
      },
      {
        component: () => import('#/views/system/menu/index.vue'),
        meta: {
          icon: 'lucide:menu',
          title: $t('page.system.menu'),
        },
        name: 'SystemMenu',
        path: 'menu',
      },
      {
        component: () => import('#/views/system/operlog/index.vue'),
        meta: {
          icon: 'lucide:file-text',
          title: $t('page.system.operlog'),
        },
        name: 'SystemOperLog',
        path: 'operlog',
      },
    ],
  },
];

export default routes;

