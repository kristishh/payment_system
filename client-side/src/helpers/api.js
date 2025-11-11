import axios from 'axios';

// Assuming Rails is running on port 3000
const API_URL = 'http://localhost:3000';

const axiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  }
});

axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      // config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  }
);

const apiCall = async (method, endpoint, data = {}) => {
  try {
    const lowerMethod = method.toLowerCase();
    let response;

    switch (lowerMethod) {
      case 'get':
        response = await axiosInstance.get(endpoint);
        break;
      case 'post': {
        response = await axiosInstance.post(endpoint, data);
        break;
      }
      case 'put':
        response = await axiosInstance.put(endpoint, data);
        break;
      case 'patch':
        response = await axiosInstance.patch(endpoint, data);
        break;
      case 'delete':
        response = await axiosInstance.delete(endpoint);
        break;
      default:
        throw new Error(`Unsupported HTTP method: ${method}`);
    }

    return response
  } catch (error) {
    return error
  }
};

export default apiCall
