export const useApi = () => {
  const config = useRuntimeConfig()
  const BASE = config.public.apiBase

  const fetchApi = async (endpoint: string, options: any = {}) => {
    const { getToken, removeTokens } = useAuth()
    const tk = getToken()
    const headers: any = { 'Content-Type': 'application/json', ...options.headers }
    if (tk) headers['Authorization'] = `Bearer ${tk}`
    try {
      return await $fetch(`${BASE}${endpoint}`, { ...options, headers })
    } catch (error: any) {
      if (error.status === 401 || error.response?.status === 401) {
        removeTokens(); navigateTo('/login')
      }
      throw error
    }
  }

  const get  = (url: string)            => fetchApi(url, { method: 'GET' })
  const post = (url: string, body: any) => fetchApi(url, { method: 'POST', body })
  const patch= (url: string, body: any) => fetchApi(url, { method: 'PATCH', body })
  const del  = (url: string)            => fetchApi(url, { method: 'DELETE' })

  return { get, post, patch, del }
}
