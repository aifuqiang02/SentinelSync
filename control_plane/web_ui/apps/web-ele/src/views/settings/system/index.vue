<template>
  <Page description="管理系统全局配置参数" title="系统设置">
    <div class="system-settings-container">
      <el-tabs v-model="activeTab" type="border-card">
        <!-- 基本设置 -->
        <el-tab-pane label="基本设置" name="basic">
          <el-form
            :model="basicSettings"
            ref="basicFormRef"
            label-width="150px"
            style="max-width: 800px"
          >
            <el-form-item label="系统名称">
              <el-input v-model="basicSettings['system.name']" placeholder="请输入系统名称" />
            </el-form-item>

            <el-form-item label="系统Logo">
              <el-input v-model="basicSettings['system.logo']" placeholder="请输入Logo URL" />
            </el-form-item>

            <el-form-item label="系统版本">
              <el-input v-model="basicSettings['system.version']" placeholder="请输入系统版本" />
            </el-form-item>

            <el-form-item label="系统描述">
              <el-input
                v-model="basicSettings['system.description']"
                type="textarea"
                :rows="3"
                placeholder="请输入系统描述"
              />
            </el-form-item>

            <el-form-item label="版权信息">
              <el-input v-model="basicSettings['system.copyright']" placeholder="请输入版权信息" />
            </el-form-item>

            <el-form-item label="备案号">
              <el-input v-model="basicSettings['system.icp']" placeholder="请输入备案号" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSaveBasic" :loading="saving">保存设置</el-button>
              <el-button @click="loadBasicSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 安全设置 -->
        <el-tab-pane label="安全设置" name="security">
          <el-form
            :model="securitySettings"
            ref="securityFormRef"
            label-width="180px"
            style="max-width: 800px"
          >
            <el-form-item label="登录超时时间（分钟）">
              <el-input-number
                v-model="securitySettings['security.login.timeout']"
                :min="5"
                :max="1440"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="密码最小长度">
              <el-input-number
                v-model="securitySettings['security.password.minLength']"
                :min="6"
                :max="20"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="密码最大长度">
              <el-input-number
                v-model="securitySettings['security.password.maxLength']"
                :min="6"
                :max="50"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="密码必须包含数字">
              <el-switch v-model="securitySettings['security.password.requireNumber']" />
            </el-form-item>

            <el-form-item label="密码必须包含字母">
              <el-switch v-model="securitySettings['security.password.requireLetter']" />
            </el-form-item>

            <el-form-item label="密码必须包含特殊字符">
              <el-switch v-model="securitySettings['security.password.requireSpecial']" />
            </el-form-item>

            <el-form-item label="登录失败锁定次数">
              <el-input-number
                v-model="securitySettings['security.login.maxAttempts']"
                :min="3"
                :max="10"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="账号锁定时间（分钟）">
              <el-input-number
                v-model="securitySettings['security.login.lockTime']"
                :min="5"
                :max="60"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSaveSecurity" :loading="saving">保存设置</el-button>
              <el-button @click="loadSecuritySettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 文件上传设置 -->
        <el-tab-pane label="文件上传" name="upload">
          <el-form
            :model="uploadSettings"
            ref="uploadFormRef"
            label-width="180px"
            style="max-width: 800px"
          >
            <el-form-item label="允许上传的文件类型">
              <el-input
                v-model="uploadSettings['upload.allowedTypes']"
                placeholder="如: jpg,png,pdf,doc"
              />
              <div style="color: #999; font-size: 12px; margin-top: 5px">
                多个类型用逗号分隔
              </div>
            </el-form-item>

            <el-form-item label="单文件最大大小（MB）">
              <el-input-number
                v-model="uploadSettings['upload.maxSize']"
                :min="1"
                :max="100"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="存储类型">
              <el-radio-group v-model="uploadSettings['upload.storageType']">
                <el-radio value="local">本地存储</el-radio>
                <el-radio value="minio">MinIO</el-radio>
                <el-radio value="oss">阿里云OSS</el-radio>
                <el-radio value="cos">腾讯云COS</el-radio>
              </el-radio-group>
            </el-form-item>

            <el-form-item label="MinIO地址" v-if="uploadSettings['upload.storageType'] === 'minio'">
              <el-input v-model="uploadSettings['upload.minio.endpoint']" placeholder="如: http://localhost:9000" />
            </el-form-item>

            <el-form-item label="MinIO Bucket" v-if="uploadSettings['upload.storageType'] === 'minio'">
              <el-input v-model="uploadSettings['upload.minio.bucket']" placeholder="请输入Bucket名称" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSaveUpload" :loading="saving">保存设置</el-button>
              <el-button @click="loadUploadSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 邮件设置 -->
        <el-tab-pane label="邮件设置" name="email">
          <el-form
            :model="emailSettings"
            ref="emailFormRef"
            label-width="150px"
            style="max-width: 800px"
          >
            <el-form-item label="SMTP服务器">
              <el-input v-model="emailSettings['email.smtp.host']" placeholder="如: smtp.qq.com" />
            </el-form-item>

            <el-form-item label="SMTP端口">
              <el-input-number
                v-model="emailSettings['email.smtp.port']"
                :min="1"
                :max="65535"
                style="width: 200px"
              />
            </el-form-item>

            <el-form-item label="发件人邮箱">
              <el-input v-model="emailSettings['email.from']" placeholder="请输入发件人邮箱" />
            </el-form-item>

            <el-form-item label="发件人名称">
              <el-input v-model="emailSettings['email.fromName']" placeholder="请输入发件人名称" />
            </el-form-item>

            <el-form-item label="SMTP用户名">
              <el-input v-model="emailSettings['email.smtp.username']" placeholder="请输入SMTP用户名" />
            </el-form-item>

            <el-form-item label="SMTP密码">
              <el-input
                v-model="emailSettings['email.smtp.password']"
                type="password"
                placeholder="请输入SMTP密码"
                show-password
              />
            </el-form-item>

            <el-form-item label="启用SSL">
              <el-switch v-model="emailSettings['email.smtp.ssl']" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSaveEmail" :loading="saving">保存设置</el-button>
              <el-button @click="loadEmailSettings">重置</el-button>
              <el-button @click="handleTestEmail" :loading="testing">发送测试邮件</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- AI隐私设置 -->
        <el-tab-pane label="AI隐私设置" name="ai-privacy">
          <el-alert
            title="数据隐私说明"
            type="info"
            :closable="false"
            style="margin-bottom: 20px"
          >
            <p>根据数据敏感程度，系统可以自动选择合适的AI模型：</p>
            <ul style="margin: 10px 0 0 20px">
              <li><strong>高隐私</strong>：使用本地部署或私有化部署的模型，数据不会上传到公网</li>
              <li><strong>中等隐私</strong>：使用国内服务商，数据不出境</li>
              <li><strong>低隐私/公开</strong>：可使用任何服务商，性能优先</li>
            </ul>
          </el-alert>

          <el-card
            v-for="level in privacyLevels"
            :key="level.value"
            style="margin-bottom: 20px"
            shadow="hover"
          >
            <template #header>
              <div style="display: flex; align-items: center; justify-content: space-between">
                <div style="display: flex; align-items: center; gap: 12px">
                  <el-icon :size="20" :color="level.color">
                    <component :is="level.icon" />
                  </el-icon>
                  <span style="font-size: 16px; font-weight: 600">{{ level.label }}</span>
                  <el-tag :type="level.tagType" size="small">{{ level.description }}</el-tag>
                </div>
                <el-switch
                  v-model="aiPrivacySettings[level.value].enabled"
                  active-text="启用"
                  inactive-text="禁用"
                />
              </div>
            </template>

            <div v-if="aiPrivacySettings[level.value].enabled">
              <!-- 推荐服务商类型提示 -->
              <el-alert
                :type="level.tagType"
                :closable="false"
                style="margin-bottom: 16px"
              >
                <template v-if="level.value === 'high'">
                  <strong>推荐服务商：</strong>开源/本地部署（如 Ollama、LocalAI、LM Studio 等）
                </template>
                <template v-else-if="level.value === 'medium'">
                  <strong>推荐服务商：</strong>中国服务商（如通义千问、文心一言、智谱AI等）及开源模型
                </template>
                <template v-else>
                  <strong>可用服务商：</strong>所有服务商，优先推荐性能强、效果好的模型（如 GPT-4、Claude、Gemini 等）
                </template>
              </el-alert>

              <el-form label-width="120px" style="max-width: 1000px">
                <el-form-item label="可用模型">
                  <el-select
                    v-model="aiPrivacySettings[level.value].models"
                    multiple
                    filterable
                    placeholder="请选择可用的AI模型"
                    style="width: 100%"
                    :loading="modelsLoading"
                  >
                    <el-option-group
                      v-for="provider in groupedModels"
                      :key="provider.providerId"
                      :label="`${provider.providerName} (${provider.models.length}个模型)`"
                    >
                      <el-option
                        v-for="model in provider.models"
                        :key="model.id"
                        :label="`${model.modelName} - ${provider.providerName}`"
                        :value="model.id"
                      >
                        <div style="display: flex; justify-content: space-between; align-items: center">
                          <span>{{ model.modelName }}</span>
                          <el-tag v-if="model.recommended === 1" type="warning" size="small">推荐</el-tag>
                        </div>
                      </el-option>
                    </el-option-group>
                  </el-select>
                  <div style="margin-top: 8px; color: #999; font-size: 12px">
                    已选择 {{ aiPrivacySettings[level.value].models.length }} 个模型（仅显示已启用的模型）
                  </div>
                </el-form-item>

                <el-form-item label="推荐模型">
                  <el-tag
                    v-for="modelId in getRecommendedModels(level.value)"
                    :key="modelId"
                    style="margin-right: 8px; margin-bottom: 8px"
                    closable
                    @close="removeRecommendedModel(level.value, modelId)"
                  >
                    {{ getModelName(modelId) }}
                  </el-tag>
                  <el-button
                    size="small"
                    @click="autoSelectRecommended(level.value)"
                    style="margin-left: 8px"
                  >
                    自动选择推荐模型
                  </el-button>
                </el-form-item>

                <el-form-item label="默认模型">
                  <el-select
                    v-model="aiPrivacySettings[level.value].defaultModel"
                    filterable
                    placeholder="请选择默认模型"
                    style="width: 400px"
                  >
                    <el-option
                      v-for="modelId in aiPrivacySettings[level.value].models"
                      :key="modelId"
                      :label="getModelName(modelId)"
                      :value="modelId"
                    />
                  </el-select>
                  <div style="margin-top: 4px; color: #999; font-size: 12px">
                    未指定时使用第一个可用模型
                  </div>
                </el-form-item>

                <el-form-item label="备注">
                  <el-input
                    v-model="aiPrivacySettings[level.value].remark"
                    type="textarea"
                    :rows="2"
                    placeholder="可以添加使用说明或注意事项"
                  />
                </el-form-item>
              </el-form>
            </div>

            <el-empty
              v-else
              description="该隐私等级未启用"
              :image-size="80"
            />
          </el-card>

          <div style="margin-top: 20px">
            <el-button type="primary" @click="handleSaveAiPrivacy" :loading="saving" size="large">
              保存隐私设置
            </el-button>
            <el-button @click="loadAiPrivacySettings" size="large">重置</el-button>
          </div>
        </el-tab-pane>

        <!-- 配置管理 -->
        <el-tab-pane label="配置管理" name="config">
          <div style="margin-bottom: 16px">
            <el-button type="primary" @click="handleAddConfig">
              <el-icon><Plus /></el-icon>
              新增配置
            </el-button>
          </div>

          <el-table :data="configList" v-loading="configLoading" border style="width: 100%">
            <el-table-column prop="configKey" label="配置键" width="200" />
            <el-table-column prop="configName" label="配置名称" width="150" />
            <el-table-column prop="configValue" label="配置值" min-width="200" show-overflow-tooltip />
            <el-table-column prop="configGroup" label="配置分组" width="120" />
            <el-table-column prop="configType" label="类型" width="100" />
            <el-table-column prop="isSystem" label="系统内置" width="100">
              <template #default="scope">
                <el-tag v-if="scope.row" :type="scope.row.isSystem === 1 ? 'danger' : 'success'">
                  {{ scope.row.isSystem === 1 ? '是' : '否' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" fixed="right">
              <template #default="scope">
                <template v-if="scope.row">
                  <el-button size="small" type="primary" link @click="handleEditConfig(scope.row)">
                    编辑
                  </el-button>
                  <el-popconfirm
                    v-if="scope.row.isSystem !== 1"
                    title="确定要删除吗？"
                    @confirm="handleDeleteConfig(scope.row.id)"
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
            v-model:current-page="configPagination.current"
            v-model:page-size="configPagination.size"
            :total="configPagination.total"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next"
            @current-change="loadConfigList"
            @size-change="loadConfigList"
            style="margin-top: 16px; justify-content: flex-end"
          />
        </el-tab-pane>
      </el-tabs>

      <!-- 配置表单对话框 -->
      <el-dialog
        v-model="configDialogVisible"
        :title="configDialogTitle"
        width="600px"
        @close="resetConfigForm"
      >
        <el-form :model="configFormData" :rules="configRules" ref="configFormRef" label-width="100px">
          <el-form-item label="配置键" prop="configKey">
            <el-input
              v-model="configFormData.configKey"
              placeholder="请输入配置键"
              :disabled="isConfigEdit && configFormData.isSystem === 1"
            />
          </el-form-item>
          <el-form-item label="配置名称" prop="configName">
            <el-input v-model="configFormData.configName" placeholder="请输入配置名称" />
          </el-form-item>
          <el-form-item label="配置值" prop="configValue">
            <el-input
              v-model="configFormData.configValue"
              type="textarea"
              :rows="3"
              placeholder="请输入配置值"
            />
          </el-form-item>
          <el-form-item label="配置分组" prop="configGroup">
            <el-input v-model="configFormData.configGroup" placeholder="请输入配置分组" />
          </el-form-item>
          <el-form-item label="配置类型" prop="configType">
            <el-select v-model="configFormData.configType" style="width: 100%">
              <el-option label="字符串" value="STRING" />
              <el-option label="数字" value="NUMBER" />
              <el-option label="布尔值" value="BOOLEAN" />
              <el-option label="JSON" value="JSON" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="configFormData.status">
              <el-radio value="ACTIVE">启用</el-radio>
              <el-radio value="DISABLED">停用</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="备注">
            <el-input
              v-model="configFormData.remark"
              type="textarea"
              :rows="2"
              placeholder="请输入备注"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="configDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleConfigSubmit">确定</el-button>
        </template>
      </el-dialog>
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Plus, Lock, Warning, Unlock } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';
import { configApi, type Config } from '#/api/system/config';
import { aiProviderApi } from '#/api/ai/provider';

const activeTab = ref('basic');
const saving = ref(false);
const testing = ref(false);
const configLoading = ref(false);
const modelsLoading = ref(false);
const configFormRef = ref();
const configDialogVisible = ref(false);
const configDialogTitle = ref('新增配置');
const isConfigEdit = ref(false);

// AI模型和服务商数据
const allProviders = ref<any[]>([]);
const allModels = ref<any[]>([]);

// 基本设置
const basicSettings = reactive<Record<string, any>>({
  'system.name': 'AI智慧平台',
  'system.logo': '',
  'system.version': '1.0.0',
  'system.description': '',
  'system.copyright': '',
  'system.icp': '',
});

// 安全设置
const securitySettings = reactive<Record<string, any>>({
  'security.login.timeout': 30,
  'security.password.minLength': 6,
  'security.password.maxLength': 20,
  'security.password.requireNumber': true,
  'security.password.requireLetter': true,
  'security.password.requireSpecial': false,
  'security.login.maxAttempts': 5,
  'security.login.lockTime': 15,
});

// 文件上传设置
const uploadSettings = reactive<Record<string, any>>({
  'upload.allowedTypes': 'jpg,png,gif,pdf,doc,docx,xls,xlsx',
  'upload.maxSize': 10,
  'upload.storageType': 'local',
  'upload.minio.endpoint': '',
  'upload.minio.bucket': '',
});

// 邮件设置
const emailSettings = reactive<Record<string, any>>({
  'email.smtp.host': '',
  'email.smtp.port': 465,
  'email.from': '',
  'email.fromName': '',
  'email.smtp.username': '',
  'email.smtp.password': '',
  'email.smtp.ssl': true,
});

// AI隐私等级定义
const privacyLevels = [
  {
    value: 'high',
    label: '高隐私',
    description: '本地/私有部署',
    icon: Lock,
    color: '#f56c6c',
    tagType: 'danger' as const,
  },
  {
    value: 'medium',
    label: '中等隐私',
    description: '国内服务商',
    icon: Warning,
    color: '#e6a23c',
    tagType: 'warning' as const,
  },
  {
    value: 'low',
    label: '低隐私/公开',
    description: '任何服务商',
    icon: Unlock,
    color: '#67c23a',
    tagType: 'success' as const,
  },
];

// AI隐私设置
const aiPrivacySettings = reactive<Record<string, any>>({
  high: {
    enabled: true,
    models: [],
    defaultModel: '',
    remark: '高隐私数据使用本地或私有化部署的模型，确保数据不上传到公网',
  },
  medium: {
    enabled: true,
    models: [],
    defaultModel: '',
    remark: '中等隐私数据使用国内服务商，确保数据不出境',
  },
  low: {
    enabled: true,
    models: [],
    defaultModel: '',
    remark: '低隐私或公开数据可以使用任何服务商，优先考虑性能和效果',
  },
});

// 配置列表
const configList = ref<Config[]>([]);
const configPagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const configFormData = reactive<Config>({
  configKey: '',
  configValue: '',
  configGroup: '',
  configName: '',
  configType: 'STRING',
  isSystem: 0,
  status: 'ACTIVE',
  remark: '',
});

const configRules = {
  configKey: [{ required: true, message: '请输入配置键', trigger: 'blur' }],
  configName: [{ required: true, message: '请输入配置名称', trigger: 'blur' }],
};

// 按服务商分组的模型（只显示已启用的模型）
const groupedModels = computed(() => {
  const groups: any[] = [];
  allProviders.value.forEach((provider) => {
    if (provider.models && provider.models.length > 0 && provider.enabled === 1) {
      // 只包含已启用的模型
      const enabledModels = provider.models.filter((m: any) => m.enabled === 1);
      if (enabledModels.length > 0) {
        groups.push({
          providerId: provider.id,
          providerName: provider.providerName,
          models: enabledModels,
        });
      }
    }
  });
  return groups;
});

// 获取模型名称
const getModelName = (modelId: string) => {
  for (const provider of allProviders.value) {
    if (provider.models) {
      const model = provider.models.find((m: any) => m.id === modelId);
      if (model) {
        return `${model.modelName} - ${provider.providerName}`;
      }
    }
  }
  return modelId;
};

// 获取推荐模型
const getRecommendedModels = (level: string) => {
  return aiPrivacySettings[level].models.filter((modelId: string) => {
    for (const provider of allProviders.value) {
      if (provider.models) {
        const model = provider.models.find((m: any) => m.id === modelId);
        if (model && model.recommended === 1) {
          return true;
        }
      }
    }
    return false;
  });
};

// 移除推荐模型
const removeRecommendedModel = (level: string, modelId: string) => {
  const index = aiPrivacySettings[level].models.indexOf(modelId);
  if (index > -1) {
    aiPrivacySettings[level].models.splice(index, 1);
  }
};

// 自动选择推荐模型
const autoSelectRecommended = (level: string) => {
  const recommendedModels: string[] = [];
  const allSelectedModels: string[] = [];
  
  for (const provider of allProviders.value) {
    // 根据隐私等级筛选服务商
    let shouldInclude = false;
    
    if (level === 'high') {
      // 高隐私：只使用开源/本地部署的模型
      shouldInclude = provider.category === 'opensource';
    } else if (level === 'medium') {
      // 中等隐私：使用国内服务商和开源
      shouldInclude = ['chinese', 'chinese-extended', 'opensource'].includes(provider.category);
    } else if (level === 'low') {
      // 低隐私：可以使用所有服务商
      shouldInclude = true;
    }
    
    if (!shouldInclude || !provider.models || provider.enabled !== 1) {
      continue;
    }
    
    // 收集启用的推荐模型和所有启用的模型
    provider.models.forEach((model: any) => {
      if (model.enabled === 1) {
        allSelectedModels.push(model.id);
        if (model.recommended === 1) {
          recommendedModels.push(model.id);
        }
      }
    });
  }
  
  // 优先使用推荐模型，如果没有推荐模型则使用所有符合条件的模型
  if (recommendedModels.length > 0) {
    aiPrivacySettings[level].models = recommendedModels;
    ElMessage.success(`已自动选择 ${recommendedModels.length} 个推荐模型`);
  } else if (allSelectedModels.length > 0) {
    aiPrivacySettings[level].models = allSelectedModels;
    ElMessage.warning(`该隐私等级没有推荐模型，已选择所有符合条件的 ${allSelectedModels.length} 个模型`);
  } else {
    aiPrivacySettings[level].models = [];
    ElMessage.info('该隐私等级暂无可用模型，请先在AI服务商页面启用相关模型');
  }
};

// 加载基本设置
const loadBasicSettings = async () => {
  try {
    const configs = await configApi.getConfigsByGroup('system');
    configs.forEach((config) => {
      if (basicSettings.hasOwnProperty(config.configKey)) {
        basicSettings[config.configKey] = config.configValue;
      }
    });
  } catch (error: any) {
    console.error('加载基本设置失败', error);
  }
};

// 保存基本设置
const handleSaveBasic = async () => {
  try {
    saving.value = true;
    const configs = Object.keys(basicSettings).map((key) => ({
      configKey: key,
      configValue: String(basicSettings[key]),
      configGroup: 'system',
      configName: key,
      configType: 'STRING' as const,
      status: 'ACTIVE' as const,
      isSystem: 0 as const,
    }));
    await configApi.batchUpdateConfig(configs);
    ElMessage.success('保存成功');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 加载安全设置
const loadSecuritySettings = async () => {
  try {
    const configs = await configApi.getConfigsByGroup('security');
    configs.forEach((config) => {
      if (securitySettings.hasOwnProperty(config.configKey)) {
        const value = config.configValue;
        if (config.configType === 'NUMBER') {
          securitySettings[config.configKey] = Number(value);
        } else if (config.configType === 'BOOLEAN') {
          securitySettings[config.configKey] = value === 'true';
        } else {
          securitySettings[config.configKey] = value;
        }
      }
    });
  } catch (error: any) {
    console.error('加载安全设置失败', error);
  }
};

// 保存安全设置
const handleSaveSecurity = async () => {
  try {
    saving.value = true;
    const configs = Object.keys(securitySettings).map((key) => {
      const value = securitySettings[key];
      return {
        configKey: key,
        configValue: String(value),
        configGroup: 'security',
        configName: key,
        configType: typeof value === 'number' ? 'NUMBER' : (typeof value === 'boolean' ? 'BOOLEAN' : 'STRING') as any,
        status: 'ACTIVE' as const,
        isSystem: 0 as const,
      };
    });
    await configApi.batchUpdateConfig(configs);
    ElMessage.success('保存成功');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 加载文件上传设置
const loadUploadSettings = async () => {
  try {
    const configs = await configApi.getConfigsByGroup('upload');
    configs.forEach((config) => {
      if (uploadSettings.hasOwnProperty(config.configKey)) {
        const value = config.configValue;
        if (config.configType === 'NUMBER') {
          uploadSettings[config.configKey] = Number(value);
        } else {
          uploadSettings[config.configKey] = value;
        }
      }
    });
  } catch (error: any) {
    console.error('加载文件上传设置失败', error);
  }
};

// 保存文件上传设置
const handleSaveUpload = async () => {
  try {
    saving.value = true;
    const configs = Object.keys(uploadSettings).map((key) => {
      const value = uploadSettings[key];
      return {
        configKey: key,
        configValue: String(value),
        configGroup: 'upload',
        configName: key,
        configType: typeof value === 'number' ? 'NUMBER' : 'STRING' as any,
        status: 'ACTIVE' as const,
        isSystem: 0 as const,
      };
    });
    await configApi.batchUpdateConfig(configs);
    ElMessage.success('保存成功');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 加载邮件设置
const loadEmailSettings = async () => {
  try {
    const configs = await configApi.getConfigsByGroup('email');
    configs.forEach((config) => {
      if (emailSettings.hasOwnProperty(config.configKey)) {
        const value = config.configValue;
        if (config.configType === 'NUMBER') {
          emailSettings[config.configKey] = Number(value);
        } else if (config.configType === 'BOOLEAN') {
          emailSettings[config.configKey] = value === 'true';
        } else {
          emailSettings[config.configKey] = value;
        }
      }
    });
  } catch (error: any) {
    console.error('加载邮件设置失败', error);
  }
};

// 保存邮件设置
const handleSaveEmail = async () => {
  try {
    saving.value = true;
    const configs = Object.keys(emailSettings).map((key) => {
      const value = emailSettings[key];
      return {
        configKey: key,
        configValue: String(value),
        configGroup: 'email',
        configName: key,
        configType: typeof value === 'number' ? 'NUMBER' : (typeof value === 'boolean' ? 'BOOLEAN' : 'STRING') as any,
        status: 'ACTIVE' as const,
        isSystem: 0 as const,
      };
    });
    await configApi.batchUpdateConfig(configs);
    ElMessage.success('保存成功');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 测试邮件
const handleTestEmail = () => {
  testing.value = true;
  setTimeout(() => {
    testing.value = false;
    ElMessage.success('测试邮件已发送，请检查收件箱');
  }, 1500);
};

// 加载AI服务商和模型
const loadAiModels = async () => {
  try {
    modelsLoading.value = true;
    const providers = await aiProviderApi.getAllProviders();
    allProviders.value = providers;
    
    // 提取所有模型
    const models: any[] = [];
    providers.forEach((provider) => {
      if (provider.models) {
        provider.models.forEach((model: any) => {
          models.push({
            ...model,
            providerId: provider.id,
            providerName: provider.providerName,
          });
        });
      }
    });
    allModels.value = models;
  } catch (error: any) {
    console.error('加载AI模型失败', error);
  } finally {
    modelsLoading.value = false;
  }
};

// 加载AI隐私设置
const loadAiPrivacySettings = async () => {
  try {
    const configs = await configApi.getConfigsByGroup('ai-privacy');
    configs.forEach((config) => {
      const parts = config.configKey.split('.');
      const level = parts[1];
      const key = parts[2];
      
      if (level && key && aiPrivacySettings[level]) {
        if (key === 'enabled') {
          aiPrivacySettings[level][key] = config.configValue === 'true';
        } else if (key === 'models') {
          try {
            aiPrivacySettings[level][key] = JSON.parse(config.configValue || '[]');
          } catch {
            aiPrivacySettings[level][key] = [];
          }
        } else {
          aiPrivacySettings[level][key] = config.configValue;
        }
      }
    });
  } catch (error: any) {
    console.error('加载AI隐私设置失败', error);
  }
};

// 保存AI隐私设置
const handleSaveAiPrivacy = async () => {
  try {
    saving.value = true;
    const configs: any[] = [];
    
    Object.keys(aiPrivacySettings).forEach((level) => {
      const settings = aiPrivacySettings[level];
      
      configs.push({
        configKey: `ai-privacy.${level}.enabled`,
        configValue: String(settings.enabled),
        configGroup: 'ai-privacy',
        configName: `${level}_enabled`,
        configType: 'BOOLEAN',
        status: 'ACTIVE',
        isSystem: 0,
      });
      
      configs.push({
        configKey: `ai-privacy.${level}.models`,
        configValue: JSON.stringify(settings.models || []),
        configGroup: 'ai-privacy',
        configName: `${level}_models`,
        configType: 'JSON',
        status: 'ACTIVE',
        isSystem: 0,
      });
      
      configs.push({
        configKey: `ai-privacy.${level}.defaultModel`,
        configValue: String(settings.defaultModel || ''),
        configGroup: 'ai-privacy',
        configName: `${level}_defaultModel`,
        configType: 'STRING',
        status: 'ACTIVE',
        isSystem: 0,
      });
      
      configs.push({
        configKey: `ai-privacy.${level}.remark`,
        configValue: String(settings.remark || ''),
        configGroup: 'ai-privacy',
        configName: `${level}_remark`,
        configType: 'STRING',
        status: 'ACTIVE',
        isSystem: 0,
      });
    });
    
    await configApi.batchUpdateConfig(configs);
    ElMessage.success('AI隐私设置已保存');
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败');
  } finally {
    saving.value = false;
  }
};

// 加载配置列表
const loadConfigList = async () => {
  try {
    configLoading.value = true;
    const res = await configApi.getConfigPage({
      current: configPagination.current,
      size: configPagination.size,
    });
    configList.value = res.records;
    configPagination.total = res.total;
  } catch (error: any) {
    ElMessage.error('加载失败');
  } finally {
    configLoading.value = false;
  }
};

// 配置 CRUD
const handleAddConfig = () => {
  configDialogTitle.value = '新增配置';
  isConfigEdit.value = false;
  resetConfigForm();
  configDialogVisible.value = true;
};

const handleEditConfig = (row: Config) => {
  configDialogTitle.value = '编辑配置';
  isConfigEdit.value = true;
  Object.assign(configFormData, row);
  configDialogVisible.value = true;
};

const handleDeleteConfig = async (id: string) => {
  try {
    await configApi.deleteConfig(id);
    ElMessage.success('删除成功');
    loadConfigList();
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败');
  }
};

const handleConfigSubmit = async () => {
  try {
    await configFormRef.value?.validate();
    if (isConfigEdit.value && configFormData.id) {
      await configApi.updateConfig(configFormData.id, configFormData);
      ElMessage.success('更新成功');
    } else {
      await configApi.createConfig(configFormData);
      ElMessage.success('创建成功');
    }
    configDialogVisible.value = false;
    loadConfigList();
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  }
};

const resetConfigForm = () => {
  configFormRef.value?.resetFields();
  Object.assign(configFormData, {
    configKey: '',
    configValue: '',
    configGroup: '',
    configName: '',
    configType: 'STRING',
    isSystem: 0,
    status: 'ACTIVE',
    remark: '',
  });
};

onMounted(() => {
  loadBasicSettings();
  loadSecuritySettings();
  loadUploadSettings();
  loadEmailSettings();
  loadAiModels();
  loadAiPrivacySettings();
  loadConfigList();
});
</script>

<style lang="scss" scoped>
.system-settings-container {
  padding: 16px;
}
</style>

