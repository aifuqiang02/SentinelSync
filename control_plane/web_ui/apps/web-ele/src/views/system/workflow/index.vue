<template>
  <Page description="管理工作流程配置和设计" title="工作流管理">
    <div class="workflow-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :model="searchForm" :inline="true" style="margin-bottom: 16px">
          <el-form-item label="工作流名称">
            <el-input
              v-model="searchForm.name"
              placeholder="请输入工作流名称"
              clearable
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="状态">
            <el-select
              v-model="searchForm.status"
              placeholder="请选择状态"
              clearable
              style="width: 120px"
              @change="handleSearch"
            >
              <el-option label="启用" value="ACTIVE" />
              <el-option label="禁用" value="DISABLED" />
              <el-option label="草稿" value="DRAFT" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新增工作流
            </el-button>
          </el-form-item>
        </el-form>

        <el-table :data="tableData" v-loading="loading" border style="width: 100%">
          <el-table-column prop="name" label="工作流名称" width="180" />
          <el-table-column prop="description" label="描述" min-width="200" />
          <el-table-column prop="version" label="版本" width="100" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag :type="scope.row.status === 'ACTIVE' ? 'success' : scope.row.status === 'DISABLED' ? 'danger' : 'warning'">
                {{ scope.row.status === 'ACTIVE' ? '启用' : scope.row.status === 'DISABLED' ? '禁用' : '草稿' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdBy" label="创建人" width="120" />
          <el-table-column prop="createdAt" label="创建时间" width="180" />
          <el-table-column prop="updatedAt" label="更新时间" width="180" />
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="scope">
              <el-button size="small" type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
              <el-button size="small" type="info" link @click="handleDesign(scope.row)">设计</el-button>
              <el-popconfirm title="确定要删除该工作流吗？" @confirm="handleDelete(scope.row.id)">
                <template #reference>
                  <el-button size="small" type="danger" link>删除</el-button>
                </template>
              </el-popconfirm>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="loadData"
          @size-change="loadData"
          style="margin-top: 16px; justify-content: flex-end"
        />
      </el-card>

      <!-- 新增/编辑弹窗 -->
      <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px">
        <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
          <el-form-item label="工作流名称" prop="name">
            <el-input v-model="formData.name" placeholder="请输入工作流名称" />
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input v-model="formData.description" type="textarea" :rows="3" placeholder="请输入工作流描述" />
          </el-form-item>
          <el-form-item label="版本" prop="version">
            <el-input v-model="formData.version" placeholder="请输入版本号" />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%">
              <el-option label="草稿" value="DRAFT" />
              <el-option label="启用" value="ACTIVE" />
              <el-option label="禁用" value="DISABLED" />
            </el-select>
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </template>
      </el-dialog>
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';

// TODO: 替换为实际的API调用
// import { workflowApi, type Workflow } from '#/api/system/workflow';

interface Workflow {
  id?: string;
  name: string;
  description: string;
  version: string;
  status: 'DRAFT' | 'ACTIVE' | 'DISABLED';
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

const formRef = ref();
const loading = ref(false);
const tableData = ref<Workflow[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('新增工作流');
const isEdit = ref(false);

const searchForm = reactive({
  name: '',
  status: '',
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const formData = reactive<Workflow>({
  name: '',
  description: '',
  version: '1.0.0',
  status: 'DRAFT',
  createdBy: '',
  createdAt: '',
  updatedAt: '',
});

const rules = {
  name: [{ required: true, message: '请输入工作流名称', trigger: 'blur' }],
  version: [{ required: true, message: '请输入版本号', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
};

const loadData = async () => {
  try {
    loading.value = true;
    // TODO: 替换为实际的API调用
    // const res = await workflowApi.getWorkflowPage({
    //   current: pagination.current,
    //   size: pagination.pageSize,
    //   ...searchForm,
    // });

    // 模拟数据
    const mockData: Workflow[] = [
      {
        id: '1',
        name: '数据备份工作流',
        description: '自动化数据备份和处理流程',
        version: '1.0.0',
        status: 'ACTIVE',
        createdBy: 'admin',
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00',
      },
    ];

    tableData.value = mockData; // res.records;
    pagination.total = mockData.length; // res.total;
  } catch (error: any) {
    ElMessage.error(error.message || '加载失败');
  } finally {
    loading.value = false;
  }
};

// 防抖定时器
let searchTimer: NodeJS.Timeout | null = null;

const handleSearch = () => {
  if (searchTimer) {
    clearTimeout(searchTimer);
  }
  searchTimer = setTimeout(() => {
    pagination.current = 1;
    loadData();
  }, 500);
};

const handleAdd = () => {
  dialogTitle.value = '新增工作流';
  isEdit.value = false;
  resetForm();
  dialogVisible.value = true;
};

const handleEdit = async (record: Workflow) => {
  dialogTitle.value = '编辑工作流';
  isEdit.value = true;
  try {
    // TODO: 替换为实际的API调用
    // const res = await workflowApi.getWorkflowById(record.id);
    // Object.assign(formData, res);
    Object.assign(formData, record);
    dialogVisible.value = true;
  } catch (error: any) {
    ElMessage.error(error.message || '加载失败');
  }
};

const handleDesign = (record: Workflow) => {
  // 跳转到工作流设计器
  console.log('设计工作流:', record.name);
  // TODO: 实现跳转逻辑
};

const handleDelete = async (id: string) => {
  try {
    // TODO: 替换为实际的API调用
    // await workflowApi.deleteWorkflow(id);
    ElMessage.success('删除成功');
    await loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleSubmit = async () => {
  try {
    await formRef.value?.validate();
    // TODO: 替换为实际的API调用
    // if (isEdit.value) {
    //   await workflowApi.updateWorkflow(formData.id!, formData);
    //   ElMessage.success('更新成功');
    // } else {
    //   await workflowApi.createWorkflow(formData);
    //   ElMessage.success('创建成功');
    // }

    ElMessage.success(isEdit.value ? '更新成功' : '创建成功');
    dialogVisible.value = false;
    await loadData();
  } catch (error: any) {
    if (error.errorFields) return;
    ElMessage.error(error.message || '操作失败');
  }
};

const resetForm = () => {
  formData.id = undefined;
  formData.name = '';
  formData.description = '';
  formData.version = '1.0.0';
  formData.status = 'DRAFT';
  formData.createdBy = '';
  formData.createdAt = '';
  formData.updatedAt = '';
  formRef.value?.clearValidate();
};

onMounted(() => {
  loadData();
});
</script>

<style lang="scss" scoped>
.workflow-container {
  height: 100%;
}
</style>