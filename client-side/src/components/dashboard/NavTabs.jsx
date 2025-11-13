import { Card, Nav } from 'react-bootstrap';

const NavTabs = ({ tabs, activeTab, handleTabsChange }) => {
    return (
        <Card.Header className="bg-white border-bottom-0 pt-4 pb-0">
            <Nav variant="pills" className="flex-nowrap overflow-auto pb-3 mb-3 border-bottom border-secondary-subtle">
                {tabs.map(tab => (
                    <Nav.Item key={tab.id} className="me-2">
                        <Nav.Link
                            className={`
                                text-uppercase fw-bold rounded-pill shadow-sm transition 
                                ${activeTab === tab.id ? 'bg-primary text-white' : 'bg-light text-secondary border border-secondary-subtle'}
                            `}
                            active={activeTab === tab.id}
                            onClick={() => handleTabsChange(tab.id)}
                            style={{ cursor: 'pointer' }}
                        >
                            {tab.label}
                        </Nav.Link>
                    </Nav.Item>
                ))}
            </Nav>
        </Card.Header>
    );
}

export default NavTabs
