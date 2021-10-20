import React from 'react';
import { Router } from 'react-router-dom';
import { render, screen, waitFor } from '@testing-library/react';
import { within } from '@testing-library/dom';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { createMemoryHistory } from 'history';

import OvalPoliciesShow from '../index';
import {
  ovalPoliciesShowPath,
  resolvePath,
} from '../../../../helpers/pathsHelper';

import {
  withRedux,
  withMockedProvider,
  tick,
  withRouter,
} from '../../../../testHelper';
import {
  policyDetailMock,
  historyMock,
  historyWithSearch,
  pushMock,
  policyCvesMock,
  policyHostgroupsMock,
  policyHostgroupsDeniedMock,
  ovalPolicyId,
  policyUnauthorizedMock,
} from './OvalPoliciesShow.fixtures';

const TestComponent = withRedux(
  withRouter(withMockedProvider(OvalPoliciesShow))
);

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
    expect(screen.getAllByText('Third policy').pop()).toBeInTheDocument();
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
  it('should not load the page when user does not have permissions', async () => {
    render(
      <TestComponent
        history={historyMock}
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyUnauthorizedMock}
      />
    );
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(
      screen.getByText(
        'You are not authorized to view the page. Request the following permissions from administrator: view_oval_policies.'
      )
    ).toBeInTheDocument();
  });
  it('should load CVEs tab when specified in URL', async () => {
    const mocks = policyDetailMock.concat(policyCvesMock);
    render(
      <TestComponent
        history={historyWithSearch}
        match={{
          params: { id: ovalPolicyId, tab: 'cves' },
          path: ovalPoliciesShowPath,
        }}
        mocks={mocks}
      />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('CVE-2020-14365')).toBeInTheDocument();
  });
  it('should have button for scanning all hostgroups', async () => {
    const btnText = 'Scan All Hostgroups';

    const WithProvider = withRedux(withMockedProvider(OvalPoliciesShow));
    const history = createMemoryHistory();
    history.push = jest.fn();

    render(
      <Router history={history}>
        <WithProvider
          history={history}
          match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
          mocks={policyDetailMock}
        />
      </Router>
    );
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText(btnText)).toBeInTheDocument();
    userEvent.click(screen.getByRole('button', { name: btnText }));
    expect(history.push).toHaveBeenCalledWith(
      '/job_invocations/new?feature=foreman_openscap_run_oval_scans&host_ids=hostgroup_id+%5E+%284+10+12+11%29&inputs%5Boval_policies%5D=3'
    );
  });
  it('should load hostgroups tab when specified in URL', async () => {
    const mocks = policyDetailMock.concat(policyHostgroupsMock);
    render(
      <TestComponent
        history={historyWithSearch}
        match={{
          params: { id: ovalPolicyId, tab: 'hostgroups' },
          path: ovalPoliciesShowPath,
        }}
        mocks={mocks}
      />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('first hostgroup')).toBeInTheDocument();
  });
  it('should not show hostgroups for a user without permissions', async () => {
    const mocks = policyDetailMock.concat(policyHostgroupsDeniedMock);
    render(
      <TestComponent
        history={historyWithSearch}
        match={{
          params: { id: ovalPolicyId, tab: 'hostgroups' },
          path: ovalPoliciesShowPath,
        }}
        mocks={mocks}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.getByText('Permission denied')).toBeInTheDocument();
  });
});
