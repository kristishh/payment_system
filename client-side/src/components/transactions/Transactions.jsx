import { Fragment, useCallback, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { ChevronDown, ChevronUp } from 'lucide-react';
import { getAllTransactions } from '../../store/slices/transactionSlice';

const getStatusBadge = (status) => {
  let colorClass = 'bg-gray-500';
  let text = status.toUpperCase();

  switch (status.toLowerCase()) {
    case 'approved':
      colorClass = 'bg-green-500';
      break;
    case 'refunded':
    case 'reversed':
      colorClass = 'bg-yellow-500';
      break;
    case 'error':
    case 'voided':
      colorClass = 'bg-red-500';
      break;
    case 'charged':
      colorClass = 'bg-blue-500';
      break;
    default:
      colorClass = 'bg-gray-500';
  }

  return (
    <span className={`px-2 py-1 text-xs font-semibold text-white rounded-full ${colorClass}`}>
      {text}
    </span>
  );
};

const ReferencedTransactionsTable = ({ transactions }) => (
  <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg shadow-inner mt-2 mb-4">
    <h4 className="text-lg font-semibold mb-3 text-gray-700">Transaction history</h4>
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200 text-sm">
        <thead>
          <tr className="text-center text-xs font-medium text-gray-500 uppercase tracking-wider bg-gray-100">
            <th scope="col" className="px-3 py-2">ID</th>
            <th scope="col" className="px-3 py-2">Type</th>
            <th scope="col" className="px-3 py-2">Amount</th>
            <th scope="col" className="px-3 py-2">Status</th>
            <th scope="col" className="px-3 py-2">Created At</th>
          </tr>
        </thead>
        <tbody className="text-center bg-white divide-y divide-gray-200">
          {transactions.map((refTx, index) => (
            <tr key={refTx.id} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
              <td className="px-3 py-2 font-mono text-xs">{refTx.id.substring(0, 8)}...</td>
              <td className="px-3 py-2 font-medium">{refTx.type.replace('Transaction', '')}</td>
              <td className="px-3 py-2 text-green-700 font-semibold">{refTx.amount ? `$${parseFloat(refTx.amount).toFixed(2)}` : 'N/A'}</td>
              <td className="px-3 py-2">{getStatusBadge(refTx.status)}</td>
              <td className="px-3 py-2 text-gray-500">{new Date(refTx.created_at).toLocaleTimeString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  </div>
);

const Transactions = () => {
  const dispatch = useDispatch()
  const { transactions } = useSelector(state => state.transaction)
  const [openTransactionId, setOpenTransactionId] = useState(null);

  const toggleCollapse = useCallback((id) => {
    setOpenTransactionId(prevId => prevId === id ? null : id);
  }, []);

  const renderTransactionRow = (tx) => {
    const isOpen = openTransactionId === tx.id;
    const hasRefs = tx.referenced_transactions && tx.referenced_transactions.length > 0;

    return (
      <Fragment key={tx.id}>
        <tr
          className={`transition-all duration-300 ease-in-out hover:bg-indigo-50/50 ${isOpen ? 'bg-indigo-100/70 shadow-inner' : 'bg-white'}`}
        >
          <td className="px-4 py-3 font-mono text-xs text-gray-600 border-b border-gray-200">
            {tx.id.substring(0, 8)}...
          </td>
          <td className="px-4 py-3 font-medium text-gray-800 border-b border-gray-200">
            {tx.type.replace('Transaction', '')}
          </td>
          <td className="px-4 py-3 text-green-700 font-bold border-b border-gray-200">
            ${parseFloat(tx.amount || 0).toFixed(2)}
          </td>
          <td className="px-4 py-3 border-b border-gray-200">
            {getStatusBadge(tx.status)}
          </td>
          <td className="px-4 py-3 text-gray-500 border-b border-gray-200">
            {new Date(tx.created_at).toLocaleString()}
          </td>
          <td className="px-4 py-3 text-center border-b border-gray-200">
            {hasRefs && (
              <button
                onClick={() => toggleCollapse(tx.id)}
                className="p-1 rounded-full text-indigo-600 hover:bg-indigo-100 transition duration-150"
                aria-expanded={isOpen}
                aria-controls={`collapse-${tx.id}`}
              >
                {isOpen ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
              </button>
            )}
          </td>
        </tr>

        {isOpen && hasRefs && (
          <tr className="bg-white">
            <td colSpan="6" className="p-0 border-b border-indigo-300">
              <div className="p-4 pt-0">
                <ReferencedTransactionsTable transactions={tx.referenced_transactions} />
              </div>
            </td>
          </tr>
        )}
      </Fragment>
    );
  };

  useEffect(() => {
    const loadTransactions = async () => {
      await dispatch(getAllTransactions()).unwrap()
    }

    if (!transactions) {
      loadTransactions()
    }
  }, [])

  if (!transactions) return null

  return <>
    <div className="bg-white shadow-2xl rounded-xl overflow-hidden ring-1 ring-gray-100">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-indigo-50">
            <tr>
              <th scope="col" className="px-4 py-4 text-left text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/6">
                ID
              </th>
              <th scope="col" className="px-4 py-4 text-left text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/6">
                Type
              </th>
              <th scope="col" className="px-4 py-4 text-left text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/6">
                Amount
              </th>
              <th scope="col" className="px-4 py-4 text-left text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/6">
                Status
              </th>
              <th scope="col" className="px-4 py-4 text-left text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/6">
                Date & Time
              </th>
              <th scope="col" className="px-4 py-4 text-center text-xs font-bold text-indigo-700 uppercase tracking-wider sm:w-1/12">
                Details
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-100">
            {transactions.map(renderTransactionRow)}
          </tbody>
        </table>
      </div>
    </div>

    {transactions.length === 0 && (
      <div className="mt-8 p-6 text-center bg-yellow-50 rounded-xl border border-yellow-200 text-yellow-700">
        No transactions found for this user.
      </div>
    )}
  </>
}

export default Transactions
