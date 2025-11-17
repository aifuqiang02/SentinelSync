import { requestClient } from '#/api/request';

export interface Config {
  id?: string;
  configKey: string;
  configValue: string;
  configGroup: string;
  configName: string;
  configType: 'STRING' | 'NUMBER' | 'BOOLEAN' | 'JSON';
  isSystem: 0 | 1; // 0: 非系统内置, 1: 系统内置
  status: 'ACTIVE' | 'DISABLED';
  remark?: string;
  createTime?: string;
  updateTime?: string;
}

export interface ConfigPageParams {
  current: number;
  size: number;
  configKey?: string;
  configGroup?: string;
}

export interface PageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

export const configApi = {
  async getConfigPage(params: ConfigPageParams) {
    return requestClient.get<PageResult<Config>>('/system/config/page', { params });
  },

  async getConfigValue(configKey: string) {
    return requestClient.get<string>(`/system/config/key/${configKey}`);
  },

  async getConfigsByGroup(configGroup: string) {
    return requestClient.get<Config[]>(`/system/config/group/${configGroup}`);
  },

  async getConfigById(id: string) {
    return requestClient.get<Config>(`/system/config/${id}`);
  },

  async createConfig(data: Config) {
    return requestClient.post<Config>('/system/config', data);
  },

  async updateConfig(id: string, data: Config) {
    return requestClient.put<Config>(`/system/config/${id}`, data);
  },

  async deleteConfig(id: string) {
    return requestClient.delete(`/system/config/${id}`);
  },

  async batchUpdateConfig(configs: Config[]) {
    return requestClient.post('/system/config/batch', configs);
  },
};

