import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:settings-2',
      order: 900,
      title: '系统配置',
    },
    name: 'Config',
    path: '/config',
    children: [
      {
        component: () => import('#/views/system/dict/index.vue'),
        meta: {
          icon: 'lucide:book',
          title: $t('page.system.config.dict'),
        },
        name: 'SystemDict',
        path: 'dict',
      },
      {
        component: () => import('#/views/settings/system/index.vue'),
        meta: {
          icon: 'lucide:settings',
          title: $t('page.settings.system'),
        },
        name: 'SystemSettings',
        path: 'system',
      },
      {
        component: () => import('#/views/settings/ai-provider/index.vue'),
        meta: {
          icon: 'lucide:bot',
          title: $t('page.settings.aiProvider'),
        },
        name: 'AiProviderSettings',
        path: 'ai-provider',
      },
    ],
  },
];

export default routes;

