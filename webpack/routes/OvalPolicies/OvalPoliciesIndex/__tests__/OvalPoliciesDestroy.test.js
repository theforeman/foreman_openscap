import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalPoliciesIndex from '../OvalPoliciesIndex';
import {
  withRouter,
  withRedux,
  withMockedProvider,
  tick,
  historyMock,
} from '../../../../testHelper';
import { mocks, noDeleteMocks } from './OvalPoliciesIndex.fixtures';
import {
  firstCall,
  secondCall,
  deleteMockFactory,
  pageParamsHistoryMock,
} from './OvalPoliciesDestroy.fixtures';

const TestComponent = withRouter(
  withRedux(withMockedProvider(OvalPoliciesIndex))
);

describe('OvalPoliciesIndex', () => {
  it('should open and close delete modal', async () => {
    render(
      <TestComponent
        history={historyMock}
        mocks={mocks}
        showToast={jest.fn()}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Policy'));
    await waitFor(tick);
    expect(
      screen.getByText('Are you sure you want to delete first policy?')
    ).toBeInTheDocument();
    userEvent.click(screen.getByText('Cancel'));
    await waitFor(tick);
    expect(
      screen.queryByText('Are you sure you want to delete first policy?')
    ).not.toBeInTheDocument();
    expect(screen.getByText('first policy')).toBeInTheDocument();
  });
  it('should delete OVAL policy', async () => {
    const showToast = jest.fn();
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall)}
        showToast={showToast}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.queryByText('third policy')).not.toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Policy'));
    await waitFor(tick);
    userEvent.click(screen.getByText('Confirm'));
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL policy was successfully deleted.',
    });
    await waitFor(tick);
    expect(screen.queryByText('first policy')).not.toBeInTheDocument();
    expect(screen.getByText('third policy')).toBeInTheDocument();
  });
  it('should show error when deleting OVAL policy fails', async () => {
    const showToast = jest.fn();
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall, [
          { message: 'cannot do it', path: 'base' },
          { message: 'will not do it', path: 'base' },
        ])}
        showToast={showToast}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.queryByText('third policy')).not.toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Policy'));
    await waitFor(tick);
    userEvent.click(screen.getByText('Confirm'));
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'error',
      message:
        'There was a following error when deleting OVAL policy: cannot do it, will not do it',
    });
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.queryByText('third policy')).not.toBeInTheDocument();
  });
  it('should not show delete button when user does not have delete permissions', async () => {
    render(
      <TestComponent
        history={historyMock}
        mocks={noDeleteMocks}
        showToast={jest.fn()}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Actions' })
    ).not.toBeInTheDocument();
  });
});
