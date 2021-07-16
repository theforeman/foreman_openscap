import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { within } from '@testing-library/dom';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { createMemoryHistory } from 'history';

import { i18nProviderWrapperFactory } from 'foremanReact/common/i18nProviderWrapperFactory';

import OvalPoliciesShow from '../';
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
  policyCvesMock,
  policyHostgroupsMock,
  policyHostgroupsDeniedMock,
  ovalPolicyId,
  policyUnauthorizedMock,
  contentSyncMock,
  contentSyncErrorMock,
} from './OvalPoliciesShow.fixtures';

import * as toasts from '../../../../helpers/toastHelper';

const TestComponent = i18nProviderWrapperFactory(
  new Date('2021-08-28 00:00:00 -1100'),
  'UTC'
)(withRedux(withMockedProvider(withRouter(OvalPoliciesShow))));

describe('OvalPoliciesShow', () => {
  it('should load details by default and handle tab change', async () => {
    const history = createMemoryHistory();
    history.push = jest.fn();

    const { container } = render(
      <TestComponent
        history={history}
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyDetailMock}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('Third policy | OVAL Policy')).toBeInTheDocument();
    expect(screen.getByText('Weekly, on tuesday')).toBeInTheDocument();
    expect(screen.getByText('A very strict policy')).toBeInTheDocument();
    const activeTabHeader = container.querySelector(
      '.pf-c-tabs__item.pf-m-current'
    );
    expect(within(activeTabHeader).getByText('Details')).toBeInTheDocument();
    userEvent.click(screen.getByRole('button', { name: 'CVEs' }));
    expect(history.push).toHaveBeenCalledWith(
      resolvePath(ovalPoliciesShowPath, {
        ':id': ovalPolicyId,
        ':tab?': 'cves',
      })
    );
  });
  it('should load details tab when specified in URL', async () => {
    render(
      <TestComponent
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('Weekly, on tuesday')).toBeInTheDocument();
  });
  it('should not load the page when user does not have permissions', async () => {
    render(
      <TestComponent
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyUnauthorizedMock}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(
      screen.getByText(
        'You are not authorized to view the page. Request the following permissions from administrator: view_oval_policies.'
      )
    ).toBeInTheDocument();
  });
  it('should load CVEs tab when specified in URL', async () => {
    const history = createMemoryHistory();
    history.location.search = '?page=1&perPage=5';

    render(
      <TestComponent
        history={history}
        match={{
          params: { id: ovalPolicyId, tab: 'cves' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock.concat(policyCvesMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('CVE-2020-14365')).toBeInTheDocument();
  });
  it('should have button for scanning all hostgroups', async () => {
    const btnText = 'Scan All Hostgroups';
    const history = createMemoryHistory();
    history.push = jest.fn();

    render(
      <TestComponent
        history={history}
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyDetailMock}
      />
    );
    await waitFor(tick);
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
        match={{
          params: { id: ovalPolicyId, tab: 'hostgroups' },
          path: ovalPoliciesShowPath,
        }}
        mocks={mocks}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('first hostgroup')).toBeInTheDocument();
  });
  it('should not show hostgroups for a user without permissions', async () => {
    const mocks = policyDetailMock.concat(policyHostgroupsDeniedMock);
    render(
      <TestComponent
        match={{
          params: { id: ovalPolicyId, tab: 'hostgroups' },
          path: ovalPoliciesShowPath,
        }}
        mocks={mocks}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.getByText('Permission denied')).toBeInTheDocument();
  });
  it('should sync content', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);

    const modalText =
      'The following action will update OVAL Content from url. Are you sure you want to proceed?';
    render(
      <TestComponent
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyDetailMock.concat(contentSyncMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    userEvent.click(screen.getByRole('button', { name: 'Sync OVAL Content' }));
    await waitFor(tick);
    expect(screen.getByText(modalText)).toBeInTheDocument();
    const confirmBtn = screen.getByRole('button', { name: 'Confirm' });
    userEvent.click(confirmBtn);
    expect(confirmBtn).toBeDisabled();
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL content was successfully synced.',
    });
  });
  it('should show errors on content sync', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);
    render(
      <TestComponent
        match={{ params: { id: ovalPolicyId }, path: ovalPoliciesShowPath }}
        mocks={policyDetailMock.concat(contentSyncErrorMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    userEvent.click(screen.getByRole('button', { name: 'Sync OVAL Content' }));
    await waitFor(tick);
    const confirmBtn = screen.getByRole('button', { name: 'Confirm' });
    userEvent.click(confirmBtn);
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'error',
      message:
        'There was a following error when syncing OVAL content: Could not fetch OVAL content from URL',
    });
  });
});
