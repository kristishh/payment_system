import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Container, Table, Button, Badge, CardText } from 'react-bootstrap';
import { Edit, Trash2 } from 'lucide-react';
import { deleteMerchant, getAllMerchants } from '../../store/slices/merchantSlice';
import DeleteConfirmationModal from './DeleteConfirmationModal';

const Merchants = () => {
  const dispatch = useDispatch()
  const { allMerchants, merchantsLoading } = useSelector(state => state.merchant)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [merchantToDelete, setMerchantToDelete] = useState(null)

  const handleDelete = (id) => {
    const merchant = allMerchants.find(merchant => id === merchant.id)

    setMerchantToDelete(merchant)
    setShowDeleteModal(true);
  }

  const confirmDelete = async () => {
    setShowDeleteModal(false);
    await dispatch(deleteMerchant({ merchant: merchantToDelete })).unwrap()
  };

  const handleEdit = (merchant) => {
    console.log(merchant);
  }

  useEffect(() => {
    const loadMerchants = async () => {
      await dispatch(getAllMerchants()).unwrap()
    }

    loadMerchants()
  }, [])

  if (merchantsLoading) return null

  return (
    <>
      {allMerchants.length > 0 ? (
        <Table striped hover responsive className="mb-0">
          <thead className="table-dark">
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Description</th>
              <th>Status</th>
              <th className="text-end">Total Sum</th>
              <th className="text-center">Actions</th>
            </tr>
          </thead>
          {allMerchants.map((merchant) => (
            <tbody>
              <tr key={`${merchant.id} ${merchant.email}`}>
                <td>{merchant.name}</td>
                <td>{merchant.email}</td>
                <td className="text-truncate" style={{ maxWidth: '250px' }}>{merchant.description}</td>
                <td>
                  <Badge
                    bg={merchant.status === 'active' ? 'success' : 'danger'}
                    pill
                  >
                    {merchant.status.toUpperCase()}
                  </Badge>
                </td>
                <td className="text-end">
                  ${merchant.total_transaction_sum.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                </td>
                <td className="text-center">
                  <Button
                    variant="outline-primary"
                    size="sm"
                    onClick={() => handleEdit(merchant.id)}
                    className="me-2 d-inline-flex align-items-center"
                  >
                    <Edit size={16} className="me-1" /> Edit
                  </Button>
                  <Button
                    variant="outline-danger"
                    size="sm"
                    onClick={() => handleDelete(merchant.id)}
                    className="d-inline-flex align-items-center"
                  >
                    <Trash2 size={16} className="me-1" /> Delete
                  </Button>
                </td>
              </tr>
            </tbody>
          ))}
        </Table>
      ) : (
        <CardText className='shadow-none'>No merchants found.</CardText>
      )}
      {showDeleteModal && <DeleteConfirmationModal merchantName={merchantToDelete.name} toggleDeleteModal={setShowDeleteModal} handleDelete={confirmDelete} />}
    </>
  )
}

export default Merchants;
