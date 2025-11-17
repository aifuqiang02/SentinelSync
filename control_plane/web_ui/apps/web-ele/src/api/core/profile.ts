import { requestClient } from '#/api/request';

/**
 * 更新个人信息
 */
export interface UpdateProfileParams {
  realName?: string;
  email?: string;
  phone?: string;
  avatar?: string;
  remark?: string;
}

export async function updateProfileApi(data: UpdateProfileParams) {
  return requestClient.put('/auth/profile', data);
}

/**
 * 修改密码
 */
export interface ChangePasswordParams {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export async function changePasswordApi(data: ChangePasswordParams) {
  return requestClient.post('/auth/change-password', data);
}

/**
 * 上传头像
 */
export async function uploadAvatarApi(file: File) {
  const formData = new FormData();
  formData.append('file', file);
  return requestClient.post<{ url: string }>('/auth/upload-avatar', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
}

