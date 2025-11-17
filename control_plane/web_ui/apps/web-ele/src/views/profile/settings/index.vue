<template>
  <Page description="管理个人信息和系统偏好设置" title="个人设置">
    <div class="settings-container">
      <el-row :gutter="20">
        <el-col :span="24" :lg="16">
          <el-tabs v-model="activeTab" type="border-card">
            <!-- 个人信息 -->
            <el-tab-pane label="个人信息" name="profile">
              <el-form
                :model="profileForm"
                :rules="profileRules"
                ref="profileFormRef"
                label-width="100px"
                style="max-width: 600px"
              >
                <el-form-item label="头像">
                  <div class="avatar-upload">
                    <el-avatar :size="100" :src="profileForm.avatar || undefined">
                      <el-icon><UserFilled /></el-icon>
                    </el-avatar>
                    <el-upload
                      :show-file-list="false"
                      :before-upload="handleAvatarUpload"
                      accept="image/*"
                      style="margin-left: 20px"
                    >
                      <el-button type="primary" size="small">
                        <el-icon><Upload /></el-icon>
                        上传头像
                      </el-button>
                    </el-upload>
                  </div>
                </el-form-item>

                <el-form-item label="用户名">
                  <el-input v-model="profileForm.username" disabled />
                </el-form-item>

                <el-form-item label="姓名" prop="realName">
                  <el-input v-model="profileForm.realName" placeholder="请输入姓名" />
                </el-form-item>

                <el-form-item label="邮箱" prop="email">
                  <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
                </el-form-item>

                <el-form-item label="手机号" prop="phone">
                  <el-input v-model="profileForm.phone" placeholder="请输入手机号" />
                </el-form-item>

                <el-form-item label="备注">
                  <el-input
                    v-model="profileForm.remark"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入备注"
                  />
                </el-form-item>

                <el-form-item>
                  <el-button type="primary" @click="handleProfileSubmit" :loading="profileLoading">
                    保存修改
                  </el-button>
                  <el-button @click="handleProfileReset">重置</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 修改密码 -->
            <el-tab-pane label="修改密码" name="password">
              <el-form
                :model="passwordForm"
                :rules="passwordRules"
                ref="passwordFormRef"
                label-width="100px"
                style="max-width: 600px"
              >
                <el-form-item label="原密码" prop="oldPassword">
                  <el-input
                    v-model="passwordForm.oldPassword"
                    type="password"
                    placeholder="请输入原密码"
                    show-password
                  />
                </el-form-item>

                <el-form-item label="新密码" prop="newPassword">
                  <el-input
                    v-model="passwordForm.newPassword"
                    type="password"
                    placeholder="请输入新密码"
                    show-password
                  />
                </el-form-item>

                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input
                    v-model="passwordForm.confirmPassword"
                    type="password"
                    placeholder="请再次输入新密码"
                    show-password
                  />
                </el-form-item>

                <el-form-item>
                  <el-button type="primary" @click="handlePasswordSubmit" :loading="passwordLoading">
                    修改密码
                  </el-button>
                  <el-button @click="handlePasswordReset">重置</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 系统偏好 -->
            <el-tab-pane label="系统偏好" name="preferences">
              <el-form label-width="120px" style="max-width: 600px">
                <el-form-item label="主题模式">
                  <el-radio-group v-model="themeMode" @change="handleThemeChange">
                    <el-radio value="light">浅色模式</el-radio>
                    <el-radio value="dark">深色模式</el-radio>
                    <el-radio value="auto">跟随系统</el-radio>
                  </el-radio-group>
                </el-form-item>

                <el-form-item label="主题颜色">
                  <el-color-picker
                    v-model="themeColor"
                    @change="handleThemeColorChange"
                    :predefine="predefineColors"
                  />
                  <el-button size="small" style="margin-left: 10px" @click="handleResetThemeColor">
                    重置为默认
                  </el-button>
                </el-form-item>

                <el-form-item label="语言">
                  <el-select v-model="language" @change="handleLanguageChange" style="width: 200px">
                    <el-option label="简体中文" value="zh-CN" />
                    <el-option label="English" value="en-US" />
                  </el-select>
                </el-form-item>

                <el-form-item label="页面布局">
                  <el-radio-group v-model="layoutMode" @change="handleLayoutChange">
                    <el-radio value="sidebar">侧边栏</el-radio>
                    <el-radio value="header">顶部栏</el-radio>
                    <el-radio value="mixed">混合模式</el-radio>
                  </el-radio-group>
                </el-form-item>

                <el-form-item label="标签页">
                  <el-switch
                    v-model="showTabs"
                    @change="handleTabsChange"
                    active-text="显示"
                    inactive-text="隐藏"
                  />
                </el-form-item>

                <el-form-item label="面包屑">
                  <el-switch
                    v-model="showBreadcrumb"
                    @change="handleBreadcrumbChange"
                    active-text="显示"
                    inactive-text="隐藏"
                  />
                </el-form-item>

                <el-form-item>
                  <el-button type="danger" @click="handleResetPreferences">
                    恢复默认设置
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 通知设置 -->
            <el-tab-pane label="通知设置" name="notification">
              <el-form label-width="150px" style="max-width: 600px">
                <el-form-item label="系统通知">
                  <el-switch
                    v-model="notificationSettings.system"
                    @change="handleNotificationChange"
                  />
                </el-form-item>

                <el-form-item label="任务通知">
                  <el-switch
                    v-model="notificationSettings.task"
                    @change="handleNotificationChange"
                  />
                </el-form-item>

                <el-form-item label="审批通知">
                  <el-switch
                    v-model="notificationSettings.approval"
                    @change="handleNotificationChange"
                  />
                </el-form-item>

                <el-form-item label="邮件通知">
                  <el-switch
                    v-model="notificationSettings.email"
                    @change="handleNotificationChange"
                  />
                </el-form-item>

                <el-form-item label="短信通知">
                  <el-switch
                    v-model="notificationSettings.sms"
                    @change="handleNotificationChange"
                  />
                </el-form-item>

                <el-form-item label="通知提示音">
                  <el-switch
                    v-model="notificationSettings.sound"
                    @change="handleNotificationChange"
                  />
                </el-form-item>
              </el-form>
            </el-tab-pane>
          </el-tabs>
        </el-col>

        <el-col :span="24" :lg="8">
          <el-card>
            <template #header>
              <span>账号信息</span>
            </template>
            <div class="account-info">
              <el-descriptions :column="1" border>
                <el-descriptions-item label="用户ID">
                  {{ userInfo?.userId || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="用户名">
                  {{ userInfo?.username || '-' }}
                </el-descriptions-item>
                <el-descriptions-item label="角色">
                  <el-tag
                    v-for="role in userInfo?.roles"
                    :key="role"
                    size="small"
                    style="margin-right: 5px"
                  >
                    {{ role }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="登录时间">
                  {{ loginTime }}
                </el-descriptions-item>
                <el-descriptions-item label="上次登录">
                  {{ lastLoginTime }}
                </el-descriptions-item>
              </el-descriptions>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </Page>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage } from 'element-plus';
import { UserFilled, Upload } from '@element-plus/icons-vue';
import { Page } from '@vben/common-ui';
import { useUserStore } from '@vben/stores';
import { preferences } from '@vben/preferences';
import {
  updateProfileApi,
  changePasswordApi,
  uploadAvatarApi,
  type UpdateProfileParams,
  type ChangePasswordParams,
} from '#/api/core/profile';
import { getUserInfoApi } from '#/api/core/user';

const userStore = useUserStore();
const profileFormRef = ref();
const passwordFormRef = ref();
const profileLoading = ref(false);
const passwordLoading = ref(false);
const activeTab = ref('profile');

// 获取用户信息
const userInfo = computed(() => userStore.userInfo);

// 个人信息表单
const profileForm = reactive({
  username: '',
  realName: '',
  email: '',
  phone: '',
  avatar: '',
  remark: '',
});

const profileRules = {
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' },
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' },
  ],
};

// 密码表单
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: '',
});

const validateConfirmPassword = (rule: any, value: any, callback: any) => {
  if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入的密码不一致'));
  } else {
    callback();
  }
};

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为 6-20 位', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' },
  ],
};

// 系统偏好设置
const themeMode = ref(preferences.theme.mode);
const themeColor = ref('#005FB8');
const language = ref('zh-CN');
const layoutMode = ref('sidebar');
const showTabs = ref(true);
const showBreadcrumb = ref(true);

const predefineColors = [
  '#005FB8',
  '#409EFF',
  '#67C23A',
  '#E6A23C',
  '#F56C6C',
  '#909399',
];

// 通知设置
const notificationSettings = reactive({
  system: true,
  task: true,
  approval: true,
  email: false,
  sms: false,
  sound: true,
});

// 账号信息
const loginTime = ref('2025-10-15 10:30:00');
const lastLoginTime = ref('2025-10-14 15:20:00');

// 加载用户信息
const loadUserInfo = async () => {
  try {
    const info = await getUserInfoApi();
    Object.assign(profileForm, {
      username: info.username,
      realName: info.realName,
      avatar: info.avatar,
      email: info.email || '',
      phone: info.phone || '',
      remark: info.remark || '',
    });
  } catch (error: any) {
    ElMessage.error('加载用户信息失败');
  }
};

// 上传头像
const handleAvatarUpload = async (file: File) => {
  // 验证文件类型
  const isImage = file.type.startsWith('image/');
  if (!isImage) {
    ElMessage.error('只能上传图片文件！');
    return false;
  }

  // 验证文件大小（2MB）
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB！');
    return false;
  }

  try {
    const result = await uploadAvatarApi(file);
    profileForm.avatar = result.url;
    ElMessage.success('头像上传成功');
  } catch (error: any) {
    ElMessage.error(error.message || '头像上传失败');
  }

  return false; // 阻止自动上传
};

// 保存个人信息
const handleProfileSubmit = async () => {
  try {
    await profileFormRef.value?.validate();
    profileLoading.value = true;

    const data: UpdateProfileParams = {
      realName: profileForm.realName,
      email: profileForm.email,
      phone: profileForm.phone,
      avatar: profileForm.avatar,
      remark: profileForm.remark,
    };

    await updateProfileApi(data);
    ElMessage.success('保存成功');

    // 刷新用户信息
    await loadUserInfo();
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  } finally {
    profileLoading.value = false;
  }
};

// 重置个人信息表单
const handleProfileReset = () => {
  loadUserInfo();
};

// 修改密码
const handlePasswordSubmit = async () => {
  try {
    await passwordFormRef.value?.validate();
    passwordLoading.value = true;

    const data: ChangePasswordParams = {
      oldPassword: passwordForm.oldPassword,
      newPassword: passwordForm.newPassword,
      confirmPassword: passwordForm.confirmPassword,
    };

    await changePasswordApi(data);
    ElMessage.success('密码修改成功，请重新登录');

    // 重置表单
    handlePasswordReset();

    // 可以选择自动跳转到登录页
    // setTimeout(() => {
    //   userStore.logout();
    // }, 1500);
  } catch (error: any) {
    if (error?.message) {
      ElMessage.error(error.message);
    }
  } finally {
    passwordLoading.value = false;
  }
};

// 重置密码表单
const handlePasswordReset = () => {
  passwordFormRef.value?.resetFields();
  Object.assign(passwordForm, {
    oldPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
};

// 主题设置
const handleThemeChange = (value: string) => {
  preferences.updatePreferences({
    theme: {
      mode: value as any,
    },
  });
  ElMessage.success('主题模式已更新');
};

const handleThemeColorChange = (value: string) => {
  preferences.updatePreferences({
    theme: {
      colorPrimary: value,
    },
  });
  ElMessage.success('主题颜色已更新');
};

const handleResetThemeColor = () => {
  themeColor.value = '#005FB8';
  handleThemeColorChange(themeColor.value);
};

// 语言设置
const handleLanguageChange = (value: string) => {
  preferences.updatePreferences({
    app: {
      locale: value,
    },
  });
  ElMessage.success('语言已切换');
};

// 布局设置
const handleLayoutChange = (value: string) => {
  preferences.updatePreferences({
    app: {
      layout: value as any,
    },
  });
  ElMessage.success('布局已更新');
};

const handleTabsChange = (value: boolean) => {
  preferences.updatePreferences({
    tabbar: {
      enable: value,
    },
  });
  ElMessage.success(`已${value ? '显示' : '隐藏'}标签页`);
};

const handleBreadcrumbChange = (value: boolean) => {
  preferences.updatePreferences({
    breadcrumb: {
      enable: value,
    },
  });
  ElMessage.success(`已${value ? '显示' : '隐藏'}面包屑`);
};

// 恢复默认设置
const handleResetPreferences = () => {
  preferences.resetPreferences();
  themeMode.value = 'light';
  themeColor.value = '#005FB8';
  language.value = 'zh-CN';
  layoutMode.value = 'sidebar';
  showTabs.value = true;
  showBreadcrumb.value = true;
  ElMessage.success('已恢复默认设置');
};

// 通知设置
const handleNotificationChange = () => {
  // 保存到 localStorage
  localStorage.setItem('notification-settings', JSON.stringify(notificationSettings));
  ElMessage.success('通知设置已保存');
};

// 加载通知设置
const loadNotificationSettings = () => {
  const saved = localStorage.getItem('notification-settings');
  if (saved) {
    Object.assign(notificationSettings, JSON.parse(saved));
  }
};

onMounted(() => {
  loadUserInfo();
  loadNotificationSettings();
});
</script>

<style lang="scss" scoped>
.settings-container {
  padding: 16px;
}

.avatar-upload {
  display: flex;
  align-items: center;
}

.account-info {
  :deep(.el-descriptions__label) {
    width: 100px;
  }
}
</style>

