import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { within } from '@testing-library/dom';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import OvalContentsIndex from '../';

import {
  withRouter,
  withRedux,
  withMockedProvider,
  tick,
  historyMock,
} from '../../../../testHelper';
import { ovalContentsPath } from '../../../../helpers/pathsHelper';

import {
  mocks,
  paginatedMocks,
  pushMock,
  pagePaginationHistoryMock,
  emptyMocks,
  errorMocks,
  viewerMocks,
  unauthorizedMocks,
} from './OvalContentsIndex.fixtures';

const TestComponent = withRedux(
  withRouter(withMockedProvider(OvalContentsIndex))
);

describe('OvalContentsIndex', () => {
  it('should load page', async () => {
    const { container } = render(
      <TestComponent history={historyMock} mocks={mocks} />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(
      screen.getByText(
        'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('openshift OVAL content')).toBeInTheDocument();
    expect(screen.getByText('openshift.oval.xml.bz2')).toBeInTheDocument();
    const pageItems = container.querySelector('.pf-c-pagination__total-items');
    expect(within(pageItems).getByText(/1 - 4/)).toBeInTheDocument();
    expect(within(pageItems).getByText('of')).toBeInTheDocument();
    expect(within(pageItems).getByText('4')).toBeInTheDocument();
  });
  it('should load page with pagination params', async () => {
    const { container } = render(
      <TestComponent
        history={pagePaginationHistoryMock}
        mocks={paginatedMocks}
      />
    );
    await waitFor(tick);
    const pageItems = container.querySelector('.pf-c-pagination__total-items');
    expect(within(pageItems).getByText(/6 - 7/)).toBeInTheDocument();
    expect(within(pageItems).getByText('of')).toBeInTheDocument();
    expect(within(pageItems).getByText('7')).toBeInTheDocument();
    userEvent.click(
      screen.getByRole('button', { name: 'Go to previous page' })
    );

    expect(pushMock).toHaveBeenCalledWith(
      `${ovalContentsPath}?page=1&perPage=5`
    );
  });
  it('should show empty state', async () => {
    render(<TestComponent history={historyMock} mocks={emptyMocks} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('No OVAL Contents found.')).toBeInTheDocument();
  });
  it('should show errors', async () => {
    render(<TestComponent history={historyMock} mocks={errorMocks} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(
      screen.getByText('Something very bad happened.')
    ).toBeInTheDocument();
    expect(screen.getByText('Error!')).toBeInTheDocument();
  });
  it('should load page for user with permissions', async () => {
    render(<TestComponent history={historyMock} mocks={viewerMocks} />);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
  });
  it('should not load page for user without permissions', async () => {
    render(<TestComponent history={historyMock} mocks={unauthorizedMocks} />);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.queryByText('ansible OVAL content')).not.toBeInTheDocument();
    expect(
      screen.getByText(
        'You are not authorized to view the page. Request the following permissions from administrator: view_oval_contents.'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('Permission denied')).toBeInTheDocument();
  });
});
