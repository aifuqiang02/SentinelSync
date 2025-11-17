import { defineConfig } from '@vben/vite-config';

import AutoImport from 'unplugin-auto-import/vite';
import Components from 'unplugin-vue-components/vite';
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers';
import ElementPlus from 'unplugin-element-plus/vite';

export default defineConfig(async () => {
  return {
    application: {},
    vite: {
      define: {
        // 如果环境变量未设置，使用默认值
        'import.meta.env.VITE_GLOB_API_URL': JSON.stringify(
          process.env.VITE_GLOB_API_URL || '/api'
        ),
        'import.meta.env.VITE_APP_TITLE': JSON.stringify(
          process.env.VITE_APP_TITLE || 'AI智慧平台'
        ),
      },
      plugins: [
        // Element Plus 样式自动导入
        ElementPlus({
          format: 'esm',
        }),
        // Element Plus 组件自动导入
        AutoImport({
          resolvers: [ElementPlusResolver()],
        }),
        Components({
          resolvers: [ElementPlusResolver()],
        }),
      ],
      server: {
        proxy: {
          '/api': {
            changeOrigin: true,
            // 不重写路径，保留 /api 前缀
            // rewrite: (path) => path.replace(/^\/api/, ''),
            // 后端服务地址
            target: 'http://10.66.7.82:8080',
            ws: true,
          },
        },
      },
    },
  };
});
