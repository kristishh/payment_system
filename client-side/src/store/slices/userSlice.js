import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { login } from '../../lib/authService'

const initialUserState = {
  details: null,
  authLoading: false,
  authError: null,
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
    //     .addCase(logoutUser.fulfilled, () => {
    //       // Resetting state to initial state upon successful logout
    //       return { ...initialUserState, isAuthenticated: false, details: null, isAuthReady: true };
    //     });
  },
});

const { setAuthReady } = userSlice.actions;

export default userSlice
