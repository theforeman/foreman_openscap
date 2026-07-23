import React from 'react';
import {
  screen,
  fireEvent,
  waitFor,
  within,
  act,
} from '@testing-library/react';
import '@testing-library/jest-dom';
import { rtlHelpers, initMockStore } from 'foremanReact/common/testHelpers';
import { STATUS } from 'foremanReact/constants';
import { APIActions } from 'foremanReact/redux/API';
import { OPENSCAP_PROXIES_KEY } from '../../../../OpenscapRemediationWizard/constants';
import BulkChangeOpenscapProxyModal from '../BulkChangeOpenscapProxyModal';

const { renderWithStore } = rtlHelpers;

jest.mock('foremanReact/common/I18n');

jest.spyOn(APIActions, 'get');
jest.spyOn(APIActions, 'put');

const proxies = {
  results: [
    { id: 1, name: 'openscap-proxy-1.example.com' },
    { id: 2, name: 'openscap-proxy-2.example.com' },
  ],
};

const defaultProps = {
  selectedCount: 3,
  selectAllHostsMode: false,
  fetchBulkParams: jest.fn(() => 'id ^ (1,2,3)'),
  isOpen: true,
  closeModal: jest.fn(),
  organizationId: 1,
  locationId: 2,
};

const proxiesResolvedState = {
  API: {
    [OPENSCAP_PROXIES_KEY]: {
      status: STATUS.RESOLVED,
      response: proxies,
    },
  },
};

const noProxiesState = {
  API: {
    [OPENSCAP_PROXIES_KEY]: {
      status: STATUS.RESOLVED,
      response: { results: [] },
    },
  },
};

const renderModal = (props = {}, initialState = proxiesResolvedState) =>
  renderWithStore(
    <BulkChangeOpenscapProxyModal {...defaultProps} {...props} />,
    initialState
  );

describe('BulkChangeOpenscapProxyModal', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // renderWithStore lodash-merges into shared initMockStore; clear prior API fixtures
    delete initMockStore.API[OPENSCAP_PROXIES_KEY];
    APIActions.get.mockImplementation(payload => ({
      type: 'TEST_API_GET',
      payload,
    }));
    APIActions.put.mockImplementation(payload => ({
      type: 'TEST_API_PUT',
      payload,
    }));
  });

  it('renders modal title and description with selected host count', () => {
    renderModal();
    expect(screen.getByText('Assign OpenSCAP Proxy')).toBeInTheDocument();
    expect(screen.getByText('3 selected hosts.')).toBeInTheDocument();
  });

  it('renders all-hosts mode description', () => {
    renderModal({ selectAllHostsMode: true });
    expect(screen.getByText('ALL selected hosts.')).toBeInTheDocument();
  });

  it('disables Assign until a proxy is selected', () => {
    renderModal();
    expect(screen.getByRole('button', { name: 'Assign' })).toBeDisabled();
  });

  it('lists OpenSCAP proxies in the dropdown', async () => {
    renderModal();
    fireEvent.click(
      screen.getByRole('button', { name: 'Select OpenSCAP Proxy' })
    );

    const menu = await screen.findByRole('menu');
    expect(
      within(menu).getByRole('menuitem', {
        name: 'openscap-proxy-1.example.com',
      })
    ).toBeInTheDocument();
    expect(
      within(menu).getByRole('menuitem', {
        name: 'openscap-proxy-2.example.com',
      })
    ).toBeInTheDocument();
  });

  it('enables Assign and dispatches bulk PUT after selecting a proxy', async () => {
    renderModal();
    fireEvent.click(
      screen.getByRole('button', { name: 'Select OpenSCAP Proxy' })
    );

    const menu = await screen.findByRole('menu');
    fireEvent.click(
      within(menu).getByRole('menuitem', {
        name: 'openscap-proxy-1.example.com',
      })
    );

    const assignBtn = screen.getByRole('button', { name: 'Assign' });
    await waitFor(() => {
      expect(assignBtn).not.toBeDisabled();
    });

    fireEvent.click(assignBtn);
    expect(APIActions.put).toHaveBeenCalledWith(
      expect.objectContaining({
        url: expect.stringContaining('/hosts/bulk/change_openscap_proxy'),
        params: expect.objectContaining({
          included: { search: 'id ^ (1,2,3)' },
          organization_id: 1,
          location_id: 2,
          openscap_proxy_id: '1',
        }),
      })
    );
  });

  it('calls onSuccess and closeModal after a successful bulk PUT', async () => {
    const onSuccess = jest.fn();
    const closeModal = jest.fn();
    renderModal({ onSuccess, closeModal });

    fireEvent.click(
      screen.getByRole('button', { name: 'Select OpenSCAP Proxy' })
    );

    const menu = await screen.findByRole('menu');
    fireEvent.click(
      within(menu).getByRole('menuitem', {
        name: 'openscap-proxy-1.example.com',
      })
    );

    const assignBtn = screen.getByRole('button', { name: 'Assign' });
    await waitFor(() => {
      expect(assignBtn).not.toBeDisabled();
    });

    fireEvent.click(assignBtn);

    const { handleSuccess } = APIActions.put.mock.calls[0][0];
    act(() => {
      handleSuccess();
    });

    expect(onSuccess).toHaveBeenCalled();
    expect(closeModal).toHaveBeenCalled();
  });

  it('calls closeModal on Cancel', () => {
    const closeModal = jest.fn();
    renderModal({ closeModal });
    fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(closeModal).toHaveBeenCalled();
  });

  it('shows empty state when no proxies are available', () => {
    renderModal({}, noProxiesState);
    expect(
      screen.getByText(
        'No OpenSCAP Proxies available. Please configure a Smart Proxy with the OpenSCAP feature.'
      )
    ).toBeInTheDocument();
  });

  it('does not render when isOpen is false', () => {
    renderModal({ isOpen: false });
    expect(screen.queryByText('Assign OpenSCAP Proxy')).not.toBeInTheDocument();
  });
});
