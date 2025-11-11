import './App.css'
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'
import { BrowserRouter, Routes, Route, Navigate } from "react-router";

const App = () => {

  return (
    <BrowserRouter>
      <Routes>
          <Route path="dashboard" element={<Dashboard/>} />
          <Route path="login" element={<Login />} />
          {/* <Route path="*" element={<Navigate to="/dashboard" replace />} /> */}
      </Routes>
    </BrowserRouter>
  )
}

export default App
