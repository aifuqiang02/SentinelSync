/**
 * 通用结果类型
 */
export interface Result<T = any> {
  /** 是否成功 */
  success: boolean
  /** 消息 */
  message?: string
  /** 数据 */
  data: T
  /** 错误码 */
  code?: number
}

