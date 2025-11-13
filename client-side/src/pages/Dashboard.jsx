
import { useEffect, useMemo, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { useNavigate } from "react-router-dom";
import { Card, Container } from 'react-bootstrap';
import { fetchCurrentUser } from '../store/slices/userSlice';
import UserInfoCard from '../components/dashboard/UserInfoCard';
import NavTabs from '../components/dashboard/NavTabs'
import Transactions from '../components/dashboard/Transactions';
import Merchants from '../components/merchants/Merchants';

const tabs = [
  { id: 'transactions', label: 'Transactions' }
];

const Dashboard = () => {
  const dispatch = useDispatch();
  const { user, userLoading } = useSelector(state => state.user);
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('transactions');
  const memoTabs = useMemo(() => {
    if (user?.role === 'admin') {
      tabs.push({ id: 'merchants', label: 'Merchants' });
    }
    return tabs;
  }, [user]);

  useEffect(() => {
    const loadUser = async () => {
      await dispatch(fetchCurrentUser()).unwrap()
    }

    if (!user) {
      loadUser()
    }
  }, [])

  useEffect(() => {
    if (user && user?.role === 'merchant' && activeTab === 'merchants') {
      setActiveTab('transactions');
    }
  }, [user, activeTab]);


  if (!user) {
    navigate('/login')
  }

  if (userLoading) return null

  return (
    <div className="min-h-screen w-full inline-block p-4 bg-linear-to-br from-cyan-50 to-teal-100">
      <UserInfoCard user={user} />
      <div className="bg-white p-6 md:p-8 rounded-xl shadow-2xl">
        <NavTabs tabs={memoTabs} activeTab={activeTab} handleTabsChange={setActiveTab} />
        {activeTab === 'transactions' ? <Transactions /> : <Merchants />}
      </div>
    </div>
  )
}

export default Dashboard
