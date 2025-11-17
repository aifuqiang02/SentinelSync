# 常量配置使用指南

## 业务常量（business.ts）

### 经营范围分类

#### 1. 在表格中显示

```vue
<template>
  <el-table :data="tableData">
    <!-- 使用文本显示 -->
    <el-table-column label="分类" prop="scopeCategory">
      <template #default="{ row }">
        {{ getScopeCategoryText(row.scopeCategory) }}
      </template>
    </el-table-column>

    <!-- 使用标签显示（带颜色） -->
    <el-table-column label="分类" prop="scopeCategory">
      <template #default="{ row }">
        <el-tag :type="getScopeCategoryTagType(row.scopeCategory)">
          {{ getScopeCategoryText(row.scopeCategory) }}
        </el-tag>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup lang="ts">
import { getScopeCategoryText, getScopeCategoryTagType } from '@/constants/business';
</script>
```

#### 2. 在表单中使用（下拉选择）

```vue
<template>
  <el-form :model="form">
    <el-form-item label="经营范围分类" prop="scopeCategory">
      <el-select v-model="form.scopeCategory" placeholder="请选择分类">
        <el-option
          v-for="item in SCOPE_CATEGORY_OPTIONS"
          :key="item.value"
          :label="item.label"
          :value="item.value"
        />
      </el-select>
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { SCOPE_CATEGORY_OPTIONS } from '@/constants/business';

const form = ref({
  scopeCategory: 3, // 默认：一般
});
</script>
```

#### 3. 在搜索条件中使用

```vue
<template>
  <el-form :model="searchForm" :inline="true">
    <el-form-item label="分类">
      <el-select
        v-model="searchForm.scopeCategory"
        placeholder="请选择分类"
        clearable
      >
        <el-option
          v-for="item in SCOPE_CATEGORY_OPTIONS"
          :key="item.value"
          :label="item.label"
          :value="item.value"
        />
      </el-select>
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { SCOPE_CATEGORY_OPTIONS } from '@/constants/business';

const searchForm = reactive({
  scopeCategory: undefined,
});
</script>
```

#### 4. 直接使用枚举值

```typescript
import { ScopeCategoryEnum } from '@/constants/business';

// 判断分类
if (scope.scopeCategory === ScopeCategoryEnum.PRE_PERMIT) {
  console.log('这是前置许可');
}

// 设置默认值
const defaultCategory = ScopeCategoryEnum.GENERAL; // 3
```

### 许可类型（用于许可配置）

#### 在表格中显示

```vue
<template>
  <el-table :data="approvalData">
    <el-table-column label="许可类型" prop="approvalType">
      <template #default="{ row }">
        {{ getApprovalTypeText(row.approvalType) }}
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup lang="ts">
import { getApprovalTypeText } from '@/constants/business';
</script>
```

#### 在表单中使用

```vue
<template>
  <el-form :model="form">
    <el-form-item label="许可类型" prop="approvalType">
      <el-radio-group v-model="form.approvalType">
        <el-radio
          v-for="item in APPROVAL_TYPE_OPTIONS"
          :key="item.value"
          :label="item.value"
        >
          {{ item.label }}
        </el-radio>
      </el-radio-group>
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { APPROVAL_TYPE_OPTIONS, ApprovalTypeEnum } from '@/constants/business';

const form = ref({
  approvalType: ApprovalTypeEnum.POST_APPROVAL,
});
</script>
```

## 导出的内容

### 枚举（Enum）
- `ScopeCategoryEnum` - 经营范围分类枚举
- `ApprovalTypeEnum` - 许可类型枚举

### 映射对象（Map）
- `SCOPE_CATEGORY_TEXT` - 经营范围分类文本映射
- `SCOPE_CATEGORY_TAG_TYPE` - 经营范围分类标签类型映射
- `APPROVAL_TYPE_TEXT` - 许可类型文本映射

### 选项数组（Options）
- `SCOPE_CATEGORY_OPTIONS` - 经营范围分类选项（用于下拉）
- `APPROVAL_TYPE_OPTIONS` - 许可类型选项（用于下拉/单选）

### 工具函数（Utils）
- `getScopeCategoryText(category)` - 获取经营范围分类文本
- `getScopeCategoryTagType(category)` - 获取经营范围分类标签类型
- `getApprovalTypeText(type)` - 获取许可类型文本

## 标签颜色说明

- **前置许可**: `warning` (橙色) - 表示需要先取得许可证
- **后置许可**: `info` (蓝色) - 表示可先办营业执照
- **一般**: `success` (绿色) - 表示无需许可证

