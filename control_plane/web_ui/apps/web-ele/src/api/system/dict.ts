/**
 * 字典管理 API
 */
import { requestClient } from '#/api/request';

/**
 * 字典类型
 */
export interface Dict {
  id?: string;
  dictName: string;
  dictCode: string;
  dictType?: string;
  status: string;
  dictLevel?: string;           // 字典级别：SYSTEM-系统级，BUSINESS-业务级
  businessTypeCode?: string;    // 关联业务类型编码
  enabled?: boolean;            // 是否启用
  sortOrder?: number;           // 排序
  remark?: string;
  createTime?: string;
  updateTime?: string;
  items?: DictItem[];
}

/**
 * 字典项类型
 */
export interface DictItem {
  id?: string;
  dictId: string;
  itemLabel: string;
  itemValue: string;
  itemType?: string;
  sortOrder?: number;
  status: string;
  remark?: string;
  createTime?: string;
  updateTime?: string;
}

/**
 * 分页结果
 */
export interface PageResult<T> {
  records: T[];
  total: number;
  size: number;
  current: number;
  pages: number;
}

/**
 * 分页参数
 */
export interface DictPageParams {
  current: number;
  size: number;
  dictName?: string;
  dictCode?: string;
  dictLevel?: string;
}

export const dictApi = {
  /**
   * 分页查询字典
   */
  async getDictPage(params: DictPageParams) {
    return requestClient.get<PageResult<Dict>>('/system/dict/page', { params });
  },

  /**
   * 获取字典详情
   */
  async getDictById(id: string) {
    return requestClient.get<Dict>(`/system/dict/${id}`);
  },

  /**
   * 创建字典
   */
  async createDict(data: Dict) {
    return requestClient.post<Dict>('/system/dict', data);
  },

  /**
   * 更新字典
   */
  async updateDict(id: string, data: Dict) {
    return requestClient.put<Dict>(`/system/dict/${id}`, data);
  },

  /**
   * 删除字典
   */
  async deleteDict(id: string) {
    return requestClient.delete(`/system/dict/${id}`);
  },

  /**
   * 获取字典项列表
   */
  async getDictItems(dictId: string) {
    return requestClient.get<DictItem[]>(`/system/dict/${dictId}/items`);
  },

  /**
   * 创建字典项
   */
  async createDictItem(data: DictItem) {
    return requestClient.post<DictItem>('/system/dict/item', data);
  },

  /**
   * 更新字典项
   */
  async updateDictItem(id: string, data: DictItem) {
    return requestClient.put<DictItem>(`/system/dict/item/${id}`, data);
  },

  /**
   * 删除字典项
   */
  async deleteDictItem(id: string) {
    return requestClient.delete(`/system/dict/item/${id}`);
  },
};

