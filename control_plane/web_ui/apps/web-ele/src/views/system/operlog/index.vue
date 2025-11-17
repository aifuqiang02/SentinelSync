<template>
  <Page description="查看系统操作日志记录" title="操作日志">
    <div class="operlog-container">
      <el-card>
        <!-- 搜索表单 -->
        <el-form :inline="true" :model="searchForm" style="margin-bottom: 16px">
          <el-form-item label="操作模块">
            <el-input 
              v-model="searchForm.operModule" 
              placeholder="请输入操作模块" 
              clearable 
              style="width: 160px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item label="操作类型">
            <el-select 
              v-model="searchForm.operType" 
              placeholder="请选择操作类型" 
              clearable 
              style="width: 140px"
              @change="handleSearch"
            >
              <el-option label="新增" value="CREATE" />
              <el-option label="修改" value="UPDATE" />
              <el-option label="删除" value="DELETE" />
              <el-option label="查询" value="QUERY" />
              <el-option label="导出" value="EXPORT" />
              <el-option label="导入" value="IMPORT" />
              <el-option label="授权" value="GRANT" />
              <el-option label="其他" value="OTHER" />
            </el-select>
          </el-form-item>
          <el-form-item label="操作状态">
            <el-select 
              v-model="searchForm.operStatus" 
              placeholder="请选择操作状态" 
              clearable 
              style="width: 120px"
              @change="handleSearch"
            >
              <el-option label="成功" value="SUCCESS" />
              <el-option label="失败" value="FAIL" />
            </el-select>
          </el-form-item>
          <el-form-item label="操作人">
            <el-input 
              v-model="searchForm.operUserName" 
              placeholder="请输入操作人" 
              clearable 
              style="width: 140px"
              @input="handleSearch"
              @clear="handleSearch"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="danger" @click="handleClear" :disabled="!hasSelection">
              批量删除
            </el-button>
            <el-popconfirm title="确定要清空所有日志吗？" @confirm="handleClearAll">
              <template #reference>
                <el-button type="warning">清空日志</el-button>
              </template>
            </el-popconfirm>
          </el-form-item>
        </el-form>

        <el-table 
          :data="tableData" 
          v-loading="loading" 
          border 
          style="width: 100%"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="operModule" label="操作模块" width="120" />
          <el-table-column prop="operType" label="操作类型" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="getOperTypeTag(scope.row.operType)">
                {{ getOperTypeLabel(scope.row.operType) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="operDesc" label="操作描述" min-width="150" />
          <el-table-column prop="requestMethod" label="请求方法" width="100" />
          <el-table-column prop="operStatus" label="状态" width="80">
            <template #default="scope">
              <el-tag v-if="scope.row" :type="scope.row.operStatus === 'SUCCESS' ? 'success' : 'danger'">
                {{ scope.row.operStatus === 'SUCCESS' ? '成功' : '失败' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="operIp" label="操作IP" width="140" />
          <el-table-column prop="operLocation" label="操作地点" width="120" />
          <el-table-column prop="executionTime" label="执行时长" width="100">
            <template #default="scope">
              <span v-if="scope.row">{{ scope.row.executionTime }}ms</span>
            </template>
          </el-table-column>
          <el-table-column prop="operUserName" label="操作人" width="120" />
          <el-table-column prop="operTime" label="操作时间" width="180" />
          <el-table-column label="操作" width="120" fixed="right">
            <template #default="scope">
              <template v-if="scope.row">
                <el-button size="small" type="primary" link @click="handleView(scope.row)">详情</el-button>
                <el-popconfirm title="确定要删除吗？" @confirm="handleDelete(scope.row.id)">
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
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadData"
          @size-change="loadData"
          style="margin-top: 16px; justify-content: flex-end"
        />
      </el-card>

      <!-- 详情对话框 -->
      <el-dialog
        v-model="detailDialogVisible"
        title="操作日志详情"
        width="800px"
      >
        <el-descriptions v-if="currentLog" :column="2" border>
          <el-descriptions-item label="操作模块">{{ currentLog.operModule }}</el-descriptions-item>
          <el-descriptions-item label="操作类型">
            <el-tag :type="getOperTypeTag(currentLog.operType)">
              {{ getOperTypeLabel(currentLog.operType) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="操作描述" :span="2">{{ currentLog.operDesc }}</el-descriptions-item>
          <el-descriptions-item label="请求方法">{{ currentLog.requestMethod }}</el-descriptions-item>
          <el-descriptions-item label="请求URL" :span="1">{{ currentLog.requestUrl }}</el-descriptions-item>
          <el-descriptions-item label="操作状态">
            <el-tag :type="currentLog.operStatus === 'SUCCESS' ? 'success' : 'danger'">
              {{ currentLog.operStatus === 'SUCCESS' ? '成功' : '失败' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="执行时长">{{ currentLog.executionTime }}ms</el-descriptions-item>
          <el-descriptions-item label="操作IP">{{ currentLog.operIp }}</el-descriptions-item>
          <el-descriptions-item label="操作地点">{{ currentLog.operLocation }}</el-descriptions-item>
          <el-descriptions-item label="操作人">{{ currentLog.operUserName }}</el-descriptions-item>
          <el-descriptions-item label="操作时间">{{ currentLog.operTime }}</el-descriptions-item>
          <el-descriptions-item label="请求参数" :span="2">
            <el-input 
              :model-value="currentLog.requestParam || '无'" 
              type="textarea" 
              :rows="4" 
              readonly
            />
          </el-descriptions-item>
          <el-descriptions-item label="响应结果" :span="2">
            <el-input 
              :model-value="currentLog.responseResult || '无'" 
              type="textarea" 
              :rows="4" 
              readonly
            />
          </el-descriptions-item>
          <el-descriptions-item v-if="currentLog.errorMsg" label="错误信息" :span="2">
            <el-text type="danger">{{ currentLog.errorMsg }}</el-text>
          </el-descriptions-item>
        </el-descriptions>
        <template #footer>
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </template>
      </el-dialog>
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Page } from '@vben/common-ui';
import { operLogApi, type OperLog } from '#/api/system/operlog';

const loading = ref(false);
const tableData = ref<OperLog[]>([]);
const detailDialogVisible = ref(false);
const currentLog = ref<OperLog | null>(null);
const selectedIds = ref<string[]>([]);
const hasSelection = ref(false);

const searchForm = reactive({
  operModule: '',
  operType: '',
  operStatus: '',
  operUserName: '',
});

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const loadData = async () => {
  try {
    loading.value = true;
    const res = await operLogApi.getOperLogPage({
      current: pagination.current,
      size: pagination.size,
      ...searchForm,
    });
    tableData.value = res.records;
    pagination.total = res.total;
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
    pagination.current = 1;
    loadData();
  }, 500);
};

const handleView = async (row: OperLog) => {
  if (!row.id) return;
  try {
    currentLog.value = await operLogApi.getOperLogById(row.id);
    detailDialogVisible.value = true;
  } catch (error: any) {
    ElMessage.error('加载详情失败');
  }
};

const handleDelete = async (id: string) => {
  try {
    await operLogApi.deleteOperLogs([id]);
    ElMessage.success('删除成功');
    loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleSelectionChange = (selection: OperLog[]) => {
  selectedIds.value = selection.map(item => item.id!).filter(id => id);
  hasSelection.value = selectedIds.value.length > 0;
};

const handleClear = async () => {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请选择要删除的日志');
    return;
  }

  try {
    await operLogApi.deleteOperLogs(selectedIds.value);
    ElMessage.success('删除成功');
    loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleClearAll = async () => {
  try {
    await operLogApi.clearOperLogs();
    ElMessage.success('清空成功');
    loadData();
  } catch (error: any) {
    ElMessage.error(error.message || '清空失败');
  }
};

const getOperTypeLabel = (type: string) => {
  const typeMap: Record<string, string> = {
    CREATE: '新增',
    UPDATE: '修改',
    DELETE: '删除',
    QUERY: '查询',
    EXPORT: '导出',
    IMPORT: '导入',
    GRANT: '授权',
    OTHER: '其他',
  };
  return typeMap[type] || type;
};

const getOperTypeTag = (type: string) => {
  const tagMap: Record<string, any> = {
    CREATE: 'success',
    UPDATE: 'primary',
    DELETE: 'danger',
    QUERY: 'info',
    EXPORT: 'warning',
    IMPORT: 'warning',
    GRANT: 'success',
    OTHER: '',
  };
  return tagMap[type] || '';
};

onMounted(() => {
  loadData();
});
</script>

<style lang="scss" scoped>
.operlog-container {
  padding: 16px;
}
</style>

