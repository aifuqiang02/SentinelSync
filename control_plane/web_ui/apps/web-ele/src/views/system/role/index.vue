<template>
  <Page description="管理系统角色及权限" title="角色管理">
    <div class="role-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :inline="true" style="margin-bottom: 16px">
          <el-form-item label="角色名称">
            <el-input 
              v-model="searchForm.roleName" 
              placeholder="请输入角色名称" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="角色编码">
            <el-input 
              v-model="searchForm.roleCode" 
              placeholder="请输入角色编码" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新增角色
            </el-button>
          </el-form-item>
        </el-form>

        <el-table :data="tableData" v-loading="loading" border style="width: 100%">
          <el-table-column prop="roleName" label="角色名称" min-width="150" />
          <el-table-column prop="roleCode" label="角色编码" width="150" />
          <el-table-column prop="roleType" label="角色类型" width="120">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.roleType === 'SYSTEM' ? 'primary' : 'info'">
                {{ scope.row.roleType === 'SYSTEM' ? '系统角色' : '自定义角色' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="dataScope" label="数据权限" width="150" />
          <el-table-column prop="sortOrder" label="排序" width="80" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">
                {{ scope.row.status === 'ACTIVE' ? '正常' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="180" />
          <el-table-column label="操作" width="240" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
                <el-button size="small" type="warning" link @click="handleAssignMenu(scope.row)">分配权限</el-button>
                <el-popconfirm
                  v-if="scope.row.roleType !== 'SYSTEM'"
                  title="确定要删除该角色吗？"
                  @confirm="handleDelete(scope.row.id)"
                >
                  <template #reference>
                    <el-button size="small" type="danger" link>删除</el-button>
                  </template>
                </el-popconfirm>
              </template>
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
      <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
        <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
          <el-form-item label="角色编码" prop="roleCode">
            <el-input v-model="formData.roleCode" placeholder="请输入角色编码" />
          </el-form-item>
          <el-form-item label="角色名称" prop="roleName">
            <el-input v-model="formData.roleName" placeholder="请输入角色名称" />
          </el-form-item>
          <el-form-item label="角色类型" prop="roleType">
            <el-select v-model="formData.roleType" placeholder="请选择角色类型" style="width: 100%">
              <el-option label="系统角色" value="SYSTEM" />
              <el-option label="自定义角色" value="CUSTOM" />
            </el-select>
          </el-form-item>
          <el-form-item label="数据权限" prop="dataScope">
            <el-select v-model="formData.dataScope" placeholder="请选择数据权限" style="width: 100%">
              <el-option label="全部数据" value="ALL" />
              <el-option label="自定义" value="CUSTOM" />
              <el-option label="仅本人" value="SELF" />
            </el-select>
          </el-form-item>
          <el-form-item label="排序" prop="sortOrder">
            <el-input-number v-model="formData.sortOrder" :min="0" style="width: 100%" />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="formData.status">
              <el-radio value="ACTIVE">正常</el-radio>
              <el-radio value="DISABLED">停用</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="备注" prop="remark">
            <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </template>
      </el-dialog>

      <!-- 分配权限对话框 -->
      <el-dialog
        v-model="menuDialogVisible"
        title="分配菜单权限"
        width="500px"
      >
        <el-tree
          ref="menuTreeRef"
          :data="menuTreeData"
          :props="{ label: 'menuName', children: 'children' }"
          node-key="id"
          show-checkbox
          default-expand-all
          :default-checked-keys="checkedMenuIds"
        />
        <template #footer>
          <el-button @click="menuDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleMenuSubmit">确定</el-button>
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
import { roleApi, type Role } from '#/api/system/role';
import { menuApi, type Menu } from '#/api/system/menu';
import { requestClient } from '#/api/request';

const formRef = ref();
const menuTreeRef = ref();
const loading = ref(false);
const tableData = ref<Role[]>([]);
const dialogVisible = ref(false);
const menuDialogVisible = ref(false);
const dialogTitle = ref('新增角色');
const isEdit = ref(false);
const currentRole = ref<Role | null>(null);
const menuTreeData = ref<Menu[]>([]);
const checkedMenuIds = ref<string[]>([]);

const searchForm = reactive({
  roleName: '',
  roleCode: '',
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const formData = reactive<Role>({
  roleCode: '',
  roleName: '',
  roleType: 'CUSTOM',
  dataScope: 'CUSTOM',
  status: 'ACTIVE',
  sortOrder: 0,
  remark: '',
});

const rules = {
  roleCode: [{ required: true, message: '请输入角色编码', trigger: 'blur' }],
  roleName: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
};

const loadData = async () => {
  console.log('🔵 [角色管理] loadData 开始执行');
  try {
    loading.value = true;
    console.log('🔵 [角色管理] 准备调用 API, params:', {
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm,
    });
    const res = await roleApi.getRolePage({
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm,
    });
    console.log('🟢 [角色管理] API 调用成功, 返回数据:', res);
    tableData.value = res.records;
    pagination.total = res.total;
  } catch (error: any) {
    console.error('🔴 [角色管理] API 调用失败:', error);
    ElMessage.error(error.message || '加载失败');
  } finally {
    loading.value = false;
    console.log('🔵 [角色管理] loadData 执行完成');
  }
};

// 防抖定时器
let searchTimer: NodeJS.Timeout | null = null;

const handleSearch = () => {
  // 清除之前的定时器
  if (searchTimer) {
    clearTimeout(searchTimer);
  }
  // 设置新的定时器，500ms 后执行搜索
  searchTimer = setTimeout(() => {
    pagination.current = 1;
    loadData();
  }, 500);
};

const handleAdd = () => {
  dialogTitle.value = '新增角色';
  isEdit.value = false;
  resetForm();
  dialogVisible.value = true;
};

const handleEdit = async (record: Role) => {
  dialogTitle.value = '编辑角色';
  isEdit.value = true;
  Object.assign(formData, record);
  dialogVisible.value = true;
};

const handleDelete = async (id: string) => {
  try {
    await roleApi.deleteRole(id);
    ElMessage.success('删除成功');
    await loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleSubmit = async () => {
  try {
    await formRef.value?.validate();
    if (isEdit.value) {
      await roleApi.updateRole(formData.id!, formData);
      ElMessage.success('更新成功');
    } else {
      await roleApi.createRole(formData);
      ElMessage.success('创建成功');
    }
    dialogVisible.value = false;
    await loadData();
  } catch (error: any) {
    if (error.errorFields) return;
    ElMessage.error(error.message || '操作失败');
  }
};

const resetForm = () => {
  formData.id = undefined;
  formData.roleCode = '';
  formData.roleName = '';
  formData.roleType = 'CUSTOM';
  formData.dataScope = 'CUSTOM';
  formData.status = 'ACTIVE';
  formData.sortOrder = 0;
  formData.remark = '';
  formRef.value?.clearValidate();
};

// 加载菜单树
const loadMenuTree = async () => {
  try {
    menuTreeData.value = await menuApi.getMenuTree();
  } catch (error: any) {
    ElMessage.error('加载菜单失败');
  }
};

// 分配权限
const handleAssignMenu = async (row: Role) => {
  currentRole.value = row;
  await loadMenuTree();
  
  // 加载角色已有的菜单
  try {
    const menuIds = await requestClient.get<string[]>(`/system/role/${row.id}/menus`);
    checkedMenuIds.value = menuIds;
  } catch (error: any) {
    ElMessage.error('加载角色菜单失败');
  }
  
  menuDialogVisible.value = true;
};

// 提交权限分配
const handleMenuSubmit = async () => {
  if (!currentRole.value || !currentRole.value.id) {
    return;
  }

  try {
    const checkedKeys = menuTreeRef.value?.getCheckedKeys() || [];
    const halfCheckedKeys = menuTreeRef.value?.getHalfCheckedKeys() || [];
    const allMenuIds = [...checkedKeys, ...halfCheckedKeys];
    
    await requestClient.post(`/system/role/${currentRole.value.id}/menus`, allMenuIds);
    ElMessage.success('分配成功');
    menuDialogVisible.value = false;
  } catch (error: any) {
    ElMessage.error(error.message || '分配失败');
  }
};

onMounted(() => {
  console.log('🚀 [角色管理] 组件已挂载，准备加载数据');
  loadData();
});
</script>

<style lang="scss" scoped>
.role-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
