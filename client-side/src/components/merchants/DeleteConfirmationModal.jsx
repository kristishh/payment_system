import { Button } from 'react-bootstrap';

const DeleteConfirmationModal = ({ merchantName, toggleDeleteModal, handleDelete }) => {
  return (
    <div className="modal d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
      <div className="modal-dialog modal-dialog-centered">
        <div className="modal-content">
          <div className="modal-header bg-danger text-white">
            <h5 className="modal-title">Confirm Deletion</h5>
            <Button variant="close" onClick={() => toggleDeleteModal(false)}></Button>
          </div>
          <div className="modal-body">
            <p>Are you sure you want to permanently delete: <strong>{merchantName}</strong>?</p>
            <p className="text-danger small">This action cannot be undone.</p>
          </div>
          <div className="modal-footer">
            <Button variant="secondary" onClick={() => toggleDeleteModal(false)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleDelete}>
              Delete
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DeleteConfirmationModal
