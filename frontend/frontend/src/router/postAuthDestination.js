// After a guest gets bounced to login/register (e.g. from checkout), send them
// back to where they were headed instead of just their role's default home.
export function postAuthDestination(router, redirectQuery, role) {
  if (redirectQuery) {
    const resolved = router.resolve(redirectQuery)
    if (!resolved.meta.roles || resolved.meta.roles.includes(role)) return redirectQuery
  }
  if (role === 'vendor') return '/vendor/dashboard'
  if (role === 'admin') return '/admin'
  return '/vendors'
}
