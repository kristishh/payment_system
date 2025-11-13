import { configureStore } from '@reduxjs/toolkit'
import userSlice from './slices/userSlice'
import merchantSlice from './slices/merchantSlice';

const store = configureStore({
  reducer: {
    user: userSlice.reducer,
    merchant: merchantSlice.reducer,
  },
});

export default store
