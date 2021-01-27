import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { within } from '@testing-library/dom';
import '@testing-library/jest-dom';

import { withMockedProvider, tick, historyMock } from '../../../../testHelper';

import {
  mocks,
  pushMock,
  pageParamsMocks,
  pageParamsHistoryMock,
  emptyMocks,
  errorMocks,
} from './OvalPoliciesIndex.fixtures';

import OvalPoliciesIndex from '../OvalPoliciesIndex';
import { ovalPoliciesPath } from '../../../../helpers/pathsHelper';

const TestComponent = withMockedProvider(OvalPoliciesIndex);

describe('OvalPoliciesIndex', () => {
  it('should load page', async () => {
    const { container } = render(
      <TestComponent history={historyMock} mocks={mocks} />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.getByText('first policy')).toBeInTheDocument();
    expect(screen.getByText('second policy')).toBeInTheDocument();
    expect(screen.getByText('first content')).toBeInTheDocument();
    expect(screen.getByText('second content')).toBeInTheDocument();
    const pageItems = container.querySelector('.pf-c-pagination__total-items');
    expect(within(pageItems).getByText(/1 - 2/)).toBeInTheDocument();
    expect(within(pageItems).getByText('of')).toBeInTheDocument();
    expect(within(pageItems).getByText('2')).toBeInTheDocument();
  });
  it('should load page with page params', async () => {
    const { container } = render(
      <TestComponent history={pageParamsHistoryMock} mocks={pageParamsMocks} />
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
      `${ovalPoliciesPath}?page=1&perPage=5`
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
});
