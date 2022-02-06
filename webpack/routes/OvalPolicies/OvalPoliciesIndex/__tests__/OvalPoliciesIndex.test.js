import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import {
  withMockedProvider,
  withRouter,
  withRedux,
  tick,
  historyMock,
} from '../../../../testHelper';

import {
  mocks,
  emptyMocks,
  errorMocks,
  viewerMocks,
  unauthorizedMocks,
} from './OvalPoliciesIndex.fixtures';

import OvalPoliciesIndex from '../index';

const TestComponent = withRouter(
  withRedux(withMockedProvider(OvalPoliciesIndex))
);

describe('OvalPoliciesIndex', () => {
  it('should load page', async () => {
    render(<TestComponent history={historyMock} mocks={mocks} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.getByText('second policy')).toBeInTheDocument();
    expect(screen.getByText('first content')).toBeInTheDocument();
    expect(screen.getByText('second content')).toBeInTheDocument();

    expect(screen.getByText('first policy').closest('a')).toHaveAttribute(
      'href',
      '/experimental/compliance/oval_policies/1'
    );
    expect(screen.getByText('second policy').closest('a')).toHaveAttribute(
      'href',
      '/experimental/compliance/oval_policies/40'
    );
  });
  it('should show empty state', async () => {
    render(<TestComponent history={historyMock} mocks={emptyMocks} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('No OVAL Policies found')).toBeInTheDocument();
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
    expect(screen.getByText('first policy')).toBeInTheDocument();
  });
  it('should not load page for user without permissions', async () => {
    render(<TestComponent history={historyMock} mocks={unauthorizedMocks} />);
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.queryByText('first policy')).not.toBeInTheDocument();
    expect(
      screen.getByText(
        'You are not authorized to view the page. Request the following permissions from administrator: view_oval_policies.'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('Permission denied')).toBeInTheDocument();
  });
});
