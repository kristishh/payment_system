import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import apiCall from '../../helpers/api';

const initialTransactionState = {
  transactions: null,
};

export const getAllTransactions = createAsyncThunk(
  'transaction/getAll',
  async () => {
    return await apiCall('get', '/transactions',).then((res => {
      if (res.statusText !== "OK") {
        throw res.response.data.error
      }

      return res.data
    })).catch((e) => {
      throw new Error(e)
    })
  }
);

const transactionSlice = createSlice({
  name: 'transaction',
  initialState: initialTransactionState,
  extraReducers: (builder) => {
    builder
      .addCase(getAllTransactions.pending, (state) => {
      })
      .addCase(getAllTransactions.fulfilled, (state, action) => {
        state.transactions = action.payload.transactions
      })
  },
});


export default transactionSlice
