import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import AdminLogin from '../AdminLogin';
import AdminManagement from '../AdminManagement';
import EscrowFinance from '../EscrowFinance';
import Footer from '../Footer';
import SettingsPage from '../SettingsPage';
import Sidebar from '../Sidebar';
import TopBar from '../TopBar';
import UserProfile from '../UserProfile';
import OrdersDashboard from '../OrdersDashboard';
import JewelerVerification from '../JewelerVerification';
import AdminDashboard from '../AdminDashboard';

const ordersApiCall = vi.fn();
const jewellersGetAll = vi.fn();
const jewellersApprove = vi.fn();
const jewellersReject = vi.fn();
const jewellersApiCall = vi.fn();
const dashboardApiCall = vi.fn();

vi.mock('../api/client', async () => {
  const actual = await vi.importActual('../api/client');
  return {
    ...actual,
    apiCall: (...args) => {
      const [endpoint] = args;
      if (String(endpoint) === '/admin/orders/chart') {
        return dashboardApiCall(...args);
      }
      if (String(endpoint).startsWith('/admin/orders')) {
        return ordersApiCall(...args);
      }
      if (
        String(endpoint).startsWith('/documents/') ||
        String(endpoint) === '/admin/jewellers' ||
        String(endpoint) === '/admin/jewellers?status='
      ) {
        return jewellersApiCall(...args);
      }
      return dashboardApiCall(...args);
    },
    getAllJewellers: (...args) => jewellersGetAll(...args),
    approveJeweller: (...args) => jewellersApprove(...args),
    rejectJeweller: (...args) => jewellersReject(...args),
  };
});

vi.mock('../Sidebar', () => ({
  default: ({ menuItems, setActiveMenu }) => (
    <div>
      {menuItems.map((item) => (
        <button key={item.id} onClick={() => setActiveMenu(item.id)}>
          {item.label}
        </button>
      ))}
    </div>
  ),
}));

vi.mock('../TopBar', () => ({
  default: ({ onProfileClick, onLogout }) => (
    <div>
      <button onClick={onProfileClick}>Open Profile</button>
      <button onClick={onLogout}>Logout</button>
    </div>
  ),
}));

vi.mock('../Footer', () => ({
  default: () => <div>Footer Mock</div>,
}));

vi.mock('../ProductDashboard', () => ({
  default: ({ defaultFilter }) => <div>Product Screen {defaultFilter}</div>,
}));

describe('All screens', () => {
  beforeEach(() => {
    ordersApiCall.mockReset();
    jewellersGetAll.mockReset();
    jewellersApprove.mockReset();
    jewellersReject.mockReset();
    jewellersApiCall.mockReset();
    dashboardApiCall.mockReset();
  });

  it('AdminLogin validates empty submit', async () => {
    render(<AdminLogin onLogin={vi.fn()} />);
    fireEvent.submit(document.querySelector('form'));
    expect(await screen.findByText(/please enter your email and password/i)).toBeInTheDocument();
  });

  it('AdminLogin submits valid credentials', async () => {
    const onLogin = vi.fn();
    global.fetch = vi.fn().mockResolvedValue({
      json: async () => ({
        success: true,
        user: { id: 1, name: 'Admin User' },
        token: 'token-123',
      }),
    });

    render(<AdminLogin onLogin={onLogin} />);
    fireEvent.change(screen.getByPlaceholderText(/enter your email address/i), {
      target: { value: 'admin@example.com' },
    });
    fireEvent.change(screen.getByPlaceholderText(/enter your password/i), {
      target: { value: 'Password123!' },
    });
    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(onLogin).toHaveBeenCalledWith({ id: 1, name: 'Admin User' }, 'token-123');
    });
  });

  it('AdminDashboard renders overview and key navigation', async () => {
    dashboardApiCall.mockImplementation((endpoint) => {
      if (endpoint === '/admin/stats') {
        return Promise.resolve({
          success: true,
          stats: {
            pendingJewellers: 2,
            totalProducts: 5,
            activeOrders: 3,
            totalJewellers: 4,
          },
        });
      }
      if (endpoint === '/admin/orders/chart') {
        return Promise.resolve({
          success: true,
          chart: [
            { label: 'Jan', count: 1 },
            { label: 'Feb', count: 2 },
          ],
        });
      }
      return Promise.resolve({ success: true });
    });

    const onLogout = vi.fn();
    render(<AdminDashboard onLogout={onLogout} />);

    expect(screen.getByText(/dashboard overview/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /verify jeweler/i }));
    expect(await screen.findByText(/jeweler verification/i)).toBeInTheDocument();
  });

  it('AdminManagement opens add administrator modal and validates fields', async () => {
    render(<AdminManagement />);
    fireEvent.click(screen.getByRole('button', { name: /add admin/i }));
    fireEvent.click(screen.getByRole('button', { name: /add administrator/i }));
    expect(await screen.findByText(/first name is required/i)).toBeInTheDocument();
    expect(screen.getByText(/last name is required/i)).toBeInTheDocument();
  });

  it('EscrowFinance releases a held transaction', async () => {
    render(<EscrowFinance />);
    fireEvent.click(screen.getByRole('button', { name: 'Held' }));
    fireEvent.click(screen.getAllByRole('button', { name: 'Release' })[0]);
    fireEvent.click(screen.getByRole('button', { name: /yes, release/i }));
    await waitFor(() => {
      expect(screen.getByText(/showing 1 of 7 transactions/i)).toBeInTheDocument();
    });
  });

  it('Footer renders branding', () => {
    render(<Footer />);
    expect(screen.getByText(/footer mock/i)).toBeInTheDocument();
  });

  it('JewelerVerification loads and approves a jeweller', async () => {
    const jewellers = [
      {
        id: 1,
        name: 'Nimali',
        email: 'nimali@example.com',
        business_name: 'Golden Aura Jewelry',
        business_registration_number: 'BRN-001',
        verification_status: 'pending',
        created_at: '2026-03-20T00:00:00.000Z',
      },
    ];

    jewellersGetAll.mockResolvedValue({ jewellers });
    jewellersApprove.mockResolvedValue({ success: true });
    jewellersReject.mockResolvedValue({ success: true });
    jewellersApiCall.mockImplementation((endpoint) => {
      if (endpoint === '/documents/1') return Promise.resolve({ documents: {} });
      if (endpoint === '/documents/1/logs') return Promise.resolve({ logs: [] });
      return Promise.resolve({});
    });

    render(<JewelerVerification />);
    expect(await screen.findByText(/golden aura jewelry/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /review/i }));
    fireEvent.click(screen.getByRole('button', { name: /✓\s*approve/i }));

    await waitFor(() => {
      expect(jewellersApprove).toHaveBeenCalledWith(1);
    });
  });

  it('OrdersDashboard loads and updates order status', async () => {
    const orders = [
      {
        id: 1,
        order_number: 'ORD-1001',
        status: 'pending_payment',
        quantity: 1,
        total_price: 12000,
        created_at: '2026-03-20T00:00:00.000Z',
        customer: { name: 'Amara Silva', email: 'amara@example.com' },
        jeweller: { business_name: 'Golden Aura Jewelry', email: 'golden@example.com' },
        product: { name: 'Diamond Ring', category: 'Rings' },
      },
    ];

    ordersApiCall.mockImplementation((endpoint) => {
      if (endpoint.startsWith('/admin/orders?')) return Promise.resolve({ orders });
      if (endpoint === '/admin/orders/stats') {
        return Promise.resolve({
          success: true,
          stats: {
            total: 1,
            pending_payment: 1,
            in_production: 0,
            completed: 0,
            cancelled: 0,
          },
        });
      }
      if (endpoint === '/admin/orders/1/status') return Promise.resolve({ success: true });
      return Promise.resolve({});
    });

    render(<OrdersDashboard />);
    expect(await screen.findByText(/ord-1001/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /view/i }));
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'completed' } });
    fireEvent.click(screen.getByRole('button', { name: /save changes/i }));

    await waitFor(() => {
      expect(ordersApiCall).toHaveBeenCalledWith(
        '/admin/orders/1/status',
        expect.objectContaining({ method: 'PATCH' }),
      );
    });
  });

  it('SettingsPage saves changed values', async () => {
    render(<SettingsPage />);
    fireEvent.change(screen.getByDisplayValue('3'), { target: { value: '5' } });
    fireEvent.click(screen.getAllByRole('button', { name: /save changes/i })[1]);
    expect(await screen.findByText(/changes saved successfully/i)).toBeInTheDocument();
  });

  it('Sidebar calls setActiveMenu', () => {
    const setActiveMenu = vi.fn();
    const DummyIcon = () => <span>icon</span>;
    const SupportIcon = () => <span>support</span>;

    render(
      <Sidebar
        activeMenu="dashboard"
        setActiveMenu={setActiveMenu}
        menuItems={[
          { id: 'dashboard', label: 'Dashboard', icon: DummyIcon },
          { id: 'orders', label: 'Orders', icon: DummyIcon },
        ]}
        Icons={{ Support: SupportIcon }}
      />,
    );

    fireEvent.click(screen.getByRole('button', { name: /orders/i }));
    expect(setActiveMenu).toHaveBeenCalledWith('orders');
  });

  it('TopBar calls profile and logout handlers', () => {
    const onProfileClick = vi.fn();
    const onLogout = vi.fn();

    render(<TopBar onProfileClick={onProfileClick} onLogout={onLogout} />);
    fireEvent.click(screen.getByRole('button', { name: /open profile/i }));
    fireEvent.click(screen.getByRole('button', { name: /logout/i }));

    expect(onProfileClick).toHaveBeenCalled();
    expect(onLogout).toHaveBeenCalled();
  });

  it('UserProfile edits data and navigates', async () => {
    const onNavigate = vi.fn();
    render(<UserProfile onNavigate={onNavigate} />);

    fireEvent.click(screen.getByRole('button', { name: /edit profile/i }));
    fireEvent.change(screen.getByDisplayValue(/sanuthmi jayalath/i), {
      target: { value: 'Test Admin' },
    });
    fireEvent.click(screen.getByRole('button', { name: /save changes/i }));

    expect(await screen.findByText(/profile updated/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /manage admins/i }));
    expect(onNavigate).toHaveBeenCalledWith('admins');
  });
});
