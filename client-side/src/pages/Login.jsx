import React, { useState } from 'react';
import { useNavigate } from "react-router-dom";
import { login } from "../lib/authService"

const InputField = ({ id, label, type, value, onChange, required }) => (
  <div>
    <label htmlFor={id} className="text-sm float-left font-medium text-gray-700 mb-1">
      {label}
    </label>
    <input
      id={id}
      name={id}
      type={type}
      value={value}
      onChange={onChange}
      required={required}
      className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-teal-700 focus:border-teal-700 transition duration-150 ease-in-out sm:text-sm"
    />
  </div>
);

const Alert = ({ type, text }) => {
  if (!text) return

  const baseClass = "p-3 mb-4 text-white text-sm rounded-lg";
  const errorClass = "bg-red-700 text-red-800 border border-red-300";

  return (
    <div className={`${baseClass} ${errorClass}`} role="alert">
      {text}
    </div>
  );
};


const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const navigate = useNavigate()

  const handleLogin = (e) => {
    e.preventDefault();
    setMessage(null);
    setLoading(true);

    if (!email || !password) {
      setLoading(false);
      setMessage({ type: 'error', text: 'Please enter both email and password.' });
    }

    setTimeout(async () => {
      const response = await login(email, password)

      setLoading(false);

      if (response.statusText === "OK") {
        navigate('/dashboard')
      } else {
        setMessage({ type: 'error', text: response.response.data.error });
      }

      setLoading(false);
    }, 1500);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-linear-to-br from-cyan-50 to-teal-100">
      <div className="w-full max-w-sm bg-white p-6 md:p-8 rounded-xl shadow-2xl">
        <h2 className="text-3xl font-extrabold text-gray-900 text-center mb-6">Sign In</h2>
        {message && <Alert type={message?.type} text={message?.text} />}
        <form className="space-y-6" onSubmit={handleLogin}>
          <InputField
            id="email"
            label="Email address"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <InputField
            id="password"
            label="Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button
            type="submit"
            disabled={loading}
            className={`w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-base font-medium text-white transition duration-150 ease-in-out 
              ${loading 
                ? 'bg-teal-500 cursor-not-allowed'
                : 'bg-teal-700! hover:bg-teal-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-700'
              }`}
          >
            {loading ? (
              <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            ) : (
              'Sign In'
            )}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
