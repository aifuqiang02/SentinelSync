<script lang="ts" setup>
import { ref, onMounted, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { requestClient } from '#/api/request'
import GetihuReviewDialog from '#/views/business/getihu/review-dialog.vue'

// 当前激活的 Tab
const activeTab = ref('todo')

// 统计数据
const statistics = ref({
  todoCount: 0, // 待处理（用户自己的任务）
  pendingApprovalCount: 0, // 待审核（需要审核的业务）
  reviewingCount: 0, // 审核中
  todayProcessedCount: 0, // 今日已处理
  totalCompletedCount: 0, // 累计已完成
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 分页参数
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
})

// 搜索条件
const searchForm = reactive({
  businessNo: '',
  businessName: '',
  businessType: '',
  taskStatus: '',
})

// 业务类型选项
const businessTypeOptions = [
  { label: '个体户注册', value: 'GETIHU_REGISTER' },
  { label: '企业注册', value: 'ENTERPRISE_REGISTER' },
]

// 任务状态选项
const taskStatusOptions = [
  { label: '待处理', value: 'PENDING' },
  { label: '已认领', value: 'CLAIMED' },
  { label: '已完成', value: 'COMPLETED' },
]

// 加载统计数据（审核中、今日已处理、累计已完成）
const loadStatistics = async () => {
  try {
    const statsRes = await requestClient.get('/business/statistics')
    
    // 只更新其他统计数据，待处理和待审核会在各自的列表加载时更新
    statistics.value.reviewingCount = statsRes.reviewingCount || 0
    statistics.value.todayProcessedCount = statsRes.todayProcessedCount || 0
    statistics.value.totalCompletedCount = statsRes.completedCount || 0
  } catch (error) {
    console.error('加载统计数据失败：', error)
  }
}

// 加载待处理任务列表（用户自己的任务，不包括审批任务）
const loadTodoList = async () => {
  loading.value = true
  try {
    // 查询当前用户的待办任务
    const userId = localStorage.getItem('userId') || ''
    const res = await requestClient.get('/workflow/task/page', {
      params: {
        pageNum: pagination.current,
        pageSize: pagination.size,
        assigneeId: userId, // 只查询分配给当前用户的任务
        taskStatus: searchForm.taskStatus || undefined,
        // 注意：不传 taskType 参数，后端会返回所有类型
        // 前端过滤掉 APPROVAL 类型的任务
      },
    })

    // requestClient 已自动解包，直接使用响应数据
    // 过滤掉审批类型的任务
    const allRecords = res.records || []
    const filteredRecords = allRecords.filter((task: any) => task.taskType !== 'APPROVAL')
    
    tableData.value = filteredRecords
    pagination.total = filteredRecords.length
    
    // 更新待处理任务统计数量（不包括审批任务）
    statistics.value.todoCount = filteredRecords.length
  } catch (error) {
    console.error('加载待处理任务失败：', error)
    ElMessage.error('加载待处理任务失败')
  } finally {
    loading.value = false
  }
}

// 加载待审核业务列表（需要审核的业务）
const loadPendingApprovalList = async () => {
  loading.value = true
  try {
    const res = await requestClient.get('/business/pending-approval', {
      params: {
        pageNum: pagination.current,
        pageSize: pagination.size,
        businessNo: searchForm.businessNo || undefined,
        businessName: searchForm.businessName || undefined,
        businessType: searchForm.businessType || undefined,
      },
    })

    // requestClient 已自动解包，直接使用响应数据
    tableData.value = res.records || []
    pagination.total = res.total || 0
    
    // 更新待审核业务统计数量
    statistics.value.pendingApprovalCount = res.total || 0
  } catch (error) {
    console.error('加载待审核列表失败：', error)
    ElMessage.error('加载待审核列表失败')
  } finally {
    loading.value = false
  }
}

// 加载数据（根据当前 Tab）
const loadData = () => {
  pagination.current = 1
  if (activeTab.value === 'todo') {
    loadTodoList()
  } else {
    loadPendingApprovalList()
  }
}

// 查询
const handleQuery = () => {
  loadData()
}

// 重置
const handleReset = () => {
  searchForm.businessNo = ''
  searchForm.businessName = ''
  searchForm.businessType = ''
  searchForm.taskStatus = ''
  handleQuery()
}

// Tab 切换
const handleTabChange = (tab: string) => {
  activeTab.value = tab
  handleReset()
}

// 审核对话框
const reviewDialogVisible = ref(false)
const currentReviewBusiness = ref<any>(null)
const reviewMode = ref<'view' | 'review'>('review') // 'view'只查看，'review'审核模式

// 判断当前业务类型
const currentBusinessType = computed(() => {
  return currentReviewBusiness.value?.businessType || ''
})

// 查看详情（待审核）- 只读模式
const handleViewBusiness = (row: any) => {
  console.log('查看业务：', row)
  console.log('业务类型：', row.businessType)
  currentReviewBusiness.value = row
  reviewMode.value = 'view'
  reviewDialogVisible.value = true
  console.log('对话框应该打开，visible=', reviewDialogVisible.value)
  console.log('当前业务类型computed：', currentBusinessType.value)
}

// 打开审核对话框 - 审核模式
const handleReview = (row: any) => {
  console.log('审核业务：', row)
  console.log('业务类型：', row.businessType)
  currentReviewBusiness.value = row
  reviewMode.value = 'review'
  reviewDialogVisible.value = true
  console.log('对话框应该打开，visible=', reviewDialogVisible.value)
  console.log('当前业务类型computed：', currentBusinessType.value)
}

// 查看详情（待处理任务）
const handleViewTask = (row: any) => {
  if (row.businessId) {
    // 根据业务类型跳转
    window.open(`/#/business/list/detail/${row.businessId}`, '_blank')
  } else {
    ElMessage.warning('无法查看该任务详情')
  }
}

// 审核成功回调
const handleReviewSuccess = () => {
  loadData()
  loadStatistics()
}

// 分页变化
const handlePageChange = (page: number) => {
  pagination.current = page
  loadData()
}

const handleSizeChange = (size: number) => {
  pagination.size = size
  pagination.current = 1
  loadData()
}

// 初始化加载待审核数量（用于红点提示）
const loadPendingApprovalCount = async () => {
  try {
    const res = await requestClient.get('/business/pending-approval', {
      params: { pageNum: 1, pageSize: 1 }, // 只查询第一页获取总数
    })
    statistics.value.pendingApprovalCount = res.total || 0
  } catch (error) {
    console.error('加载待审核数量失败：', error)
  }
}

// 页面加载
onMounted(() => {
  loadStatistics() // 加载其他统计数据
  loadData() // 加载当前 Tab 的列表（会更新对应的统计数量）
  
  // 如果当前 Tab 不是待审核，则单独加载待审核数量用于红点提示
  if (activeTab.value !== 'approval') {
    loadPendingApprovalCount()
  }
})
</script>

<template>
  <div class="pending-approval-container p-5">
    <!-- 统计概览 -->
    <div class="statistics-overview mb-5 grid grid-cols-5 gap-4">
      <div class="stat-card p-4 bg-blue-50 rounded-lg cursor-pointer" @click="handleTabChange('todo')">
        <div class="stat-title text-gray-600 text-sm mb-2">待处理</div>
        <div class="stat-value text-3xl font-bold text-blue-600">
          {{ statistics.todoCount }}
        </div>
        <div class="stat-desc text-gray-500 text-xs mt-1">我的待办任务</div>
      </div>
      <div class="stat-card p-4 bg-orange-50 rounded-lg cursor-pointer" @click="handleTabChange('approval')">
        <div class="stat-title text-gray-600 text-sm mb-2">待审核</div>
        <div class="stat-value text-3xl font-bold text-orange-600">
          {{ statistics.pendingApprovalCount }}
        </div>
        <div class="stat-desc text-gray-500 text-xs mt-1">需要审核的业务</div>
      </div>
      <div class="stat-card p-4 bg-purple-50 rounded-lg">
        <div class="stat-title text-gray-600 text-sm mb-2">审核中</div>
        <div class="stat-value text-3xl font-bold text-purple-600">
          {{ statistics.reviewingCount }}
        </div>
        <div class="stat-desc text-gray-500 text-xs mt-1">正在处理</div>
      </div>
      <div class="stat-card p-4 bg-green-50 rounded-lg">
        <div class="stat-title text-gray-600 text-sm mb-2">今日已处理</div>
        <div class="stat-value text-3xl font-bold text-green-600">
          {{ statistics.todayProcessedCount }}
        </div>
        <div class="stat-desc text-gray-500 text-xs mt-1">今天完成的任务</div>
      </div>
      <div class="stat-card p-4 bg-indigo-50 rounded-lg">
        <div class="stat-title text-gray-600 text-sm mb-2">累计已完成</div>
        <div class="stat-value text-3xl font-bold text-indigo-600">
          {{ statistics.totalCompletedCount }}
        </div>
        <div class="stat-desc text-gray-500 text-xs mt-1">历史累计</div>
      </div>
    </div>

    <!-- 主内容区域 -->
    <el-card>
      <template #header>
        <div class="card-header flex justify-between items-center">
          <el-tabs v-model="activeTab" @tab-change="handleTabChange">
            <el-tab-pane label="待处理" name="todo">
              <template #label>
                <span class="inline-flex items-center gap-2">
                  待处理
                  <el-badge 
                    v-if="statistics.todoCount > 0" 
                    :value="statistics.todoCount" 
                    :max="99"
                    type="danger"
                  />
                  <span v-else-if="statistics.todoCount === 0" class="empty-badge">无</span>
                </span>
              </template>
            </el-tab-pane>
            <el-tab-pane label="待审核" name="approval">
              <template #label>
                <span class="inline-flex items-center gap-2">
                  待审核
                  <el-badge 
                    v-if="statistics.pendingApprovalCount > 0" 
                    :value="statistics.pendingApprovalCount" 
                    :max="99"
                    type="danger"
                  />
                  <span v-else-if="statistics.pendingApprovalCount === 0" class="empty-badge">无</span>
                </span>
              </template>
            </el-tab-pane>
          </el-tabs>
        </div>
      </template>

      <!-- 待处理任务搜索表单 -->
      <el-form v-if="activeTab === 'todo'" :inline="true" :model="searchForm" class="search-form mb-4">
        <el-form-item label="任务状态">
          <el-select
            v-model="searchForm.taskStatus"
            placeholder="请选择"
            clearable
            style="width: 150px"
          >
            <el-option
              v-for="item in taskStatusOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 待审核业务搜索表单 -->
      <el-form v-else :inline="true" :model="searchForm" class="search-form mb-4">
        <el-form-item label="业务编号">
          <el-input
            v-model="searchForm.businessNo"
            placeholder="请输入业务编号"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="业务名称">
          <el-input
            v-model="searchForm.businessName"
            placeholder="请输入业务名称"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="业务类型">
          <el-select
            v-model="searchForm.businessType"
            placeholder="请选择"
            clearable
            style="width: 150px"
          >
            <el-option
              v-for="item in businessTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 待处理任务表格 -->
      <el-table v-if="activeTab === 'todo'" :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="taskName" label="任务名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="taskDesc" label="任务描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="taskStatus" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.taskStatus === 'PENDING' ? 'warning' : row.taskStatus === 'CLAIMED' ? 'primary' : 'success'">
              {{ row.taskStatus === 'PENDING' ? '待处理' : row.taskStatus === 'CLAIMED' ? '已认领' : '已完成' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级" width="80" />
        <el-table-column prop="createTime" label="创建时间" width="160">
          <template #default="{ row }">
            {{ row.createTime ? new Date(row.createTime).toLocaleString('zh-CN') : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewTask(row)">
              查看
            </el-button>
            <el-button link type="success" size="small" @click="() => ElMessage.info('处理功能开发中')">
              处理
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 待审核业务表格 -->
      <el-table v-else :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="businessNo" label="业务编号" width="180" />
        <el-table-column prop="businessName" label="业务名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="businessTypeName" label="业务类型" width="120" />
        <el-table-column prop="statusName" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'PENDING_STAFF' ? 'warning' : 'info'">
              {{ row.statusName }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="currentStep" label="当前环节" width="120" />
        <el-table-column prop="createUserName" label="申请人" width="100" />
        <el-table-column prop="submitTime" label="提交时间" width="160">
          <template #default="{ row }">
            {{ row.submitTime ? new Date(row.submitTime).toLocaleString('zh-CN') : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewBusiness(row)">
              查看
            </el-button>
            <el-button link type="warning" size="small" @click="handleReview(row)">
              审核
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="mt-4 flex justify-end">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="handlePageChange"
          @size-change="handleSizeChange"
        />
    </div>
    </el-card>

    <!-- 调试信息 -->
    <div style="background: #f0f0f0; padding: 10px; margin: 10px 0; font-family: monospace;">
      <div>当前业务类型: {{ currentBusinessType }}</div>
      <div>对话框可见: {{ reviewDialogVisible }}</div>
      <div>审核模式: {{ reviewMode }}</div>
      <div>当前业务信息: {{ currentReviewBusiness?.businessNo }}</div>
    </div>

    <!-- 个体户注册审核对话框 -->
    <GetihuReviewDialog
      v-if="currentBusinessType === 'GETIHU_REGISTER'"
      v-model:visible="reviewDialogVisible"
      :business-info="currentReviewBusiness"
      :mode="reviewMode"
      @success="handleReviewSuccess"
    />

    <!-- 其他业务类型的审核对话框 -->
    <!-- TODO: 添加更多业务类型的审核对话框组件 -->
    <el-dialog
      v-if="currentBusinessType && currentBusinessType !== 'GETIHU_REGISTER'"
      v-model="reviewDialogVisible"
      :title="`${reviewMode === 'view' ? '查看业务' : '审核业务'} - ${currentReviewBusiness?.businessNo || ''}`"
      width="90%"
    >
      <el-descriptions :column="2" border>
        <el-descriptions-item label="业务编号">{{ currentReviewBusiness?.businessNo }}</el-descriptions-item>
        <el-descriptions-item label="业务名称">{{ currentReviewBusiness?.businessName }}</el-descriptions-item>
        <el-descriptions-item label="业务类型">{{ currentReviewBusiness?.businessTypeName }}</el-descriptions-item>
        <el-descriptions-item label="当前状态">{{ currentReviewBusiness?.statusName }}</el-descriptions-item>
      </el-descriptions>
      <el-alert
        title="该业务类型暂不支持在线审核"
        type="warning"
        :closable="false"
        class="mt-4"
      />
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.pending-approval-container {
  .statistics-overview {
    .stat-card {
      transition: all 0.3s ease;
      
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }
    }
  }

  .search-form {
    :deep(.el-form-item) {
      margin-bottom: 0;
    }
  }

  :deep(.el-tabs__header) {
    margin-bottom: 0;
  }

  // Tab 标签中的徽章样式优化
  :deep(.el-badge) {
    .el-badge__content {
      font-weight: bold;
      animation: pulse 2s infinite;
    }
  }

  // "无"的样式
  .empty-badge {
    color: #999;
    font-size: 12px;
    padding: 0 4px;
  }

  // 徽章脉冲动画
  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.7;
    }
  }
}
</style>
