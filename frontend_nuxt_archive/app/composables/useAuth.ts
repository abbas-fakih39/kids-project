export const useAuth = () => {
  const token = useCookie('kk_access_token', { maxAge: 60 * 60 * 24 * 7, sameSite: 'lax' })
  const refreshToken = useCookie('kk_refresh_token', { maxAge: 60 * 60 * 24 * 30, sameSite: 'lax' })
  const user = useState<any>('user', () => null)

  const saveTokens = (access: string, refresh: string) => {
    token.value = access
    refreshToken.value = refresh
  }

  const getToken = () => token.value ?? null

  const removeTokens = () => {
    token.value = null
    refreshToken.value = null
    user.value = null
  }

  const isAuthenticated = () => !!token.value

  const getUser = async () => {
    if (!isAuthenticated()) return null
    if (user.value) return user.value
    try {
      const { get } = useApi()
      const data = await get('/users/profile')
      user.value = data
      return data
    } catch {
      removeTokens()
      return null
    }
  }

  const logout = async () => {
    try { const { post } = useApi(); await post('/auth/logout', {}) } catch {}
    removeTokens()
    navigateTo('/login')
  }

  return { token, user, saveTokens, getToken, removeTokens, isAuthenticated, getUser, logout }
}
