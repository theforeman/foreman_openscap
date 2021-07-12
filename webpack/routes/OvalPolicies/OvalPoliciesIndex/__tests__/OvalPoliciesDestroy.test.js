import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalPoliciesIndex from '../index';
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
    render(<TestComponent history={historyMock} mocks={mocks} />);
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
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall)}
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
    expect(
      screen.getByText('OVAL policy was successfully deleted.')
    ).toBeInTheDocument();
    expect(screen.queryByText('first policy')).not.toBeInTheDocument();
    expect(screen.getByText('third policy')).toBeInTheDocument();
  });
  it('should show error when deleting OVAL policy fails', async () => {
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall, [
          { message: 'cannot do it' },
          { message: 'will not do it' },
        ])}
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
    expect(
      screen.getByText(
        'There was a following error when deleting OVAL policy: cannot do it, will not do it'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.queryByText('third policy')).not.toBeInTheDocument();
  });
  it('should not show delete button when user does not have delete permissions', async () => {
    render(<TestComponent history={historyMock} mocks={noDeleteMocks} />);
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Actions' })
    ).not.toBeInTheDocument();
  });
});
