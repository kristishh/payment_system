import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { login, removeAuthToken } from '../../lib/authService'
import apiCall from '../../helpers/api';

const initialUserState = {
  user: null,
  authLoading: false,
  authError: null,
  userLoading: true,
};

export const loginUser = createAsyncThunk(
  'user/login',
  async ({ email, password }) => {
    return await login(email, password).then(res => {
      if (res.statusText !== "OK") {
        throw res.response.data.error
      }

      return res.data
    }).catch((e) => {
      throw new Error(e)
    })
  }
);

export const fetchCurrentUser = createAsyncThunk(
  'user/get',
  async () => {
    return await apiCall('get', '/users',).then((res => {
      if (res.statusText !== "OK") {
        throw res.response.data.error
      }

      return res.data
    })).catch((e) => {
      removeAuthToken()

      throw new Error(e)
    })
  }
);

const logoutUser = createAsyncThunk(
  'user/logout',
  async () => {
    logout();
    return null;
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState: initialUserState,
  extraReducers: (builder) => {
    builder
      .addCase(loginUser.pending, (state) => {
        state.authLoading = true;
        state.authError = null;
      })
      .addCase(loginUser.fulfilled, (state, action) => {
        state.user = action.payload.status.data.user;
        state.authLoading = false;
      })
      .addCase(loginUser.rejected, (state, action) => {
        state.user = null
        state.authLoading = false;
        state.authError = action.error.message
      })
      .addCase(fetchCurrentUser.pending, (state, action) => {
        state.user = null
        state.userLoading = true;
        state.authError = null
      })
      .addCase(fetchCurrentUser.fulfilled, (state, action) => {
        state.user = action.payload.user
        state.userLoading = false;
      })
      .addCase(fetchCurrentUser.rejected, (state, action) => {
        state.user = null
        state.userLoading = false
      })
      .addCase(logoutUser.fulfilled, () => {
        state.user = null
        state.userLoading = false
      });
  },
});

const { setAuthReady } = userSlice.actions;

export default userSlice
