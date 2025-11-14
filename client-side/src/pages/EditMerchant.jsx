import React, { useEffect, useMemo, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux'
import { useParams, useNavigate } from 'react-router-dom'
import { Container, Button, Form, Row, Col, Card } from 'react-bootstrap';
import { Save, XCircle } from 'lucide-react';
import { updateMerchant } from '../store/slices/merchantSlice';

const EditForm = () => {
  const { id } = useParams()
  const dispatch = useDispatch()
  const { allMerchants, updateMerchantError } = useSelector(state => state.merchant)
  const selectedMerchant = allMerchants?.find(merchant => merchant.id == id)
  const [formData, setFormData] = useState(selectedMerchant)
  const navigate = useNavigate()

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  }

  const handleSubmit = async (e) => {
    e.preventDefault();

    await dispatch(updateMerchant({ merchant: formData })).unwrap()
    !updateMerchantError && navigate(-1)
  }

  useEffect(() => {
    if (!formData) return navigate('/dashboard')
  }, [])

  if (!formData) return


  return (
    <Container className="min-h-screen min-w-full inline-block p-4 bg-linear-to-br from-cyan-50 to-teal-100">
      <Card className="shadow-lg p-4" >
        <h2 className="border-bottom pb-3 mb-4">Editing Merchant: {formData.name}</h2>

        <Form onSubmit={handleSubmit}>
          <Row className="mb-3">
            <Form.Group as={Col} controlId="formGridName" md={6}>
              <Form.Label>Store Name</Form.Label>
              <Form.Control
                type="text"
                placeholder="Enter store name"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
              />
            </Form.Group>

            <Form.Group as={Col} controlId="formGridEmail" md={6}>
              <Form.Label>Contact Email (Read Only)</Form.Label>
              <Form.Control
                type="email"
                placeholder="Enter email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                disabled
              />
            </Form.Group>
          </Row>

          <Form.Group className="mb-3" controlId="formGridDescription">
            <Form.Label>Description</Form.Label>
            <Form.Control
              className='resize-none!'
              as="textarea"
              rows={3}
              placeholder="Detailed description of the store..."
              name="description"
              value={formData.description}
              onChange={handleChange}
            />
          </Form.Group>

          <Row className="mb-4">
            <Form.Group as={Col} controlId="formGridStatus" md={6}>
              <Form.Label>Status</Form.Label>
              <Form.Select
                name="status"
                value={formData.status}
                onChange={handleChange}
              >
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </Form.Select>
            </Form.Group>

            <Form.Group as={Col} controlId="formGridSum" md={6}>
              <Form.Label>Total Transaction Sum (Read Only)</Form.Label>
              <Form.Control
                type="text"
                readOnly
                value={`$${formData.total_transaction_sum.toLocaleString('en-US', { minimumFractionDigits: 2 })}`}
                className="bg-light"
              />
              <Form.Text muted>
                This field is transactional and cannot be edited directly.
              </Form.Text>
            </Form.Group>
          </Row>
          <div className="d-flex justify-content-end gap-2">
            <Button variant="secondary" onClick={() => navigate('/dashboard')} className="d-inline-flex align-items-center">
              <XCircle size={18} className="me-2" /> Cancel
            </Button>
            <Button variant="success" type="submit" className="d-inline-flex align-items-center" disabled={formData === selectedMerchant}>
              <Save size={18} className="me-2" /> Save Changes
            </Button>
          </div>
        </Form>
      </Card >
    </Container >
  );
};

export default EditForm
