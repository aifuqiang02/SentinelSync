<template>
  <Page description="管理系统菜单及按钮权限" title="菜单管理">
    <div class="menu-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :inline="true" style="margin-bottom: 16px">
          <el-form-item label="菜单名称">
            <el-input 
              v-model="searchForm.menuName" 
              placeholder="请输入菜单名称" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新增菜单
            </el-button>
          </el-form-item>
        </el-form>

        <el-table
          :data="menuList"
          row-key="id"
          border
          default-expand-all
          v-loading="loading"
          style="width: 100%"
        >
          <el-table-column prop="menuName" label="菜单名称" min-width="200" />
          <el-table-column prop="menuCode" label="菜单编码" width="150" />
          <el-table-column prop="menuType" label="类型" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.menuType === 'MENU' ? 'primary' : 'info'">
                {{ scope.row.menuType === 'MENU' ? '菜单' : '按钮' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="path" label="路由路径" width="150" />
          <el-table-column prop="icon" label="图标" width="80" />
          <el-table-column prop="sortOrder" label="排序" width="80" />
          <el-table-column prop="visible" label="可见" width="80">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.visible === 1 ? 'success' : 'danger'">
                {{ scope.row.visible === 1 ? '是' : '否' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">
                {{ scope.row.status === 'ACTIVE' ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
                <el-popconfirm title="确定要删除该菜单吗？" @confirm="handleDelete(scope.row.id)">
                  <template #reference>
                    <el-button size="small" type="danger" link>删除</el-button>
                  </template>
                </el-popconfirm>
              </template>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <!-- 新增/编辑对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogTitle"
        width="600px"
        @close="resetForm"
      >
        <el-form :model="formData" :rules="rules" ref="formRef" label-width="100px">
          <el-form-item label="上级菜单" prop="parentId">
            <el-tree-select
              v-model="formData.parentId"
              :data="menuTreeData"
              :props="{ value: 'id', label: 'menuName', children: 'children' }"
              check-strictly
              placeholder="请选择上级菜单"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="菜单类型" prop="menuType">
            <el-radio-group v-model="formData.menuType">
              <el-radio value="MENU">菜单</el-radio>
              <el-radio value="BUTTON">按钮</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="菜单名称" prop="menuName">
            <el-input v-model="formData.menuName" placeholder="请输入菜单名称" />
          </el-form-item>
          <el-form-item label="菜单编码" prop="menuCode">
            <el-input v-model="formData.menuCode" placeholder="请输入菜单编码" />
          </el-form-item>
          <el-form-item label="路由路径" prop="path" v-if="formData.menuType === 'MENU'">
            <el-input v-model="formData.path" placeholder="请输入路由路径" />
          </el-form-item>
          <el-form-item label="组件路径" prop="component" v-if="formData.menuType === 'MENU'">
            <el-input v-model="formData.component" placeholder="请输入组件路径" />
          </el-form-item>
          <el-form-item label="权限标识" prop="permission">
            <el-input v-model="formData.permission" placeholder="请输入权限标识" />
          </el-form-item>
          <el-form-item label="图标" prop="icon" v-if="formData.menuType === 'MENU'">
            <el-input v-model="formData.icon" placeholder="请输入图标" />
          </el-form-item>
          <el-form-item label="排序" prop="sortOrder">
            <el-input-number v-model="formData.sortOrder" :min="0" style="width: 100%" />
          </el-form-item>
          <el-form-item label="是否可见" prop="visible" v-if="formData.menuType === 'MENU'">
            <el-radio-group v-model="formData.visible">
              <el-radio :value="1">是</el-radio>
              <el-radio :value="0">否</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="formData.status">
              <el-radio value="ACTIVE">启用</el-radio>
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
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';
import { menuApi, type Menu } from '#/api/system/menu';

const formRef = ref();
const loading = ref(false);
const menuList = ref<Menu[]>([]);
const allMenuList = ref<Menu[]>([]);
const menuTreeData = ref<Menu[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('新增菜单');
const isEdit = ref(false);

const searchForm = reactive({
  menuName: '',
});

const formData = reactive<Menu>({
  menuCode: '',
  menuName: '',
  menuType: 'MENU',
  parentId: undefined,
  path: '',
  component: '',
  permission: '',
  icon: '',
  sortOrder: 0,
  visible: 1,
  status: 'ACTIVE',
  remark: '',
});

const rules = {
  menuCode: [{ required: true, message: '请输入菜单编码', trigger: 'blur' }],
  menuName: [{ required: true, message: '请输入菜单名称', trigger: 'blur' }],
  menuType: [{ required: true, message: '请选择菜单类型', trigger: 'change' }],
};

// 递归过滤树形数据
const filterTree = (tree: Menu[], name: string): Menu[] => {
  return tree.filter((node) => {
    const matchName = !name || (node.menuName && node.menuName.includes(name));

    if (node.children && node.children.length > 0) {
      node.children = filterTree(node.children, name);
      return matchName || node.children.length > 0;
    }

    return matchName;
  }).map(node => ({ ...node }));
};

const loadMenuTree = async () => {
  try {
    loading.value = true;
    const res = await menuApi.getMenuTree();
    
    allMenuList.value = res;
    
    const filtered = filterTree(
      JSON.parse(JSON.stringify(res)),
      searchForm.menuName
    );
    
    menuList.value = filtered;
    menuTreeData.value = [
      {
        id: '0',
        menuName: '顶级菜单',
        menuCode: 'ROOT',
        menuType: 'MENU',
        status: 'ACTIVE',
        children: res,
      },
    ];
  } catch (error: any) {
    ElMessage.error('加载失败');
  } finally {
    loading.value = false;
  }
};

let searchTimer: NodeJS.Timeout | null = null;

const handleSearch = () => {
  if (searchTimer) {
    clearTimeout(searchTimer);
  }
  searchTimer = setTimeout(() => {
    loadMenuTree();
  }, 500);
};

const handleAdd = () => {
  dialogTitle.value = '新增菜单';
  isEdit.value = false;
  resetForm();
  dialogVisible.value = true;
};

const handleEdit = (row: Menu) => {
  dialogTitle.value = '编辑菜单';
  isEdit.value = true;
  Object.assign(formData, row);
  dialogVisible.value = true;
};

const handleDelete = async (id: string) => {
  try {
    await menuApi.deleteMenu(id);
    ElMessage.success('删除成功');
    loadMenuTree();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleSubmit = async () => {
  try {
    await formRef.value?.validate();
    if (isEdit.value && formData.id) {
      await menuApi.updateMenu(formData.id, formData);
      ElMessage.success('更新成功');
    } else {
      await menuApi.createMenu(formData);
      ElMessage.success('创建成功');
    }
    dialogVisible.value = false;
    loadMenuTree();
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  }
};

const resetForm = () => {
  formRef.value?.resetFields();
  Object.assign(formData, {
    menuCode: '',
    menuName: '',
    menuType: 'MENU',
    parentId: undefined,
    path: '',
    component: '',
    permission: '',
    icon: '',
    sortOrder: 0,
    visible: 1,
    status: 'ACTIVE',
    remark: '',
  });
};

onMounted(() => {
  loadMenuTree();
});
</script>

<style lang="scss" scoped>
.menu-container {
  padding: 16px;
}
</style>

