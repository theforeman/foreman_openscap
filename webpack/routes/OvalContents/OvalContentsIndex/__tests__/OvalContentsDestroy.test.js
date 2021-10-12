import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalContentsIndex from '../OvalContentsIndex';
import {
  withRouter,
  withRedux,
  withMockedProvider,
  tick,
  historyMock,
} from '../../../../testHelper';
import { mocks, noDeleteMocks } from './OvalContentsIndex.fixtures';
import {
  firstCall,
  secondCall,
  deleteMockFactory,
  pageParamsHistoryMock,
} from './OvalContentsDestroy.fixtures';

const TestComponent = withRouter(
  withRedux(withMockedProvider(OvalContentsIndex))
);

describe('OvalContentsIndex', () => {
  it('should open and close delete modal', async () => {
    render(
      <TestComponent
        history={historyMock}
        mocks={mocks}
        showToast={jest.fn()}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Content'));
    await waitFor(tick);
    expect(
      screen.getByText('Are you sure you want to delete ansible OVAL content?')
    ).toBeInTheDocument();
    userEvent.click(screen.getByText('Cancel'));
    await waitFor(tick);
    expect(
      screen.queryByText(
        'Are you sure you want to delete ansible OVAL content?'
      )
    ).not.toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
  });
  it('should delete OVAL content', async () => {
    const mocked = deleteMockFactory(firstCall, secondCall);
    const showToast = jest.fn();
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={mocked}
        showToast={showToast}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(screen.queryByText('jboss OVAL content')).not.toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Content'));
    await waitFor(tick);
    userEvent.click(screen.getByText('Confirm'));
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL Content successfully deleted.',
    });
    expect(screen.queryByText('ansible OVAL content')).not.toBeInTheDocument();
    expect(screen.getByText('jboss OVAL content')).toBeInTheDocument();
  });
  it('should show error when deleting OVAL content fails', async () => {
    const showToast = jest.fn();
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall, [
          { message: 'is used by first policy' },
          { message: 'is used by second policy' },
        ])}
        showToast={showToast}
      />
    );
    await waitFor(tick);
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(screen.queryByText('jboss OVAL content')).not.toBeInTheDocument();
    userEvent.click(screen.getAllByRole('button', { name: 'Actions' })[0]);
    userEvent.click(screen.getByText('Delete OVAL Content'));
    await waitFor(tick);
    userEvent.click(screen.getByText('Confirm'));
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'error',
      message:
        'There was a following error when deleting OVAL Content: is used by first policy, is used by second policy',
    });
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(screen.queryByText('jboss OVAL content')).not.toBeInTheDocument();
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
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Actions' })
    ).not.toBeInTheDocument();
  });
});
