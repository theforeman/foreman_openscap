import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalContentsIndex from '../index';
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
    render(<TestComponent history={historyMock} mocks={mocks} />);
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
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall)}
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
    expect(
      screen.getByText('OVAL Content successfully deleted.')
    ).toBeInTheDocument();
    expect(screen.queryByText('ansible OVAL content')).not.toBeInTheDocument();
    expect(screen.getByText('jboss OVAL content')).toBeInTheDocument();
  });
  it('should show error when deleting OVAL content fails', async () => {
    render(
      <TestComponent
        history={pageParamsHistoryMock}
        mocks={deleteMockFactory(firstCall, secondCall, [
          { message: 'is used by first policy' },
          { message: 'is used by second policy' },
        ])}
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
    expect(
      screen.getByText(
        'There was a following error when deleting OVAL Content: is used by first policy, is used by second policy'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(screen.queryByText('jboss OVAL content')).not.toBeInTheDocument();
  });
  it('should not show delete button when user does not have delete permissions', async () => {
    render(<TestComponent history={historyMock} mocks={noDeleteMocks} />);
    await waitFor(tick);
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'Actions' })
    ).not.toBeInTheDocument();
  });
});
