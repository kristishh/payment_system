import './App.css'
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'
import { BrowserRouter, Routes, Route } from "react-router";
import { Provider } from 'react-redux';
import store from './store/store';

const App = () => {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <Routes>
            <Route path="dashboard" element={<Dashboard/>} />
            <Route path="login" element={<Login />} />
            {/* <Route path="*" element={<Navigate to="/dashboard" replace />} /> */}
        </Routes>
      </BrowserRouter>
    </Provider>
  )
}

export default App
