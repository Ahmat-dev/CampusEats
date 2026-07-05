const BASE_URL = import.meta.env.VITE_API_BASE_URL

export class ApiError extends Error {
  constructor(message, status, fields) {
    super(message)
    this.status = status
    this.fields = fields ?? null
  }
}

function getToken() {
  return localStorage.getItem('campuseats_token')
}

async function request(path, { method = 'GET', body, auth = false } = {}) {
  const headers = { 'Content-Type': 'application/json' }

  if (auth) {
    const token = getToken()
    if (token) headers['Authorization'] = `Bearer ${token}`
  }

  let response
  try {
    response = await fetch(`${BASE_URL}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    })
  } catch {
    throw new ApiError('Could not reach the server.', 0)
  }

  const isJson = response.headers.get('content-type')?.includes('application/json')
  const payload = isJson ? await response.json() : null

  if (!response.ok) {
    const message = payload?.error?.message ?? `Request failed (${response.status})`
    throw new ApiError(message, response.status, payload?.error?.fields)
  }

  return payload?.data ?? null
}

export const api = {
  get: (path, opts) => request(path, { ...opts, method: 'GET' }),
  post: (path, body, opts) => request(path, { ...opts, method: 'POST', body }),
  put: (path, body, opts) => request(path, { ...opts, method: 'PUT', body }),
  patch: (path, body, opts) => request(path, { ...opts, method: 'PATCH', body }),
  delete: (path, opts) => request(path, { ...opts, method: 'DELETE' }),
}

// Backend/database unreachable (network failure or 5xx) -> fall back to the
// bundled seed data in public/mocks/ so the storefront still browses fully.
// Real application errors (404, 401, 422...) are left to throw normally.
function isBackendUnavailable(error) {
  return error instanceof ApiError && (error.status === 0 || error.status >= 500)
}

let mockVendorsPromise = null
let mockMenuItemsPromise = null

function loadMockVendors() {
  if (!mockVendorsPromise) {
    mockVendorsPromise = fetch('/mocks/vendors.json').then((r) => r.json())
  }
  return mockVendorsPromise
}

function loadMockMenuItems() {
  if (!mockMenuItemsPromise) {
    mockMenuItemsPromise = fetch('/mocks/menu.json').then((r) => r.json())
  }
  return mockMenuItemsPromise
}

export async function getVendors(search) {
  const query = search ? `?search=${encodeURIComponent(search)}` : ''

  try {
    return await request(`/api/vendors${query}`, { method: 'GET' })
  } catch (e) {
    if (!isBackendUnavailable(e)) throw e

    const vendors = await loadMockVendors()
    if (!search) return vendors

    const needle = search.toLowerCase()
    return vendors.filter((v) => v.name.toLowerCase().includes(needle))
  }
}

export async function getVendor(id) {
  try {
    return await request(`/api/vendors/${id}`, { method: 'GET' })
  } catch (e) {
    if (!isBackendUnavailable(e)) throw e

    const vendors = await loadMockVendors()
    const vendor = vendors.find((v) => String(v.id) === String(id))
    if (!vendor) throw e

    return vendor
  }
}

export async function getMenuItems(vendorId) {
  try {
    return await request(`/api/vendors/${vendorId}/menu-items`, { method: 'GET' })
  } catch (e) {
    if (!isBackendUnavailable(e)) throw e

    const items = await loadMockMenuItems()
    return items.filter((item) => String(item.vendor_id) === String(vendorId))
  }
}
