# 全局样式说明

本目录包含项目的全局通用样式文件。

## 文件说明

### `common.scss`

包含跨组件复用的通用样式类。

#### 1. `.info-table` - 信息表格样式

用于详情页面的信息展示，提供一行显示两个信息项的网格布局。

**布局特点**：
- 一行显示 2 个信息（标签 + 值）
- 标签列固定宽度 180px
- 值列自动分配剩余宽度
- 支持全宽行（跨所有列）
- 所有边框完美对齐

**使用示例**：

```vue
<template>
  <div class="info-table">
    <!-- 普通行：一行显示两个信息 -->
    <div class="info-row">
      <div class="info-label">姓名</div>
      <div class="info-value">张三</div>
    </div>
    <div class="info-row">
      <div class="info-label">手机号</div>
      <div class="info-value">13800138000</div>
    </div>

    <!-- 全宽行：跨所有列，适合长文本 -->
    <div class="info-row full-width">
      <div class="info-label">详细地址</div>
      <div class="info-value">陕西省西安市未央区凤城五路赛高街区东座101室</div>
    </div>

    <div class="info-row">
      <div class="info-label">邮箱</div>
      <div class="info-value">zhangsan@example.com</div>
    </div>
    <div class="info-row">
      <div class="info-label">身份证号</div>
      <div class="info-value">610102199001011234</div>
    </div>
  </div>
</template>
```

**视觉效果**：

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ 姓名        │ 张三        │ 手机号      │ 13800138000 │
├─────────────┴─────────────┴─────────────┴─────────────┤
│ 详细地址    │ 陕西省西安市未央区凤城五路赛高街区...    │
├─────────────┬─────────────┬─────────────┬─────────────┤
│ 邮箱        │ zhangsan... │ 身份证号    │ 610102...   │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

**CSS 类说明**：

| 类名          | 说明                             |
| ------------- | -------------------------------- |
| `.info-table` | 容器，定义网格布局               |
| `.info-row`   | 信息行，使用 `display: contents` |
| `.info-label` | 标签列，固定 180px，灰色背景     |
| `.info-value` | 值列，自动宽度，白色背景         |
| `.full-width` | 修饰符，使信息行跨所有列         |

**样式特性**：

- 标签字体：13px，中等粗细，次要文字颜色
- 值字体：14px，正常粗细，主要文字颜色
- 单元格内边距：12px 16px
- 自动处理边框：最右列和最后一行无边框

**适用场景**：

- ✅ 用户详情页
- ✅ 订单详情页
- ✅ 业务详情页
- ✅ 配置信息展示
- ✅ 任何需要展示键值对信息的页面

**注意事项**：

1. 不要在 `.info-table` 内添加其他元素，只使用 `.info-row`
2. `.info-row` 必须包含 `.info-label` 和 `.info-value`
3. 全宽行使用 `.info-row.full-width`
4. 如果某行只有一个信息，需要补充空的 `.info-row` 占位

## 引入方式

全局样式已在 `src/bootstrap.ts` 中引入：

```typescript
import './styles/common.scss';
```

## 扩展建议

如果需要添加其他全局样式：

1. 在 `common.scss` 中添加新的样式类
2. 在本 README 中更新文档说明
3. 确保样式命名语义化，避免冲突
4. 建议使用 BEM 命名规范

## 示例页面

参考以下页面查看实际使用效果：

- `src/views/business/list/components/GetihuDetail.vue` - 个体工商户详情
- （其他使用该样式的页面可在此列举）

