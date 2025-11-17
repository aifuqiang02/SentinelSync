import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: 'SentinelSync',
  description: 'AI-Driven Centralized Operations Platform',
  lastUpdated: true,
  cleanUrls: true,

  locales: {
    root: {
      label: 'English',
      lang: 'en',
      title: 'SentinelSync',
      description: 'AI-Driven Centralized Operations Platform',
      themeConfig: {
        dir: 'en',
        nav: [
          { text: 'Home', link: '/' },
          { text: 'Directory', link: '/directory' },
          { text: 'Guide', link: '/guide/installation' },
          { text: 'Architecture', link: '/architecture/overview' },
        ],

        sidebar: [
          {
            text: 'Navigation',
            items: [{ text: 'Documentation Directory', link: '/directory' }],
          },
          {
            text: 'Getting Started',
            items: [
              { text: 'Introduction', link: '/' },
              { text: 'Installation', link: '/guide/installation' },
              { text: 'Development Environment Setup', link: '/guide/development_setup' },
            ],
          },
          {
            text: 'Architecture',
            items: [
              { text: 'Overview', link: '/architecture/overview' },
              {
                text: 'Business Modules',
                link: '/architecture/business-modules',
              },
            ],
          },
        ],

        editLink: {
          pattern:
            'https://github.com/your-org/SentinelSync/edit/main/docs/:path',
          text: 'Edit this page on GitHub',
        },

        footer: {
          message: 'Released under the MIT License.',
          copyright: 'Copyright © 2024-present SentinelSync Team',
        },
      },
    },
    zh: {
      label: '中文',
      lang: 'zh',
      title: 'SentinelSync',
      description: 'AI 驱动的集中式运维平台',
      dir: 'zh',
      link: '/zh/',
      themeConfig: {
        nav: [
          { text: '首页', link: '/zh/' },
          { text: '导航', link: '/zh/directory' },
          { text: '指南', link: '/zh/guide/installation' },
          { text: '架构', link: '/zh/architecture/overview' },
        ],

        sidebar: [
          {
            text: '导航',
            items: [{ text: '文档目录', link: '/zh/directory' }],
          },
          {
            text: '快速开始',
            items: [
              { text: '介绍', link: '/zh/' },
              { text: '安装', link: '/zh/guide/installation' },
              { text: '开发环境搭建', link: '/zh/guide/development_setup' },
            ],
          },
          {
            text: '架构',
            items: [
              { text: '概览', link: '/zh/architecture/overview' },
              { text: '业务模块', link: '/zh/architecture/business-modules' },
            ],
          },
        ],

        editLink: {
          pattern:
            'https://github.com/your-org/SentinelSync/edit/main/docs/:path',
          text: '在 GitHub 上编辑此页',
        },

        footer: {
          message: '采用 MIT 许可证发布。',
          copyright: 'Copyright © 2024-present SentinelSync Team',
        },
      },
    },
  },
})
