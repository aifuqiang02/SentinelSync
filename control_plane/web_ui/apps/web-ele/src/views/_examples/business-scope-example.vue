<template>
  <div class="business-scope-example">
    <!-- 搜索表单 -->
    <el-card class="mb-4">
      <el-form :model="searchForm" :inline="true">
        <el-form-item label="关键词">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入经营范围名称"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="分类">
          <el-select
            v-model="searchForm.scopeCategory"
            placeholder="请选择分类"
            clearable
            style="width: 150px"
          >
            <el-option
              v-for="item in SCOPE_CATEGORY_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card>
      <el-table :data="tableData" border stripe>
        <el-table-column prop="scopeCode" label="范围编码" width="120" />
        <el-table-column prop="scopeName" label="经营范围名称" min-width="200" />

        <!-- 分类 - 方式1：纯文本显示 -->
        <el-table-column label="分类（文本）" width="120">
          <template #default="{ row }">
            {{ getScopeCategoryText(row.scopeCategory) }}
          </template>
        </el-table-column>

        <!-- 分类 - 方式2：标签显示（推荐） -->
        <el-table-column label="分类（标签）" width="120">
          <template #default="{ row }">
            <el-tag :type="getScopeCategoryTagType(row.scopeCategory)">
              {{ getScopeCategoryText(row.scopeCategory) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="categoryCode" label="行业代码" width="100" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="mt-4 flex justify-end">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSearch"
          @current-change="handleSearch"
        />
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
      >
        <el-form-item label="范围编码" prop="scopeCode">
          <el-input v-model="formData.scopeCode" placeholder="请输入范围编码" />
        </el-form-item>

        <el-form-item label="范围名称" prop="scopeName">
          <el-input
            v-model="formData.scopeName"
            placeholder="请输入经营范围名称"
          />
        </el-form-item>

        <el-form-item label="分类" prop="scopeCategory">
          <el-select
            v-model="formData.scopeCategory"
            placeholder="请选择分类"
            style="width: 100%"
          >
            <el-option
              v-for="item in SCOPE_CATEGORY_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="行业代码" prop="categoryCode">
          <el-input
            v-model="formData.categoryCode"
            placeholder="请输入国民经济行业代码（如：A、C13）"
          />
        </el-form-item>

        <el-form-item label="说明">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入说明"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import {
  SCOPE_CATEGORY_OPTIONS,
  ScopeCategoryEnum,
  getScopeCategoryText,
  getScopeCategoryTagType,
} from '#/constants/business';
import type { BusinessScope } from '#/api/system/businessScope';

// 搜索表单
const searchForm = reactive({
  keyword: '',
  scopeCategory: undefined as number | undefined,
});

// 分页
const pagination = reactive({
  current: 1,
  size: 20,
  total: 0,
});

// 表格数据
const tableData = ref<BusinessScope[]>([
  {
    id: '1',
    scopeCode: 'TECH001',
    scopeName: '技术开发、技术转让、技术咨询、技术服务',
    scopeCategory: ScopeCategoryEnum.GENERAL,
    categoryCode: 'I',
  },
  {
    id: '2',
    scopeCode: 'FOOD001',
    scopeName: '食品经营（销售预包装食品）',
    scopeCategory: ScopeCategoryEnum.PRE_PERMIT,
    categoryCode: 'F',
  },
  {
    id: '3',
    scopeCode: 'MEDICAL001',
    scopeName: '医疗器械销售（第二类、第三类）',
    scopeCategory: ScopeCategoryEnum.POST_PERMIT,
    categoryCode: 'F',
  },
]);

// 对话框
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const formData = reactive<Partial<BusinessScope>>({
  scopeCategory: ScopeCategoryEnum.GENERAL,
});

// 表单验证规则
const formRules: FormRules = {
  scopeCode: [{ required: true, message: '请输入范围编码', trigger: 'blur' }],
  scopeName: [{ required: true, message: '请输入范围名称', trigger: 'blur' }],
  scopeCategory: [{ required: true, message: '请选择分类', trigger: 'change' }],
};

// 搜索
const handleSearch = () => {
  console.log('搜索条件:', searchForm);
  // 这里调用实际的 API
  // const params = {
  //   current: pagination.current,
  //   size: pagination.size,
  //   keyword: searchForm.keyword,
  //   category: searchForm.scopeCategory,
  // };
  // await businessScopeApi.getPage(params);
};

// 重置
const handleReset = () => {
  searchForm.keyword = '';
  searchForm.scopeCategory = undefined;
  pagination.current = 1;
  handleSearch();
};

// 编辑
const handleEdit = (row: BusinessScope) => {
  dialogTitle.value = '编辑经营范围';
  Object.assign(formData, row);
  dialogVisible.value = true;
};

// 删除
const handleDelete = async (row: BusinessScope) => {
  try {
    await ElMessageBox.confirm('确定要删除该经营范围吗？', '提示', {
      type: 'warning',
    });
    console.log('删除:', row.id);
    ElMessage.success('删除成功');
    handleSearch();
  } catch {
    // 取消删除
  }
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate();
  console.log('提交数据:', formData);
  ElMessage.success('保存成功');
  dialogVisible.value = false;
  handleSearch();
};

// 关闭对话框
const handleDialogClose = () => {
  formRef.value?.resetFields();
  Object.keys(formData).forEach((key) => {
    delete formData[key as keyof typeof formData];
  });
  formData.scopeCategory = ScopeCategoryEnum.GENERAL;
};
</script>

<style scoped lang="scss">
.business-scope-example {
  padding: 20px;

  .mb-4 {
    margin-bottom: 16px;
  }

  .mt-4 {
    margin-top: 16px;
  }

  .flex {
    display: flex;
  }

  .justify-end {
    justify-content: flex-end;
  }
}
</style>

