import { configureStore } from '@reduxjs/toolkit'
import userSlice from './slices/userSlice'
import merchantSlice from './slices/merchantSlice';
import transactionSlice from './slices/transactionSlice';

const store = configureStore({
  reducer: {
    user: userSlice.reducer,
    merchant: merchantSlice.reducer,
    transaction: transactionSlice.reducer
  },
});

export default store
