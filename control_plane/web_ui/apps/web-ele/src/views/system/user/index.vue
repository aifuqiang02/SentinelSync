<template>
  <Page description="管理系统用户账号及信息" title="用户管理">
    <div class="user-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :model="searchForm" :inline="true" style="margin-bottom: 16px">
          <el-form-item label="用户名">
            <el-input 
              v-model="searchForm.username" 
              placeholder="请输入用户名" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="真实姓名">
            <el-input 
              v-model="searchForm.realName" 
              placeholder="请输入真实姓名" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input 
              v-model="searchForm.phone" 
              placeholder="请输入手机号" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新增用户
            </el-button>
          </el-form-item>
        </el-form>

        <el-table :data="tableData" v-loading="loading" border style="width: 100%">
          <el-table-column prop="username" label="用户名" width="120" />
          <el-table-column prop="realName" label="真实姓名" width="120" />
          <el-table-column prop="phone" label="手机号" width="130">
            <template #default="scope">
              <span>{{ scope.row?.phone || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="email" label="邮箱" min-width="180" />
          <el-table-column prop="position" label="职位" width="120">
            <template #default="scope">
              <span>{{ scope.row?.position || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.status === 'ACTIVE' ? 'success' : scope.row.status === 'DISABLED' ? 'danger' : 'warning'">
                {{ scope.row.status === 'ACTIVE' ? '正常' : scope.row.status === 'DISABLED' ? '禁用' : '锁定' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="lastLoginTime" label="最后登录" width="180" />
          <el-table-column label="操作" width="240" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
                <el-popconfirm title="确定要重置密码吗？" @confirm="handleResetPassword(scope.row.id)">
                  <template #reference>
                    <el-button size="small" type="warning" link>重置密码</el-button>
                  </template>
                </el-popconfirm>
                <el-popconfirm title="确定要删除该用户吗？" @confirm="handleDelete(scope.row.id)">
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
      <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px">
        <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="用户名" prop="username">
                <el-input v-model="formData.username" placeholder="请输入用户名" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item v-if="!isEdit" label="密码" prop="password">
                <el-input v-model="formData.password" type="password" placeholder="留空则默认 123456" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="真实姓名" prop="realName">
                <el-input v-model="formData.realName" placeholder="请输入真实姓名" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="手机号" prop="phone">
                <el-input v-model="formData.phone" placeholder="请输入手机号" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="邮箱" prop="email">
                <el-input v-model="formData.email" placeholder="请输入邮箱" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="职位" prop="position">
                <el-input v-model="formData.position" placeholder="请输入职位" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="工号" prop="employeeNo">
                <el-input v-model="formData.employeeNo" placeholder="请输入工号" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="性别" prop="gender">
                <el-select v-model="formData.gender" placeholder="请选择性别" style="width: 100%">
                  <el-option label="男" value="M" />
                  <el-option label="女" value="F" />
                  <el-option label="未知" value="U" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="状态" prop="status">
                <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%">
                  <el-option label="正常" value="ACTIVE" />
                  <el-option label="禁用" value="DISABLED" />
                  <el-option label="锁定" value="LOCKED" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="角色" prop="roleIds">
            <el-select v-model="formData.roleIds" multiple placeholder="请选择角色" style="width: 100%">
              <el-option v-for="role in roleList" :key="role.id" :label="role.roleName" :value="role.id" />
            </el-select>
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
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';
import { userApi, type User } from '#/api/system/user';
import { roleApi, type Role } from '#/api/system/role';

const formRef = ref();
const loading = ref(false);
const tableData = ref<User[]>([]);
const roleList = ref<Role[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('新增用户');
const isEdit = ref(false);

const searchForm = reactive({
  username: '',
  realName: '',
  phone: '',
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const formData = reactive<User>({
  username: '',
  password: '',
  realName: '',
  phone: '',
  email: '',
  roleIds: [],
  position: '',
  employeeNo: '',
  gender: 'U',
  status: 'ACTIVE',
  remark: '',
});

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
};

const loadData = async () => {
  console.log('🔵 [用户管理] loadData 开始执行');
  try {
    loading.value = true;
    console.log('🔵 [用户管理] 准备调用 API, params:', {
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm,
    });
    const res = await userApi.getUserPage({
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm,
    });
    console.log('🟢 [用户管理] API 调用成功, 返回数据:', res);
    tableData.value = res.records;
    pagination.total = res.total;
  } catch (error: any) {
    console.error('🔴 [用户管理] API 调用失败:', error);
    ElMessage.error(error.message || '加载失败');
  } finally {
    loading.value = false;
    console.log('🔵 [用户管理] loadData 执行完成');
  }
};

const loadRoles = async () => {
  try {
    const res = await roleApi.getAllRoles();
    roleList.value = res;
  } catch (error: any) {
    ElMessage.error('加载角色失败');
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
  dialogTitle.value = '新增用户';
  isEdit.value = false;
  resetForm();
  dialogVisible.value = true;
};

const handleEdit = async (record: User) => {
  dialogTitle.value = '编辑用户';
  isEdit.value = true;
  try {
    const res = await userApi.getUserById(record.id!);
    Object.assign(formData, res);
    dialogVisible.value = true;
  } catch (error: any) {
    ElMessage.error(error.message || '加载失败');
  }
};

const handleDelete = async (id: string) => {
  try {
    await userApi.deleteUser(id);
    ElMessage.success('删除成功');
    await loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleResetPassword = async (id: string) => {
  try {
    await userApi.resetPassword(id);
    ElMessage.success('密码已重置为 123456');
  } catch (error: any) {
    ElMessage.error(error.message || '重置失败');
  }
};

const handleSubmit = async () => {
  try {
    await formRef.value?.validate();
    if (isEdit.value) {
      await userApi.updateUser(formData.id!, formData);
      ElMessage.success('更新成功');
    } else {
      await userApi.createUser(formData);
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
  formData.username = '';
  formData.password = '';
  formData.realName = '';
  formData.phone = '';
  formData.email = '';
  formData.roleIds = [];
  formData.position = '';
  formData.employeeNo = '';
  formData.gender = 'U';
  formData.status = 'ACTIVE';
  formData.remark = '';
  formRef.value?.clearValidate();
};

onMounted(() => {
  console.log('🚀 [用户管理] 组件已挂载，准备加载数据');
  loadData();
  loadRoles();
});
</script>

<style lang="scss" scoped>
.user-container {
  height: 100%;
}
</style>
