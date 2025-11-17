import { requestClient } from '#/api/request';

export interface AiModel {
  id?: string;
  providerId: string;
  modelKey: string;
  modelName: string;
  description?: string;
  contextWindow: number;
  capabilityText: number;
  capabilityImage: number;
  capabilityVision: number;
  capabilityFunctionCall: number;
  priceInput?: number;
  priceOutput?: number;
  recommended?: number;
  enabled?: number;
  sortOrder?: number;
  status?: string;
  remark?: string;
}

export interface AiProvider {
  id?: string;
  providerKey: string;
  providerName: string;
  description?: string;
  icon?: string;
  website?: string;
  endpoint?: string;
  apiKey?: string;
  enabled?: number;
  isDefault?: number;
  category?: string;
  sortOrder?: number;
  configJson?: string;
  status?: string;
  remark?: string;
  models?: AiModel[];
  createTime?: string;
  updateTime?: string;
}

export const aiProviderApi = {
  async getAllProviders() {
    return requestClient.get<AiProvider[]>('/ai/provider/list');
  },

  async getProviderById(id: string) {
    return requestClient.get<AiProvider>(`/ai/provider/${id}`);
  },

  async saveProvider(data: AiProvider) {
    return requestClient.post<AiProvider>('/ai/provider', data);
  },

  async updateProviderConfig(id: string, data: Partial<AiProvider>) {
    return requestClient.put<AiProvider>(`/ai/provider/${id}/config`, data);
  },

  async deleteProvider(id: string) {
    return requestClient.delete(`/ai/provider/${id}`);
  },

  async toggleModel(modelId: string, enabled: number) {
    return requestClient.put(`/ai/provider/model/${modelId}/toggle`, { enabled });
  },

  async clearProviderConfig(id: string) {
    return requestClient.post(`/ai/provider/${id}/clear`);
  },

  async refreshModels(id: string) {
    return requestClient.post<AiProvider>(`/ai/provider/${id}/refresh-models`);
  },
};

