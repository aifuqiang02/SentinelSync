<template>
  <div class="info-table-example">
    <el-card shadow="never" class="border">
      <template #header>
        <div class="flex items-center">
          <i class="lucide:user text-primary mr-2" />
          <span class="font-semibold">基本信息</span>
        </div>
      </template>

      <!-- 使用 info-table 全局样式 -->
      <div class="info-table">
        <!-- 普通行：一行显示两个信息 -->
        <div class="info-row">
          <div class="info-label">姓名</div>
          <div class="info-value">张三</div>
        </div>
        <div class="info-row">
          <div class="info-label">手机号</div>
          <div class="info-value">13800138000</div>
        </div>

        <!-- 全宽行：跨所有列 -->
        <div class="info-row full-width">
          <div class="info-label">详细地址</div>
          <div class="info-value">陕西省西安市未央区凤城五路赛高街区东座101室</div>
        </div>

        <div class="info-row">
          <div class="info-label">邮箱</div>
          <div class="info-value">zhangsan@example.com</div>
        </div>
        <div class="info-row">
          <div class="info-label">身份证号</div>
          <div class="info-value">610102199001011234</div>
        </div>

        <!-- 包含 Element Plus 组件的示例 -->
        <div class="info-row">
          <div class="info-label">状态</div>
          <div class="info-value">
            <el-tag type="success">已认证</el-tag>
          </div>
        </div>
        <div class="info-row">
          <div class="info-label">注册时间</div>
          <div class="info-value">2025-01-01 12:00:00</div>
        </div>
      </div>
    </el-card>

    <el-card shadow="never" class="border mt-4">
      <template #header>
        <div class="flex items-center">
          <i class="lucide:briefcase text-primary mr-2" />
          <span class="font-semibold">工作信息</span>
        </div>
      </template>

      <div class="info-table">
        <div class="info-row">
          <div class="info-label">公司名称</div>
          <div class="info-value">某某科技有限公司</div>
        </div>
        <div class="info-row">
          <div class="info-label">职位</div>
          <div class="info-value">高级工程师</div>
        </div>

        <div class="info-row">
          <div class="info-label">部门</div>
          <div class="info-value">技术部</div>
        </div>
        <div class="info-row">
          <div class="info-label">入职日期</div>
          <div class="info-value">2023-06-01</div>
        </div>

        <!-- 包含长文本的示例 -->
        <div class="info-row full-width">
          <div class="info-label">工作职责</div>
          <div class="info-value">
            负责系统架构设计、核心模块开发、代码审查、技术选型、团队培训等工作
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
// 无需导入任何样式，info-table 是全局样式
// 直接使用即可
</script>

<style scoped lang="scss">
.info-table-example {
  padding: 20px;

  .text-primary {
    color: var(--el-color-primary);
  }
}
</style>

