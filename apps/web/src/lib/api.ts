const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8080';

export type HttpMethod = 'GET'|'POST'|'PUT'|'PATCH'|'DELETE';

let accessToken: string | null = localStorage.getItem('token');

export function setToken(token: string | null) {
  accessToken = token;
  if (token) localStorage.setItem('token', token);
  else localStorage.removeItem('token');
}

let isRefreshing = false;
let pending: Array<() => void> = [];

function getRefreshToken() {
  return localStorage.getItem('refreshToken');
}

async function tryRefresh() {
  if (isRefreshing) {
    await new Promise<void>(resolve => pending.push(resolve));
    return;
  }
  isRefreshing = true;
  try {
    const rt = getRefreshToken();
    if (!rt) throw new Error('No refresh token');
    const res = await fetch(`${API_URL}/api/auth/refresh?refreshToken=${encodeURIComponent(rt)}`, { method: 'POST' });
    if (!res.ok) throw new Error('Refresh failed');
    const data = await res.json();
    setToken(data.accessToken);
    if (data.refreshToken) localStorage.setItem('refreshToken', data.refreshToken);
  } finally {
    isRefreshing = false;
    pending.forEach(fn => fn());
    pending = [];
  }
}

async function request<T = unknown>(path: string, options: { method?: HttpMethod; body?: any; auth?: boolean; retried?: boolean } = {}) {
  const { method = 'GET', body, auth = true, retried = false } = options;
  const headers: Record<string,string> = { 'Content-Type':'application/json' };
  if (auth && accessToken) headers.Authorization = `Bearer ${accessToken}`;
  const res = await fetch(`${API_URL}${path}`, { method, headers, body: body ? JSON.stringify(body) : undefined });
  if (res.status === 401 && auth && !retried) {
    try {
      await tryRefresh();
      return request<T>(path, { method, body, auth, retried: true });
    } catch (e) {
      setToken(null);
      localStorage.removeItem('refreshToken');
    }
  }
  if (!res.ok) {
    const text = await res.text().catch(()=> '');
    throw new Error(`${res.status} ${res.statusText} - ${text}`);
  }
  const ct = res.headers.get('content-type') || '';
  return ct.includes('application/json') ? (await res.json() as T) : (await res.text() as unknown as T);
}

// Named export compatible with function-style usage: api<T>(path, opts)
const api = Object.assign(
  request,
  {
    // Axios-like helpers returning { data } for compatibility with pages that expect response.data
    async get<T = unknown>(path: string, opts: { auth?: boolean } = {}) {
      const data = await request<T>(path, { method: 'GET', auth: opts.auth ?? true });
      return { data } as { data: T };
    },
    async post<T = unknown>(path: string, body?: any, opts: { auth?: boolean } = {}) {
      const data = await request<T>(path, { method: 'POST', body, auth: opts.auth ?? true });
      return { data } as { data: T };
    },
    async put<T = unknown>(path: string, body?: any, opts: { auth?: boolean } = {}) {
      const data = await request<T>(path, { method: 'PUT', body, auth: opts.auth ?? true });
      return { data } as { data: T };
    },
    async patch<T = unknown>(path: string, body?: any, opts: { auth?: boolean } = {}) {
      const data = await request<T>(path, { method: 'PATCH', body, auth: opts.auth ?? true });
      return { data } as { data: T };
    },
    async delete<T = unknown>(path: string, opts: { auth?: boolean } = {}) {
      const data = await request<T>(path, { method: 'DELETE', auth: opts.auth ?? true });
      return { data } as { data: T };
    },
  }
);

export { api };
