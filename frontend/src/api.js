import axios from 'axios';

// This is the central connection to Anas's PHP Slim 4 server.
const api = axios.create({
  // Note: Ask Anas for his local server URL if he is running it locally right now.
  // It usually looks something like 'http://localhost:8080' or 'http://localhost/campuseats/api'
  baseURL: 'https://campuseats-tk0r.onrender.com',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// This interceptor will automatically attach the JWT token to every request later
api.interceptors.request.use(config => {
  const token = localStorage.getItem('jwt_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
