
import { useEffect, useMemo, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { useNavigate } from "react-router-dom";
import { fetchCurrentUser } from '../store/slices/userSlice';
import UserInfoCard from '../components/dashboard/UserInfoCard';
import NavTabs from '../components/dashboard/NavTabs'

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
    
    if(!user){
      loadUser()
    }
  }, [])
  
  useEffect(() => {
    if (user && user?.role === 'merchant' && activeTab === 'merchants') {
      setActiveTab('transactions');
    }
  }, [user, activeTab]);


  if(!user) {
    navigate('/login')
  }

  if(userLoading) return null
  
  return(
    <>
      <UserInfoCard user={user} />
      <NavTabs tabs={memoTabs} activeTab={activeTab} handleTabsChange={setActiveTab} />  
    </>
  )
}

export default Dashboard
