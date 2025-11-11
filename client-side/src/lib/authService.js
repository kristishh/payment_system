import apiCall from "../helpers/api";

export const login = async (email, password) => {
  try {
    const response = await apiCall('post', '/login', {
      user: {
        email: email,
        password: password
      }
    });

    if (response.statusText === "OK") {
      const token = response.headers.getAuthorization()

      localStorage.setItem('authToken', token);
    }

    return response;
  } catch (error) {
    return error
  }
};


