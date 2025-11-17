/**
 * 业务相关常量定义
 */

/**
 * 企业类型枚举
 */
export enum EnterpriseTypeEnum {
  /** 外资 */
  FOREIGN = 1,
  /** 内资 */
  DOMESTIC = 2,
  /** 个体 */
  INDIVIDUAL = 3,
  /** 农专 */
  AGRICULTURAL = 4,
  /** 港澳个体 */
  HK_MACAO_INDIVIDUAL = 5,
  /** 台湾个体 */
  TAIWAN_INDIVIDUAL = 6,
  /** 个体互联网 */
  INDIVIDUAL_INTERNET = 7,
  /** 合伙 */
  PARTNERSHIP = 9,
  /** 集团 */
  GROUP = 10,
}

/**
 * 企业类型文本映射
 */
export const ENTERPRISE_TYPE_TEXT: Record<number, string> = {
  [EnterpriseTypeEnum.FOREIGN]: '外资',
  [EnterpriseTypeEnum.DOMESTIC]: '内资',
  [EnterpriseTypeEnum.INDIVIDUAL]: '个体',
  [EnterpriseTypeEnum.AGRICULTURAL]: '农专',
  [EnterpriseTypeEnum.HK_MACAO_INDIVIDUAL]: '港澳个体',
  [EnterpriseTypeEnum.TAIWAN_INDIVIDUAL]: '台湾个体',
  [EnterpriseTypeEnum.INDIVIDUAL_INTERNET]: '个体互联网',
  [EnterpriseTypeEnum.PARTNERSHIP]: '合伙',
  [EnterpriseTypeEnum.GROUP]: '集团',
};

/**
 * 企业类型下拉选项
 */
export const ENTERPRISE_TYPE_OPTIONS = [
  { label: '外资', value: EnterpriseTypeEnum.FOREIGN },
  { label: '内资', value: EnterpriseTypeEnum.DOMESTIC },
  { label: '个体', value: EnterpriseTypeEnum.INDIVIDUAL },
  { label: '农专', value: EnterpriseTypeEnum.AGRICULTURAL },
  { label: '港澳个体', value: EnterpriseTypeEnum.HK_MACAO_INDIVIDUAL },
  { label: '台湾个体', value: EnterpriseTypeEnum.TAIWAN_INDIVIDUAL },
  { label: '个体互联网', value: EnterpriseTypeEnum.INDIVIDUAL_INTERNET },
  { label: '合伙', value: EnterpriseTypeEnum.PARTNERSHIP },
  { label: '集团', value: EnterpriseTypeEnum.GROUP },
];

/**
 * 解析企业类型代码字符串（分号分隔）返回名称数组
 * @param codes 如："1;2;3;"
 * @returns 如：["外资", "内资", "个体"]
 */
export function parseEnterpriseTypeCodes(codes: string | undefined): string[] {
  if (!codes) return [];
  return codes
    .split(';')
    .filter((code) => code.trim() !== '')
    .map((code) => ENTERPRISE_TYPE_TEXT[Number.parseInt(code.trim())] || code);
}

/**
 * 解析企业类型名称字符串（分号分隔）
 * @param names 如："外资;内资;个体;"
 * @returns 如：["外资", "内资", "个体"]
 */
export function parseEnterpriseTypeNames(names: string | undefined): string[] {
  if (!names) return [];
  return names
    .split(';')
    .filter((name) => name.trim() !== '')
    .map((name) => name.trim());
}

/**
 * 经营范围分类枚举
 */
export enum ScopeCategoryEnum {
  /** 前置许可 */
  PRE_PERMIT = 1,
  /** 后置许可 */
  POST_PERMIT = 2,
  /** 一般 */
  GENERAL = 3,
}

/**
 * 经营范围分类文本映射
 */
export const SCOPE_CATEGORY_TEXT: Record<number, string> = {
  [ScopeCategoryEnum.PRE_PERMIT]: '前置许可',
  [ScopeCategoryEnum.POST_PERMIT]: '后置许可',
  [ScopeCategoryEnum.GENERAL]: '一般',
};

/**
 * 经营范围分类标签类型映射（用于 Element Plus Tag 组件）
 */
export const SCOPE_CATEGORY_TAG_TYPE: Record<
  number,
  'success' | 'warning' | 'info' | 'danger'
> = {
  [ScopeCategoryEnum.PRE_PERMIT]: 'warning',
  [ScopeCategoryEnum.POST_PERMIT]: 'info',
  [ScopeCategoryEnum.GENERAL]: 'success',
};

/**
 * 经营范围分类选项（用于下拉选择）
 */
export const SCOPE_CATEGORY_OPTIONS = [
  { label: '前置许可', value: ScopeCategoryEnum.PRE_PERMIT },
  { label: '后置许可', value: ScopeCategoryEnum.POST_PERMIT },
  { label: '一般', value: ScopeCategoryEnum.GENERAL },
];

/**
 * 获取经营范围分类文本
 */
export function getScopeCategoryText(category?: number | null): string {
  if (category === null || category === undefined) {
    return '-';
  }
  return SCOPE_CATEGORY_TEXT[category] || '未知';
}

/**
 * 获取经营范围分类标签类型
 */
export function getScopeCategoryTagType(
  category?: number | null,
): 'success' | 'warning' | 'info' | 'danger' {
  if (category === null || category === undefined) {
    return 'info';
  }
  return SCOPE_CATEGORY_TAG_TYPE[category] || 'info';
}

/**
 * 许可类型枚举（用于许可配置）
 */
export enum ApprovalTypeEnum {
  /** 前置审批 */
  PRE_APPROVAL = 'PRE_APPROVAL',
  /** 后置审批 */
  POST_APPROVAL = 'POST_APPROVAL',
}

/**
 * 许可类型文本映射
 */
export const APPROVAL_TYPE_TEXT: Record<string, string> = {
  [ApprovalTypeEnum.PRE_APPROVAL]: '前置审批',
  [ApprovalTypeEnum.POST_APPROVAL]: '后置审批',
};

/**
 * 许可类型选项
 */
export const APPROVAL_TYPE_OPTIONS = [
  { label: '前置审批', value: ApprovalTypeEnum.PRE_APPROVAL },
  { label: '后置审批', value: ApprovalTypeEnum.POST_APPROVAL },
];

/**
 * 获取许可类型文本
 */
export function getApprovalTypeText(type?: string | null): string {
  if (!type) {
    return '-';
  }
  return APPROVAL_TYPE_TEXT[type] || '未知';
}

