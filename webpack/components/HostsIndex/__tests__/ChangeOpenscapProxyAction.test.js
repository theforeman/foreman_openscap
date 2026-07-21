import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Menu, MenuContent, MenuList } from '@patternfly/react-core';
import { rtlHelpers, initMockStore } from 'foremanReact/common/testHelpers';
import { openBulkModal } from 'foremanReact/common/BulkModalStateHelper';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { STATUS } from 'foremanReact/constants';
import { APIActions } from 'foremanReact/redux/API';
import {
  CHANGE_OPENSCAP_MODAL_ID,
  OPENSCAP_PROXIES_KEY,
} from '../../OpenscapRemediationWizard/constants';
import BulkChangeOpenscapProxyModalScene, {
  ChangeOpenscapProxyMenuItem,
} from '../ChangeOpenscapProxyAction';

const { renderWithStore } = rtlHelpers;

jest.spyOn(APIActions, 'get');
jest.spyOn(APIActions, 'put');

const proxiesResolvedState = {
  API: {
    [OPENSCAP_PROXIES_KEY]: {
      status: STATUS.RESOLVED,
      response: {
        results: [
          { id: 1, name: 'openscap-proxy-1.example.com' },
          { id: 2, name: 'openscap-proxy-2.example.com' },
        ],
      },
    },
  },
};

const actionsBarValue = {
  selectAllHostsMode: false,
  selectedCount: 3,
  fetchBulkParams: jest.fn(() => 'id ^ (1,2,3)'),
  organizationId: 1,
  locationId: 2,
};

const renderMenuItem = (props = {}) =>
  renderWithStore(
    // eslint-disable-next-line @theforeman/rules/require-ouiaid
    <Menu activeItemId={null}>
      <MenuContent>
        <MenuList>
          <ChangeOpenscapProxyMenuItem selectedCount={3} {...props} />
        </MenuList>
      </MenuContent>
    </Menu>
  );

const renderScene = (contextValue = {}, initialState = proxiesResolvedState) =>
  renderWithStore(
    <ForemanActionsBarContext.Provider
      value={{ ...actionsBarValue, ...contextValue }}
    >
      <BulkChangeOpenscapProxyModalScene />
    </ForemanActionsBarContext.Provider>,
    initialState
  );

const renderMenuItemWithScene = (
  menuProps = {},
  contextValue = {},
  initialState = proxiesResolvedState
) =>
  renderWithStore(
    <ForemanActionsBarContext.Provider
      value={{ ...actionsBarValue, ...contextValue }}
    >
      {/* eslint-disable-next-line @theforeman/rules/require-ouiaid */}
      <Menu activeItemId={null}>
        <MenuContent>
          <MenuList>
            <ChangeOpenscapProxyMenuItem selectedCount={3} {...menuProps} />
          </MenuList>
        </MenuContent>
      </Menu>
      <BulkChangeOpenscapProxyModalScene />
    </ForemanActionsBarContext.Provider>,
    initialState
  );

describe('ChangeOpenscapProxyMenuItem', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    delete initMockStore.API[OPENSCAP_PROXIES_KEY];
    openBulkModal(CHANGE_OPENSCAP_MODAL_ID, false);
    APIActions.get.mockImplementation(payload => ({
      type: 'TEST_API_GET',
      payload,
    }));
    APIActions.put.mockImplementation(payload => ({
      type: 'TEST_API_PUT',
      payload,
    }));
  });

  it('renders the OpenSCAP Proxy menu item', () => {
    renderMenuItem();
    expect(screen.getByText('OpenSCAP Proxy')).toBeInTheDocument();
  });

  it('is disabled when no hosts are selected', () => {
    renderMenuItem({ selectedCount: 0 });
    expect(
      screen.getByRole('menuitem', { name: 'OpenSCAP Proxy' })
    ).toBeDisabled();
  });

  it('opens the bulk modal when clicked', () => {
    renderMenuItemWithScene({ selectedCount: 2 });

    expect(screen.queryByText('Assign OpenSCAP Proxy')).not.toBeInTheDocument();

    fireEvent.click(screen.getByText('OpenSCAP Proxy'));

    expect(screen.getByText('Assign OpenSCAP Proxy')).toBeInTheDocument();
  });
});

describe('BulkChangeOpenscapProxyModalScene', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    delete initMockStore.API[OPENSCAP_PROXIES_KEY];
    openBulkModal(CHANGE_OPENSCAP_MODAL_ID, false);
    APIActions.get.mockImplementation(payload => ({
      type: 'TEST_API_GET',
      payload,
    }));
    APIActions.put.mockImplementation(payload => ({
      type: 'TEST_API_PUT',
      payload,
    }));
  });

  it('does not render the modal when closed', () => {
    renderScene();
    expect(screen.queryByText('Assign OpenSCAP Proxy')).not.toBeInTheDocument();
  });

  it('passes actions-bar context props when the modal is open', () => {
    openBulkModal(CHANGE_OPENSCAP_MODAL_ID, true);
    renderScene({
      selectAllHostsMode: true,
      selectedCount: 5,
      organizationId: 10,
      locationId: 20,
    });

    expect(screen.getByText('Assign OpenSCAP Proxy')).toBeInTheDocument();
    expect(screen.getByText('ALL selected hosts.')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Select OpenSCAP Proxy' })
    ).toBeInTheDocument();
  });

  it('closes the modal via Cancel', () => {
    openBulkModal(CHANGE_OPENSCAP_MODAL_ID, true);
    renderScene();

    expect(screen.getByText('Assign OpenSCAP Proxy')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(screen.queryByText('Assign OpenSCAP Proxy')).not.toBeInTheDocument();
  });
});
