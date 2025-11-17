<template>
  <Page description="配置 AI 模型的服务提供商和 API 密钥" title="AI 服务商">
    <div class="ai-provider-container">
      <el-card>
        <!-- 搜索和筛选工具栏 -->
        <div class="filter-section">
          <!-- 搜索框 -->
          <div class="search-box">
            <el-input
              v-model="searchQuery"
              placeholder="搜索服务商名称、描述或模型..."
              clearable
              style="width: 100%"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>

          <!-- 快捷分类筛选 -->
          <div class="filter-chips">
            <el-button
              v-for="category in categoryOptions"
              :key="category.value"
              :type="categoryFilter === category.value ? 'primary' : ''"
              :plain="categoryFilter !== category.value"
              size="small"
              @click="categoryFilter = category.value"
            >
              {{ category.label }}
              <el-badge 
                v-if="category.count > 0" 
                :value="category.count" 
                :type="categoryFilter === category.value ? 'primary' : 'info'"
                class="chip-badge" 
              />
            </el-button>
          </div>

          <!-- 高级筛选 -->
          <div class="advanced-filters">
            <el-select v-model="capabilityFilter" placeholder="能力筛选" style="width: 150px" clearable>
              <el-option label="全部能力" value="" />
              <el-option label="视觉理解" value="vision" />
              <el-option label="图像生成" value="image" />
              <el-option label="函数调用" value="functionCall" />
            </el-select>

            <el-button :disabled="isFiltersDefault" @click="resetFilters">
              <el-icon><Refresh /></el-icon>
              重置筛选
            </el-button>

            <el-button type="primary" @click="handleAddProvider">
              <el-icon><Plus /></el-icon>
              新增服务商
            </el-button>
          </div>
        </div>

        <!-- 筛选结果统计 -->
        <div v-if="!isFiltersDefault" class="filter-result-info">
          <el-icon><InfoFilled /></el-icon>
          找到 <strong>{{ filteredProviders.length }}</strong> 个服务商
          <span v-if="searchQuery">（搜索: "{{ searchQuery }}"）</span>
        </div>

        <!-- 统计信息 -->
        <div class="stats-bar">
          <el-tag>共 {{ filteredProviders.length }} 个服务商</el-tag>
          <el-tag type="success">已配置 {{ configuredCount }}</el-tag>
          <el-tag type="info">总计 {{ totalModels }} 个模型</el-tag>
        </div>

        <!-- 服务商列表 -->
        <div v-if="filteredProviders.length === 0" class="empty-state">
          <el-empty description="暂无服务商数据">
            <el-button type="primary" @click="resetFilters">重置筛选条件</el-button>
          </el-empty>
        </div>

        <div v-else class="providers-list">
          <!-- 已配置的服务商 -->
          <div v-if="configuredProviders.length > 0" class="provider-section">
            <div class="provider-section-header">
              <el-icon color="#67c23a"><CircleCheck /></el-icon>
              <span>已配置 ({{ configuredProviders.length }})</span>
            </div>
            <div
              v-for="provider in configuredProviders"
              :key="provider.id"
              class="provider-card"
            >
            <!-- 服务商头部 -->
            <div class="provider-header" @click="toggleProvider(provider.id!)">
              <div class="provider-info">
                <div class="provider-icon">
                  <el-icon><Avatar /></el-icon>
                </div>
                <div class="provider-details">
                  <h4 class="provider-name">{{ provider.providerName }}</h4>
                  <p class="provider-desc">{{ provider.description }}</p>
                  <el-tag v-if="provider.category" size="small">{{ provider.category }}</el-tag>
                </div>
              </div>

              <div class="provider-actions">
                <el-tag v-if="provider.apiKey" type="success">已配置</el-tag>
                <el-tag v-else type="info">未配置</el-tag>
                <el-switch v-model="provider.enabled" :active-value="1" :inactive-value="0" @click.stop @change="handleToggleProvider(provider)" />
                <el-icon v-if="expandedProviders.includes(provider.id!)">
                  <ArrowUp />
                </el-icon>
                <el-icon v-else>
                  <ArrowDown />
                </el-icon>
              </div>
            </div>

            <!-- 服务商配置区域（展开时显示） -->
            <div v-if="expandedProviders.includes(provider.id!)" class="provider-config">
              <!-- API Key -->
              <el-form :model="provider" label-width="120px">
                <el-form-item label="API Key">
                  <div style="display: flex; gap: 8px; width: 100%">
                    <el-input
                      v-model="provider.apiKey"
                      :type="showApiKey[provider.id!] ? 'text' : 'password'"
                      placeholder="请输入 API Key"
                      style="flex: 1"
                    />
                    <el-button @click="toggleApiKeyVisibility(provider.id!)">
                      <el-icon v-if="showApiKey[provider.id!]"><Hide /></el-icon>
                      <el-icon v-else><View /></el-icon>
                    </el-button>
                  </div>
                  <div style="margin-top: 4px">
                    <el-link :href="provider.website" target="_blank" type="primary">
                      获取 API Key
                    </el-link>
                  </div>
                </el-form-item>

                <el-form-item label="端点 URL">
                  <el-input v-model="provider.endpoint" placeholder="API 端点（可选）" />
                  <div style="color: #999; font-size: 12px; margin-top: 4px">
                    留空使用默认端点
                  </div>
                </el-form-item>

                <!-- 模型列表 -->
                <el-form-item label="支持的模型">
                  <div style="width: 100%">
                    <div style="margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center">
                      <span>共 {{ getFilteredModels(provider).length }} 个模型</span>
                      <el-button size="small" @click="toggleModelList(provider.id!)">
                        {{ expandedModels[provider.id!] ? '收起' : '展开' }}详情
                      </el-button>
                    </div>

                    <!-- 简要模型列表 -->
                    <div v-if="!expandedModels[provider.id!]" class="models-brief">
                      <el-tag
                        v-for="model in getFilteredModels(provider).slice(0, 3)"
                        :key="model.id"
                        size="small"
                        style="margin-right: 8px; margin-bottom: 8px"
                        :type="model.recommended === 1 ? 'warning' : ''"
                      >
                        {{ model.modelName }}
                      </el-tag>
                      <el-tag v-if="getFilteredModels(provider).length > 3" size="small">
                        +{{ getFilteredModels(provider).length - 3 }} 更多
                      </el-tag>
                    </div>

                    <!-- 详细模型列表 -->
                    <div v-else class="models-detail">
                      <!-- 模型筛选工具栏 -->
                      <div class="model-filter-toolbar">
                        <el-input
                          v-model="modelSearchQuery[provider.id!]"
                          placeholder="搜索模型名称、ID..."
                          size="small"
                          clearable
                          style="width: 250px; margin-right: 8px"
                        >
                          <template #prefix>
                            <el-icon><Search /></el-icon>
                          </template>
                        </el-input>

                        <el-select
                          v-model="modelPriceFilter[provider.id!]"
                          placeholder="价格筛选"
                          size="small"
                          style="width: 150px"
                          clearable
                        >
                          <el-option label="全部价格" value="" />
                          <el-option label="免费" value="free" />
                          <el-option label="低价 ($0-$1)" value="low" />
                          <el-option label="中等 ($1-$10)" value="medium" />
                          <el-option label="高价 (>$10)" value="high" />
                        </el-select>
                      </div>

                      <el-table :data="getFilteredModels(provider)" border size="small" style="margin-top: 8px">
                        <el-table-column prop="modelName" label="模型名称" min-width="150">
                          <template #default="scope">
                            <div>
                              {{ scope.row.modelName }}
                              <el-tag v-if="scope.row.recommended === 1" type="warning" size="small" style="margin-left: 8px">推荐</el-tag>
                            </div>
                            <div v-if="scope.row.description" style="color: #999; font-size: 12px">
                              {{ scope.row.description }}
                            </div>
                          </template>
                        </el-table-column>
                        <el-table-column prop="contextWindow" label="上下文" width="100">
                          <template #default="scope">
                            {{ formatContextWindow(scope.row.contextWindow) }}
                          </template>
                        </el-table-column>
                        <el-table-column label="能力" width="150">
                          <template #default="scope">
                            <el-tag v-if="scope.row.capabilityText === 1" size="small" style="margin-right: 4px">文本</el-tag>
                            <el-tag v-if="scope.row.capabilityImage === 1" size="small" style="margin-right: 4px">图片</el-tag>
                            <el-tag v-if="scope.row.capabilityVision === 1" size="small" style="margin-right: 4px">视觉</el-tag>
                            <el-tag v-if="scope.row.capabilityFunctionCall === 1" size="small">函数</el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column label="价格" width="120">
                          <template #default="scope">
                            <div v-if="scope.row.priceInput && scope.row.priceOutput" style="font-size: 12px">
                              ${{ scope.row.priceInput?.toFixed(2) }} / ${{ scope.row.priceOutput?.toFixed(2) }}
                            </div>
                            <div v-else>-</div>
                          </template>
                        </el-table-column>
                        <el-table-column label="启用" width="80" fixed="right">
                          <template #default="scope">
                            <el-switch
                              v-model="scope.row.enabled"
                              :active-value="1"
                              :inactive-value="0"
                              @change="handleToggleModel(scope.row)"
                            />
                          </template>
                        </el-table-column>
                      </el-table>
                    </div>
                  </div>
                </el-form-item>
              </el-form>

              <!-- 操作按钮 -->
              <div class="config-actions">
                <el-button type="primary" @click="handleSaveConfig(provider)" :loading="saving">
                  保存配置
                </el-button>
                <el-button 
                  :disabled="!provider.apiKey || refreshingModels[provider.id!]"
                  :loading="refreshingModels[provider.id!]"
                  @click="handleRefreshModels(provider)"
                >
                  <template #icon>
                    <el-icon><Refresh /></el-icon>
                  </template>
                  {{ refreshingModels[provider.id!] ? '刷新中...' : '刷新模型' }}
                </el-button>
                <el-button @click="handleTestConnection(provider)" :loading="testing[provider.id!]">
                  测试连接
                </el-button>
                <el-button @click="handleClearConfig(provider)">
                  清除配置
                </el-button>
              </div>
            </div>
            </div>
          </div>

          <!-- 未配置的服务商 -->
          <div v-if="unconfiguredProviders.length > 0" class="provider-section">
            <div class="provider-section-header">
              <el-icon color="#909399"><InfoFilled /></el-icon>
              <span>未配置 ({{ unconfiguredProviders.length }})</span>
            </div>
            <div
              v-for="provider in unconfiguredProviders"
              :key="provider.id"
              class="provider-card"
            >
            <!-- 服务商头部 -->
            <div class="provider-header" @click="toggleProvider(provider.id!)">
              <div class="provider-info">
                <div class="provider-icon">
                  <el-icon><Avatar /></el-icon>
                </div>
                <div class="provider-details">
                  <h4 class="provider-name">{{ provider.providerName }}</h4>
                  <p class="provider-desc">{{ provider.description }}</p>
                  <el-tag v-if="provider.category" size="small">{{ provider.category }}</el-tag>
                </div>
              </div>

              <div class="provider-actions">
                <el-tag v-if="provider.apiKey" type="success">已配置</el-tag>
                <el-tag v-else type="info">未配置</el-tag>
                <el-switch v-model="provider.enabled" :active-value="1" :inactive-value="0" @click.stop @change="handleToggleProvider(provider)" />
                <el-icon v-if="expandedProviders.includes(provider.id!)">
                  <ArrowUp />
                </el-icon>
                <el-icon v-else>
                  <ArrowDown />
                </el-icon>
              </div>
            </div>

            <!-- 服务商配置区域（展开时显示） -->
            <div v-if="expandedProviders.includes(provider.id!)" class="provider-config">
              <!-- API Key -->
              <el-form :model="provider" label-width="120px">
                <el-form-item label="API Key">
                  <div style="display: flex; gap: 8px; width: 100%">
                    <el-input
                      v-model="provider.apiKey"
                      :type="showApiKey[provider.id!] ? 'text' : 'password'"
                      placeholder="请输入 API Key"
                      style="flex: 1"
                    />
                    <el-button @click="toggleApiKeyVisibility(provider.id!)">
                      <el-icon v-if="showApiKey[provider.id!]"><Hide /></el-icon>
                      <el-icon v-else><View /></el-icon>
                    </el-button>
                  </div>
                  <div style="margin-top: 4px">
                    <el-link :href="provider.website" target="_blank" type="primary">
                      获取 API Key
                    </el-link>
                  </div>
                </el-form-item>

                <el-form-item label="端点 URL">
                  <el-input v-model="provider.endpoint" placeholder="API 端点（可选）" />
                  <div style="color: #999; font-size: 12px; margin-top: 4px">
                    留空使用默认端点
                  </div>
                </el-form-item>

                <!-- 模型列表 -->
                <el-form-item label="支持的模型">
                  <div style="width: 100%">
                    <div style="margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center">
                      <span>共 {{ getFilteredModels(provider).length }} 个模型</span>
                      <el-button size="small" @click="toggleModelList(provider.id!)">
                        {{ expandedModels[provider.id!] ? '收起' : '展开' }}详情
                      </el-button>
                    </div>

                    <!-- 简要模型列表 -->
                    <div v-if="!expandedModels[provider.id!]" class="models-brief">
                      <el-tag
                        v-for="model in getFilteredModels(provider).slice(0, 3)"
                        :key="model.id"
                        size="small"
                        style="margin-right: 8px; margin-bottom: 8px"
                        :type="model.recommended === 1 ? 'warning' : ''"
                      >
                        {{ model.modelName }}
                      </el-tag>
                      <el-tag v-if="getFilteredModels(provider).length > 3" size="small">
                        +{{ getFilteredModels(provider).length - 3 }} 更多
                      </el-tag>
                    </div>

                    <!-- 详细模型列表 -->
                    <div v-else class="models-detail">
                      <!-- 模型筛选工具栏 -->
                      <div class="model-filter-toolbar">
                        <el-input
                          v-model="modelSearchQuery[provider.id!]"
                          placeholder="搜索模型名称、ID..."
                          size="small"
                          clearable
                          style="width: 250px; margin-right: 8px"
                        >
                          <template #prefix>
                            <el-icon><Search /></el-icon>
                          </template>
                        </el-input>

                        <el-select
                          v-model="modelPriceFilter[provider.id!]"
                          placeholder="价格筛选"
                          size="small"
                          style="width: 150px"
                          clearable
                        >
                          <el-option label="全部价格" value="" />
                          <el-option label="免费" value="free" />
                          <el-option label="低价 ($0-$1)" value="low" />
                          <el-option label="中等 ($1-$10)" value="medium" />
                          <el-option label="高价 (>$10)" value="high" />
                        </el-select>
                      </div>

                      <el-table :data="getFilteredModels(provider)" border size="small" style="margin-top: 8px">
                        <el-table-column prop="modelName" label="模型名称" min-width="150">
                          <template #default="scope">
                            <div>
                              {{ scope.row.modelName }}
                              <el-tag v-if="scope.row.recommended === 1" type="warning" size="small" style="margin-left: 8px">推荐</el-tag>
                            </div>
                            <div v-if="scope.row.description" style="color: #999; font-size: 12px">
                              {{ scope.row.description }}
                            </div>
                          </template>
                        </el-table-column>
                        <el-table-column prop="contextWindow" label="上下文" width="100">
                          <template #default="scope">
                            {{ formatContextWindow(scope.row.contextWindow) }}
                          </template>
                        </el-table-column>
                        <el-table-column label="能力" width="150">
                          <template #default="scope">
                            <el-tag v-if="scope.row.capabilityText === 1" size="small" style="margin-right: 4px">文本</el-tag>
                            <el-tag v-if="scope.row.capabilityImage === 1" size="small" style="margin-right: 4px">图片</el-tag>
                            <el-tag v-if="scope.row.capabilityVision === 1" size="small" style="margin-right: 4px">视觉</el-tag>
                            <el-tag v-if="scope.row.capabilityFunctionCall === 1" size="small">函数</el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column label="价格" width="120">
                          <template #default="scope">
                            <div v-if="scope.row.priceInput && scope.row.priceOutput" style="font-size: 12px">
                              ${{ scope.row.priceInput?.toFixed(2) }} / ${{ scope.row.priceOutput?.toFixed(2) }}
                            </div>
                            <div v-else>-</div>
                          </template>
                        </el-table-column>
                        <el-table-column label="启用" width="80" fixed="right">
                          <template #default="scope">
                            <el-switch
                              v-model="scope.row.enabled"
                              :active-value="1"
                              :inactive-value="0"
                              @change="handleToggleModel(scope.row)"
                            />
                          </template>
                        </el-table-column>
                      </el-table>
                    </div>
                  </div>
                </el-form-item>
              </el-form>

              <!-- 操作按钮 -->
              <div class="config-actions">
                <el-button type="primary" @click="handleSaveConfig(provider)" :loading="saving">
                  保存配置
                </el-button>
                <el-button 
                  :disabled="!provider.apiKey || refreshingModels[provider.id!]"
                  :loading="refreshingModels[provider.id!]"
                  @click="handleRefreshModels(provider)"
                >
                  <template #icon>
                    <el-icon><Refresh /></el-icon>
                  </template>
                  {{ refreshingModels[provider.id!] ? '刷新中...' : '刷新模型' }}
                </el-button>
                <el-button @click="handleTestConnection(provider)" :loading="testing[provider.id!]">
                  测试连接
                </el-button>
                <el-button @click="handleClearConfig(provider)">
                  清除配置
                </el-button>
              </div>
            </div>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 新增/编辑服务商对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogTitle"
        width="600px"
        @close="resetForm"
      >
        <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
          <el-form-item label="服务商标识" prop="providerKey">
            <el-input v-model="formData.providerKey" placeholder="如: openai" />
          </el-form-item>
          <el-form-item label="服务商名称" prop="providerName">
            <el-input v-model="formData.providerName" placeholder="如: OpenAI" />
          </el-form-item>
          <el-form-item label="描述">
            <el-input v-model="formData.description" type="textarea" :rows="2" />
          </el-form-item>
          <el-form-item label="官网地址">
            <el-input v-model="formData.website" placeholder="https://..." />
          </el-form-item>
          <el-form-item label="端点URL">
            <el-input v-model="formData.endpoint" placeholder="https://api.example.com" />
          </el-form-item>
          <el-form-item label="分类">
            <el-select v-model="formData.category" style="width: 100%">
              <el-option label="国际" value="international" />
              <el-option label="中国" value="chinese" />
              <el-option label="中国扩展" value="chinese-extended" />
              <el-option label="平台" value="platform" />
              <el-option label="云服务" value="cloud" />
              <el-option label="开源" value="opensource" />
              <el-option label="专业" value="specialized" />
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
import { ref, reactive, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Search, Plus, Avatar, ArrowUp, ArrowDown, View, Hide, Refresh, InfoFilled, CircleCheck } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';
import { aiProviderApi, type AiProvider, type AiModel } from '#/api/ai/provider';

// 筛选和搜索
const searchQuery = ref('');
const categoryFilter = ref('all');
const capabilityFilter = ref('');

// 模型筛选（每个服务商独立）
const modelSearchQuery = reactive<Record<string, string>>({});
const modelPriceFilter = reactive<Record<string, string>>({});

// 数据
const providers = ref<AiProvider[]>([]);
const expandedProviders = ref<string[]>([]);
const expandedModels = reactive<Record<string, boolean>>({});
const showApiKey = reactive<Record<string, boolean>>({});
const testing = reactive<Record<string, boolean>>({});
const refreshingModels = reactive<Record<string, boolean>>({});
const saving = ref(false);
const dialogVisible = ref(false);
const dialogTitle = ref('新增服务商');
const formRef = ref();

const formData = reactive<AiProvider>({
  providerKey: '',
  providerName: '',
  description: '',
  website: '',
  endpoint: '',
  category: 'international',
  enabled: 1,
  status: 'ACTIVE',
});

const formRules = {
  providerKey: [{ required: true, message: '请输入服务商标识', trigger: 'blur' }],
  providerName: [{ required: true, message: '请输入服务商名称', trigger: 'blur' }],
};

// 分类选项（动态统计数量）
const categoryOptions = computed(() => {
  const all = providers.value.length;
  const international = providers.value.filter(p => p.category === 'international').length;
  // 中国包含 chinese 和 chinese-extended
  const chinese = providers.value.filter(p => p.category === 'chinese' || p.category === 'chinese-extended').length;
  const platforms = providers.value.filter(p => p.category === 'platform').length;
  const cloud = providers.value.filter(p => p.category === 'cloud').length;
  const opensource = providers.value.filter(p => p.category === 'opensource').length;
  const specialized = providers.value.filter(p => p.category === 'specialized').length;

  return [
    { label: '全部', value: 'all', count: all },
    { label: '国际', value: 'international', count: international },
    { label: '中国', value: 'chinese', count: chinese },
    { label: '平台', value: 'platform', count: platforms },
    { label: '云服务', value: 'cloud', count: cloud },
    { label: '开源', value: 'opensource', count: opensource },
    { label: '专业', value: 'specialized', count: specialized },
  ];
});

// 过滤后的服务商列表
const filteredProviders = computed(() => {
  let result = providers.value;

  // 分类筛选
  if (categoryFilter.value && categoryFilter.value !== 'all') {
    if (categoryFilter.value === 'chinese') {
      // 中国分类包含 chinese 和 chinese-extended
      result = result.filter((p) => p.category === 'chinese' || p.category === 'chinese-extended');
    } else {
      result = result.filter((p) => p.category === categoryFilter.value);
    }
  }

  // 搜索筛选
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    result = result.filter((p) => {
      const matchName = p.providerName?.toLowerCase().includes(query);
      const matchDesc = p.description?.toLowerCase().includes(query);
      const matchModel = p.models?.some((m) => 
        m.modelName?.toLowerCase().includes(query) ||
        m.modelKey?.toLowerCase().includes(query)
      );
      return matchName || matchDesc || matchModel;
    });
  }

  // 能力筛选
  if (capabilityFilter.value) {
    result = result.filter((p) => {
      return p.models?.some((m) => {
        switch (capabilityFilter.value) {
          case 'vision':
            return m.capabilityVision === 1;
          case 'image':
            return m.capabilityImage === 1;
          case 'functionCall':
            return m.capabilityFunctionCall === 1;
          default:
            return true;
        }
      });
    });
  }

  return result;
});

// 检查是否为默认筛选状态
const isFiltersDefault = computed(() => {
  return !searchQuery.value && (categoryFilter.value === 'all' || !categoryFilter.value) && !capabilityFilter.value;
});

// 重置筛选
const resetFilters = () => {
  searchQuery.value = '';
  categoryFilter.value = 'all';
  capabilityFilter.value = '';
};

// 已配置的服务商（有API Key）
const configuredProviders = computed(() => {
  return filteredProviders.value.filter((p) => p.apiKey);
});

// 未配置的服务商（没有API Key）
const unconfiguredProviders = computed(() => {
  return filteredProviders.value.filter((p) => !p.apiKey);
});

// 统计信息
const configuredCount = computed(() => {
  return providers.value.filter((p) => p.apiKey).length;
});

const totalModels = computed(() => {
  return providers.value.reduce((sum, p) => sum + (p.models?.length || 0), 0);
});

// 格式化上下文窗口
const formatContextWindow = (contextWindow?: number) => {
  if (!contextWindow) return '-';
  if (contextWindow >= 1000000) {
    return `${(contextWindow / 1000000).toFixed(1)}M`;
  }
  if (contextWindow >= 1000) {
    return `${(contextWindow / 1000).toFixed(0)}K`;
  }
  return contextWindow.toString();
};

// 加载数据
const loadData = async () => {
  try {
    providers.value = await aiProviderApi.getAllProviders();
  } catch (error: any) {
    ElMessage.error('加载失败');
  }
};

// 切换服务商展开/收起
const toggleProvider = (id: string) => {
  const index = expandedProviders.value.indexOf(id);
  if (index > -1) {
    expandedProviders.value.splice(index, 1);
  } else {
    expandedProviders.value.push(id);
  }
};

// 切换模型列表
const toggleModelList = (id: string) => {
  expandedModels[id] = !expandedModels[id];
  
  // 初始化筛选状态
  if (expandedModels[id]) {
    if (!modelSearchQuery[id]) {
      modelSearchQuery[id] = '';
    }
    if (!modelPriceFilter[id]) {
      modelPriceFilter[id] = '';
    }
  }
};

// 获取筛选后的模型列表
const getFilteredModels = (provider: AiProvider): AiModel[] => {
  let result = provider.models || [];

  const providerId = provider.id!;
  
  // 按搜索关键词过滤
  const searchQuery = modelSearchQuery[providerId]?.trim().toLowerCase();
  if (searchQuery) {
    result = result.filter((model) => {
      const matchesName = model.modelName?.toLowerCase().includes(searchQuery);
      const matchesKey = model.modelKey?.toLowerCase().includes(searchQuery);
      const matchesDesc = model.description?.toLowerCase().includes(searchQuery);
      return matchesName || matchesKey || matchesDesc;
    });
  }

  // 按价格筛选
  const priceFilter = modelPriceFilter[providerId];
  if (priceFilter) {
    result = result.filter((model) => {
      if (!model.priceInput || !model.priceOutput) {
        return priceFilter === 'free'; // 无价格信息的视为免费
      }

      // 计算平均价格（输入+输出）/2
      const avgPrice = (Number(model.priceInput) + Number(model.priceOutput)) / 2;

      switch (priceFilter) {
        case 'free':
          return avgPrice === 0;
        case 'low':
          return avgPrice > 0 && avgPrice <= 1; // $0-$1/1M tokens
        case 'medium':
          return avgPrice > 1 && avgPrice <= 10; // $1-$10/1M tokens
        case 'high':
          return avgPrice > 10; // >$10/1M tokens
        default:
          return true;
      }
    });
  }

  return result;
};

// 切换API Key显示
const toggleApiKeyVisibility = (id: string) => {
  showApiKey[id] = !showApiKey[id];
};

// 切换服务商启用状态
const handleToggleProvider = async (provider: AiProvider) => {
  try {
    await aiProviderApi.updateProviderConfig(provider.id!, {
      enabled: provider.enabled,
    });
    ElMessage.success('状态已更新');
  } catch (error: any) {
    ElMessage.error(error.message || '更新失败');
    // 恢复状态
    provider.enabled = provider.enabled === 1 ? 0 : 1;
  }
};

// 切换模型启用状态
const handleToggleModel = async (model: AiModel) => {
  try {
    await aiProviderApi.toggleModel(model.id!, model.enabled!);
    ElMessage.success('模型状态已更新');
  } catch (error: any) {
    ElMessage.error(error.message || '更新失败');
    // 恢复状态
    model.enabled = model.enabled === 1 ? 0 : 1;
  }
};

// 保存配置
const handleSaveConfig = async (provider: AiProvider) => {
  try {
    saving.value = true;
    await aiProviderApi.updateProviderConfig(provider.id!, {
      apiKey: provider.apiKey,
      endpoint: provider.endpoint,
    });
    ElMessage.success('配置已保存');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 测试连接
const handleTestConnection = async (provider: AiProvider) => {
  if (!provider.apiKey) {
    ElMessage.warning('请先配置 API Key');
    return;
  }

  testing[provider.id!] = true;
  try {
    // TODO: 实际的测试接口
    await new Promise((resolve) => setTimeout(resolve, 1500));
    ElMessage.success('连接测试成功');
  } catch (error: any) {
    ElMessage.error('连接测试失败');
  } finally {
    testing[provider.id!] = false;
  }
};

// 清除配置
const handleClearConfig = async (provider: AiProvider) => {
  try {
    await ElMessageBox.confirm('确定要清除该服务商的配置吗？', '确认', {
      type: 'warning',
    });

    await aiProviderApi.clearProviderConfig(provider.id!);
    provider.apiKey = '';
    ElMessage.success('配置已清除');
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '清除失败');
    }
  }
};

// 刷新模型列表
const handleRefreshModels = async (provider: AiProvider) => {
  if (!provider.apiKey) {
    ElMessage.warning('请先配置 API Key');
    return;
  }

  if (!provider.id) {
    ElMessage.error('服务商ID不存在');
    return;
  }

  refreshingModels[provider.id] = true;
  
  try {
    const updatedProvider = await aiProviderApi.refreshModels(provider.id);
    
    // 更新当前服务商的模型列表
    if (updatedProvider && updatedProvider.models) {
      provider.models = updatedProvider.models;
      ElMessage.success(`成功刷新 ${updatedProvider.models.length} 个模型`);
      
      // 重新加载数据以确保同步
      await loadData();
    } else {
      ElMessage.info('暂无可用模型');
    }
  } catch (error: any) {
    console.error('刷新模型列表失败:', error);
    ElMessage.error(error.message || '刷新模型列表失败');
  } finally {
    refreshingModels[provider.id] = false;
  }
};

// 新增服务商
const handleAddProvider = () => {
  dialogTitle.value = '新增服务商';
  resetForm();
  dialogVisible.value = true;
};

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value?.validate();
    await aiProviderApi.saveProvider(formData);
    ElMessage.success('保存成功');
    dialogVisible.value = false;
    loadData();
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  }
};

// 重置表单
const resetForm = () => {
  formRef.value?.resetFields();
  Object.assign(formData, {
    providerKey: '',
    providerName: '',
    description: '',
    website: '',
    endpoint: '',
    category: 'international',
    enabled: 1,
    status: 'ACTIVE',
  });
};

onMounted(() => {
  loadData();
});
</script>

<style lang="scss" scoped>
.ai-provider-container {
  padding: 16px;
}

// 筛选区域
.filter-section {
  margin-bottom: 16px;
}

.search-box {
  margin-bottom: 12px;
}

.filter-chips {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 12px;

  .chip-badge {
    margin-left: 4px;
  }
}

.advanced-filters {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}

.filter-result-info {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  margin-bottom: 12px;
  background-color: var(--el-color-primary-light-9);
  border-left: 3px solid var(--el-color-primary);
  border-radius: 4px;
  font-size: 14px;
  color: var(--el-text-color-regular);

  strong {
    color: var(--el-color-primary);
  }
}

.stats-bar {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

// 模型筛选工具栏
.model-filter-toolbar {
  display: flex;
  gap: 8px;
  align-items: center;
  padding: 12px;
  background-color: var(--el-fill-color-lighter);
  border-radius: 4px;
}

.providers-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.provider-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.provider-section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  background-color: var(--el-fill-color-lighter);
  border-radius: 4px;
  border-left: 3px solid var(--el-color-primary);

  span {
    flex: 1;
  }
}

.provider-card {
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--el-bg-color);
  transition: box-shadow 0.3s;

  &:hover {
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  }
}

.provider-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  cursor: pointer;
  transition: background-color 0.3s;

  &:hover {
    background-color: var(--el-fill-color-light);
  }
}

.provider-info {
  display: flex;
  gap: 12px;
  align-items: center;
}

.provider-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color);
  border-radius: 8px;
  font-size: 24px;
  color: var(--el-color-primary);
}

.provider-details {
  h4.provider-name {
    margin: 0 0 4px 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  p.provider-desc {
    margin: 0 0 8px 0;
    font-size: 14px;
    color: var(--el-text-color-regular);
  }
}

.provider-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.provider-config {
  padding: 16px;
  border-top: 1px solid var(--el-border-color-light);
  background-color: var(--el-fill-color-light);
}

.models-brief {
  display: flex;
  flex-wrap: wrap;
}

.models-detail {
  width: 100%;
}

.config-actions {
  display: flex;
  gap: 12px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--el-border-color-light);
}

.empty-state {
  padding: 40px;
  text-align: center;
  color: var(--el-text-color-secondary);
}
</style>

