<template>
  <Page description="管理系统数据字典" title="字典管理">
    <div class="dict-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :inline="true" :model="searchForm" style="margin-bottom: 16px">
          <el-form-item label="字典名称">
            <el-input 
              v-model="searchForm.dictName" 
              placeholder="请输入字典名称" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="字典编码">
            <el-input 
              v-model="searchForm.dictCode" 
              placeholder="请输入字典编码" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="字典级别">
            <el-select 
              v-model="searchForm.dictLevel" 
              placeholder="请选择字典级别" 
              clearable 
              style="width: 120px"
              @change="handleSearch"
            >
              <el-option label="系统级" value="SYSTEM" />
              <el-option label="业务级" value="BUSINESS" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAddDict">
              <el-icon><Plus /></el-icon>
              新增字典
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 字典列表 -->
        <el-table
          :data="dictTableData"
          v-loading="dictLoading"
          border
          style="width: 100%"
        >
          <el-table-column prop="dictName" label="字典名称" min-width="150" />
          <el-table-column prop="dictCode" label="字典编码" width="150" />
          <el-table-column prop="dictType" label="字典类型" width="120" />
          <el-table-column prop="dictLevel" label="字典级别" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.dictLevel === 'SYSTEM' ? 'primary' : 'success'">
                {{ scope.row.dictLevel === 'SYSTEM' ? '系统级' : '业务级' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="businessTypeCode" label="业务类型" width="120" show-overflow-tooltip />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">
                {{ scope.row.status === 'ACTIVE' ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip />
          <el-table-column prop="createTime" label="创建时间" width="180" />
          <el-table-column label="操作" width="260" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleManageItems(scope.row)">
                  管理字典项
                </el-button>
                <el-button size="small" type="warning" link @click="handleEditDict(scope.row)">
                  编辑
                </el-button>
                <el-popconfirm title="确定要删除吗？" @confirm="handleDeleteDict(scope.row.id)">
                  <template #reference>
                    <el-button size="small" type="danger" link>删除</el-button>
                  </template>
                </el-popconfirm>
              </template>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <el-pagination
          v-model:current-page="dictPagination.current"
          v-model:page-size="dictPagination.size"
          :total="dictPagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadDictList"
          @size-change="loadDictList"
          style="margin-top: 16px; justify-content: flex-end"
        />
      </el-card>

      <!-- 字典表单对话框 -->
      <el-dialog
        v-model="dictDialogVisible"
        :title="dictDialogTitle"
        width="600px"
        @close="resetDictForm"
      >
        <el-form :model="dictFormData" :rules="dictRules" ref="dictFormRef" label-width="100px">
          <el-form-item label="字典名称" prop="dictName">
            <el-input v-model="dictFormData.dictName" placeholder="请输入字典名称" />
          </el-form-item>
          <el-form-item label="字典编码" prop="dictCode">
            <el-input v-model="dictFormData.dictCode" placeholder="请输入字典编码" />
          </el-form-item>
          <el-form-item label="字典类型" prop="dictType">
            <el-input v-model="dictFormData.dictType" placeholder="请输入字典类型" />
          </el-form-item>
          <el-form-item label="字典级别" prop="dictLevel">
            <el-radio-group v-model="dictFormData.dictLevel" @change="handleDictLevelChange">
              <el-radio value="SYSTEM">系统级</el-radio>
              <el-radio value="BUSINESS">业务级</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item 
            v-if="dictFormData.dictLevel === 'BUSINESS'" 
            label="关联业务类型" 
            prop="businessTypeCode"
          >
            <el-select 
              v-model="dictFormData.businessTypeCode" 
              placeholder="请选择关联的业务类型"
              clearable
              style="width: 100%"
            >
              <el-option
                v-for="item in businessTypeList"
                :key="item.typeCode"
                :label="item.typeName"
                :value="item.typeCode"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="dictFormData.status">
              <el-radio value="ACTIVE">启用</el-radio>
              <el-radio value="DISABLED">停用</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="备注" prop="remark">
            <el-input v-model="dictFormData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="dictDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleDictSubmit">确定</el-button>
        </template>
      </el-dialog>

      <!-- 字典项管理对话框 -->
      <el-dialog
        v-model="itemDialogVisible"
        :title="`管理字典项 - ${currentDict?.dictName || ''}`"
        width="1000px"
        @close="handleItemDialogClose"
      >
        <div style="margin-bottom: 16px">
          <el-button type="primary" size="small" @click="handleAddDictItem">
            <el-icon><Plus /></el-icon>
            新增字典项
          </el-button>
        </div>

        <!-- 字典项列表 -->
        <el-table
          :data="dictItemList"
          v-loading="itemLoading"
          border
          style="width: 100%"
        >
          <el-table-column prop="itemLabel" label="字典项标签" min-width="150" />
          <el-table-column prop="itemValue" label="字典项值" width="150" />
          <el-table-column prop="itemType" label="字典项类型" width="120" />
          <el-table-column prop="sortOrder" label="排序" width="80" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">
                {{ scope.row.status === 'ACTIVE' ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleEditDictItem(scope.row)">
                  编辑
                </el-button>
                <el-popconfirm title="确定要删除吗？" @confirm="handleDeleteDictItem(scope.row.id)">
                  <template #reference>
                    <el-button size="small" type="danger" link>删除</el-button>
                  </template>
                </el-popconfirm>
              </template>
            </template>
          </el-table-column>
        </el-table>

        <template #footer>
          <el-button @click="itemDialogVisible = false">关闭</el-button>
        </template>
      </el-dialog>

      <!-- 字典项表单对话框 -->
      <el-dialog
        v-model="itemFormDialogVisible"
        :title="itemFormDialogTitle"
        width="600px"
        @close="resetItemForm"
      >
        <el-form :model="itemFormData" :rules="itemRules" ref="itemFormRef" label-width="100px">
          <el-form-item label="字典项标签" prop="itemLabel">
            <el-input v-model="itemFormData.itemLabel" placeholder="请输入字典项标签" />
          </el-form-item>
          <el-form-item label="字典项值" prop="itemValue">
            <el-input v-model="itemFormData.itemValue" placeholder="请输入字典项值" />
          </el-form-item>
          <el-form-item label="字典项类型" prop="itemType">
            <el-input v-model="itemFormData.itemType" placeholder="请输入字典项类型" />
          </el-form-item>
          <el-form-item label="排序" prop="sortOrder">
            <el-input-number v-model="itemFormData.sortOrder" :min="0" style="width: 100%" />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="itemFormData.status">
              <el-radio value="ACTIVE">启用</el-radio>
              <el-radio value="DISABLED">停用</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="备注" prop="remark">
            <el-input v-model="itemFormData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="itemFormDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleItemSubmit">确定</el-button>
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
import { dictApi, type Dict, type DictItem } from '#/api/system/dict';
import { businessTypeApi, type BusinessType } from '#/api/business/type';

const dictFormRef = ref();
const itemFormRef = ref();
const dictLoading = ref(false);
const itemLoading = ref(false);
const dictTableData = ref<Dict[]>([]);
const dictItemList = ref<DictItem[]>([]);
const currentDict = ref<Dict | null>(null);
const businessTypeList = ref<BusinessType[]>([]);
const dictDialogVisible = ref(false);
const itemDialogVisible = ref(false);
const itemFormDialogVisible = ref(false);
const dictDialogTitle = ref('新增字典');
const itemFormDialogTitle = ref('新增字典项');
const isDictEdit = ref(false);
const isItemEdit = ref(false);

const searchForm = reactive({
  dictName: '',
  dictCode: '',
  dictLevel: '',
});

const dictPagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const dictFormData = reactive<Dict>({
  dictName: '',
  dictCode: '',
  dictType: '',
  status: 'ACTIVE',
  dictLevel: 'SYSTEM', // 默认系统级
  businessTypeCode: '',
  remark: '',
});

const itemFormData = reactive<DictItem>({
  dictId: '',
  itemLabel: '',
  itemValue: '',
  itemType: '',
  sortOrder: 0,
  status: 'ACTIVE',
  remark: '',
});

const dictRules = {
  dictName: [{ required: true, message: '请输入字典名称', trigger: 'blur' }],
  dictCode: [{ required: true, message: '请输入字典编码', trigger: 'blur' }],
};

const itemRules = {
  itemLabel: [{ required: true, message: '请输入字典项标签', trigger: 'blur' }],
  itemValue: [{ required: true, message: '请输入字典项值', trigger: 'blur' }],
};

// 加载业务类型列表
const loadBusinessTypes = async () => {
  try {
    const res = await businessTypeApi.getEnabledBusinessTypeList();
    businessTypeList.value = res;
  } catch (error: any) {
    console.error('加载业务类型失败:', error);
  }
};

// 处理字典级别变化
const handleDictLevelChange = (value: string) => {
  // 如果切换为系统级，清空业务类型编码
  if (value === 'SYSTEM') {
    dictFormData.businessTypeCode = '';
  }
};

// 加载字典列表
const loadDictList = async () => {
  try {
    dictLoading.value = true;
    const res = await dictApi.getDictPage({
      current: dictPagination.current,
      size: dictPagination.size,
      ...searchForm,
    });
    dictTableData.value = res.records;
    dictPagination.total = res.total;
  } catch (error: any) {
    ElMessage.error('加载失败');
  } finally {
    dictLoading.value = false;
  }
};

let dictSearchTimer: NodeJS.Timeout | null = null;

const handleSearch = () => {
  if (dictSearchTimer) {
    clearTimeout(dictSearchTimer);
  }
  dictSearchTimer = setTimeout(() => {
    dictPagination.current = 1;
    loadDictList();
  }, 500);
};

// 字典 CRUD 操作
const handleAddDict = () => {
  dictDialogTitle.value = '新增字典';
  isDictEdit.value = false;
  resetDictForm();
  dictDialogVisible.value = true;
};

const handleEditDict = (row: Dict) => {
  dictDialogTitle.value = '编辑字典';
  isDictEdit.value = true;
  Object.assign(dictFormData, row);
  dictDialogVisible.value = true;
};

const handleDeleteDict = async (id: string) => {
  try {
    await dictApi.deleteDict(id);
    ElMessage.success('删除成功');
    loadDictList();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleDictSubmit = async () => {
  try {
    await dictFormRef.value?.validate();
    if (isDictEdit.value && dictFormData.id) {
      await dictApi.updateDict(dictFormData.id, dictFormData);
      ElMessage.success('更新成功');
    } else {
      await dictApi.createDict(dictFormData);
      ElMessage.success('创建成功');
    }
    dictDialogVisible.value = false;
    loadDictList();
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  }
};

const resetDictForm = () => {
  dictFormRef.value?.resetFields();
  Object.assign(dictFormData, {
    dictName: '',
    dictCode: '',
    dictType: '',
    status: 'ACTIVE',
    remark: '',
  });
};

// 字典项管理
const handleManageItems = async (dict: Dict) => {
  currentDict.value = dict;
  await loadDictItems(dict.id!);
  itemDialogVisible.value = true;
};

const loadDictItems = async (dictId: string) => {
  try {
    itemLoading.value = true;
    dictItemList.value = await dictApi.getDictItems(dictId);
  } catch (error: any) {
    ElMessage.error('加载字典项失败');
  } finally {
    itemLoading.value = false;
  }
};

const handleItemDialogClose = () => {
  currentDict.value = null;
  dictItemList.value = [];
};

// 字典项 CRUD 操作
const handleAddDictItem = () => {
  if (!currentDict.value?.id) {
    ElMessage.warning('请先选择字典');
    return;
  }
  itemFormDialogTitle.value = '新增字典项';
  isItemEdit.value = false;
  resetItemForm();
  itemFormData.dictId = currentDict.value.id;
  itemFormDialogVisible.value = true;
};

const handleEditDictItem = (row: DictItem) => {
  itemFormDialogTitle.value = '编辑字典项';
  isItemEdit.value = true;
  Object.assign(itemFormData, row);
  itemFormDialogVisible.value = true;
};

const handleDeleteDictItem = async (id: string) => {
  try {
    await dictApi.deleteDictItem(id);
    ElMessage.success('删除成功');
    if (currentDict.value?.id) {
      loadDictItems(currentDict.value.id);
    }
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleItemSubmit = async () => {
  try {
    await itemFormRef.value?.validate();
    if (isItemEdit.value && itemFormData.id) {
      await dictApi.updateDictItem(itemFormData.id, itemFormData);
      ElMessage.success('更新成功');
    } else {
      await dictApi.createDictItem(itemFormData);
      ElMessage.success('创建成功');
    }
    itemFormDialogVisible.value = false;
    if (currentDict.value?.id) {
      loadDictItems(currentDict.value.id);
    }
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  }
};

const resetItemForm = () => {
  itemFormRef.value?.resetFields();
  Object.assign(itemFormData, {
    dictId: currentDict.value?.id || '',
    itemLabel: '',
    itemValue: '',
    itemType: '',
    sortOrder: 0,
    status: 'ACTIVE',
    remark: '',
  });
};

onMounted(() => {
  loadDictList();
  loadBusinessTypes();
});
</script>

<style lang="scss" scoped>
.dict-container {
  padding: 16px;
}
</style>
