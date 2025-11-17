import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:user-circle',
      order: 2000,
      title: $t('page.profile.title'),
    },
    name: 'Profile',
    path: '/profile',
    children: [
      {
        component: () => import('#/views/profile/settings/index.vue'),
        meta: {
          icon: 'lucide:settings',
          title: $t('page.profile.settings'),
        },
        name: 'ProfileSettings',
        path: 'settings',
      },
    ],
  },
];

export default routes;

