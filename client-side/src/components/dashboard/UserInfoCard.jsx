import { 
  Card, 
  Badge, 
  ListGroup,
} from 'react-bootstrap';

const UserInfoCard = ({ user }) => {
  if (!user) return null;

  const formattedSum = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  }).format(user.totalTransactionalSum);

  const roleVariant = user.role === 'admin' ? 'success' : 'primary';
  return (
    <Card className="shadow-sm mb-5 border-0 rounded-3">
      <Card.Body className="p-0">
        <h5 className="mb-0 p-3 fw-bold text-primary border-bottom bg-light rounded-top-3">
            <i className="bi bi-person-circle me-2"></i>
            Account Overview
        </h5>
        <ListGroup variant="flush">
          <ListGroup.Item className="d-flex justify-content-between align-items-center">
            <span className="fw-medium text-secondary">Email:</span>
            <span className="fw-normal">{user.email}</span>
          </ListGroup.Item>
          <ListGroup.Item className="d-flex justify-content-between align-items-center">
            <span className="fw-medium text-secondary">Role:</span>
            <Badge 
                bg={roleVariant} 
                className="text-uppercase p-2 rounded-pill shadow-sm"
            >
                {user.role}
            </Badge>
          </ListGroup.Item>
          {!isNaN(formattedSum) && <ListGroup.Item className="d-flex justify-content-between align-items-center bg-light">
            <span className="fw-bold text-dark">Total Transactional Sum:</span>
            <span className="fw-bolder fs-5 text-success">{formattedSum}</span>
          </ListGroup.Item>}
        </ListGroup>
      </Card.Body>
    </Card>
  );
};

export default UserInfoCard
