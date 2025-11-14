import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { login, removeAuthToken } from '../../lib/authService'
import apiCall from '../../helpers/api';

const initialUserState = {
  allMerchants: null,
  merchantsLoading: true,
  updateMerchantError: null,
};

export const getAllMerchants = createAsyncThunk(
  'merchant/getAll',
  async () => {
    return await apiCall('get', '/admin/merchants',).then((res => {
      if (res.statusText !== "OK") {
        throw res.response.data.error
      }

      return res.data
    })).catch((e) => {
      throw new Error(e)
    })
  }
);

export const deleteMerchant = createAsyncThunk(
  'merchant/deleteMerchant',
  async ({ merchant }) => {
    return await apiCall('delete', `/admin/merchants/${merchant.id}`).then((res => {
      if (res.status !== 204) {
        throw res.response.data.error
      }

      return merchant
    })).catch((e) => {
      throw new Error(e)
    })
  }
);

export const updateMerchant = createAsyncThunk(
  'merchant/updateMerchant',
  async ({ merchant }) => {
    return await apiCall('put', `/admin/merchants/${merchant.id}`, merchant).then((res => {
      if (res.statusText !== "OK") {
        throw res.response.data.error
      }

      return merchant
    })).catch((e) => {
      throw new Error(e)
    })
  }
);

const merchantSlice = createSlice({
  name: 'merchant',
  initialState: initialUserState,
  extraReducers: (builder) => {
    builder
      .addCase(getAllMerchants.pending, (state) => {
        state.merchantsLoading = true;
      })
      .addCase(getAllMerchants.fulfilled, (state, action) => {
        state.allMerchants = action.payload.merchants
        state.merchantsLoading = false;
      })
      .addCase(deleteMerchant.fulfilled, (state, action) => {
        state.allMerchants = state.allMerchants.filter(merchant => merchant.id !== action.payload.id)
      })
      .addCase(updateMerchant.fulfilled, (state, action) => {
        state.updateMerchantError = null
      })
      .addCase(updateMerchant.rejected, (state, action) => {
        state.updateMerchantError = action.payload
      })
  },
});


export default merchantSlice
