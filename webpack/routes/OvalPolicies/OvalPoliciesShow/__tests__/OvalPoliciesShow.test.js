import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { render, screen, waitFor } from '@testing-library/react';
import { within } from '@testing-library/dom';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalPoliciesShow from '../index';
import {
  ovalPoliciesShowPath,
  resolvePath,
} from '../../../../helpers/pathsHelper';

import { withMockedProvider, tick } from '../../../../testHelper';
import {
  policyDetailMock,
  historyMock,
  historyWithSearch,
  pushMock,
  policyCvesMock,
  ovalPolicyId,
} from './OvalPoliciesShow.fixtures';

const TestComponent = withMockedProvider(OvalPoliciesShow);

describe('OvalPoliciesShow', () => {
  it('should load details by default and handle tab change', async () => {
    const { container } = render(
      <TestComponent
        history={historyMock}
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyDetailMock}
      />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('Third policy')).toBeInTheDocument();
    expect(screen.getByText('Weekly, on tuesday')).toBeInTheDocument();
    expect(screen.getByText('A very strict policy')).toBeInTheDocument();
    const activeTabHeader = container.querySelector(
      '.pf-c-tabs__item.pf-m-current'
    );
    expect(within(activeTabHeader).getByText('Details')).toBeInTheDocument();
    userEvent.click(screen.getByRole('button', { name: 'CVEs' }));
    expect(pushMock).toHaveBeenCalledWith(
      resolvePath(ovalPoliciesShowPath, {
        ':id': ovalPolicyId,
        ':tab?': 'cves',
      })
    );
  });
  it('should load details tab when specified in URL', async () => {
    render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock}
      />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('Weekly, on tuesday')).toBeInTheDocument();
  });
  it('should load CVEs tab when specified in URL', async () => {
    const mocks = policyDetailMock.concat(policyCvesMock);
    render(
      <MemoryRouter>
        <TestComponent
          history={historyWithSearch}
          match={{
            params: { id: ovalPolicyId, tab: 'cves' },
            path: ovalPoliciesShowPath,
          }}
          mocks={mocks}
        />
      </MemoryRouter>
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('CVE-2020-14365')).toBeInTheDocument();
  });
});
