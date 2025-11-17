/**
 * 操作日志 API
 */
import { requestClient } from '#/api/request';

/**
 * 操作日志类型
 */
export interface OperLog {
  id?: string;
  operModule: string;
  operType: string;
  operDesc: string;
  requestMethod?: string;
  requestUrl?: string;
  requestParam?: string;
  responseResult?: string;
  operStatus: string;
  errorMsg?: string;
  operIp?: string;
  operLocation?: string;
  operTime?: string;
  executionTime?: number;
  operUserId?: string;
  operUserName?: string;
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
export interface OperLogPageParams {
  current: number;
  size: number;
  operModule?: string;
  operType?: string;
  operStatus?: string;
  operUserName?: string;
  startTime?: string;
  endTime?: string;
}

export const operLogApi = {
  /**
   * 分页查询操作日志
   */
  async getOperLogPage(params: OperLogPageParams) {
    return requestClient.get<PageResult<OperLog>>('/system/oper-log/page', { params });
  },

  /**
   * 获取操作日志详情
   */
  async getOperLogById(id: string) {
    return requestClient.get<OperLog>(`/system/oper-log/${id}`);
  },

  /**
   * 批量删除操作日志
   */
  async deleteOperLogs(ids: string[]) {
    return requestClient.delete('/system/oper-log/batch', { data: ids });
  },

  /**
   * 清空操作日志
   */
  async clearOperLogs() {
    return requestClient.delete('/system/oper-log/clear');
  },
};

