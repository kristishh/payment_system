import './App.css'
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'

function App() {

  return (
    <>
      {false ? <Dashboard/> : <Login/>}
    </>
  )
}

export default App
