export default defineNuxtRouteMiddleware((to) => {
  const { isAuthenticated } = useAuth()
  const publicRoutes = ['/splash', '/login', '/register']
  if (to.path === '/' || to.path === '') return navigateTo('/splash')
  if (!isAuthenticated() && !publicRoutes.includes(to.path)) {
    return navigateTo('/login')
  }
})
