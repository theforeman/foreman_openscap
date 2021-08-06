import React from 'react';
import { render, waitFor, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import {
  passingChecksMock,
  failingChecksMock,
  roleAbsent,
} from './OvalPoliciesSetup.fixtures';

import { withMockedProvider, withRouter, tick } from '../../../../testHelper';

import OvalPoliciesSetup from '../';

const TestComponent = withRouter(withMockedProvider(OvalPoliciesSetup));

describe('OVAL policies setup', () => {
  it('should show all checks as passing', async () => {
    render(<TestComponent mocks={passingChecksMock} />);
    userEvent.click(screen.getByRole('button', { name: 'check OVAL setup' }));
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.getAllByText('OK')).toHaveLength(6);
  });
  it('should show errors for failing checks', async () => {
    render(<TestComponent mocks={failingChecksMock} />);
    userEvent.click(screen.getByRole('button', { name: 'check OVAL setup' }));
    await waitFor(tick);
    await waitFor(tick);
    expect(screen.getAllByText('OK')).toHaveLength(1);
    expect(screen.getByText(roleAbsent.failMsg)).toBeInTheDocument();
    expect(screen.getAllByText('This check was skipped')).toHaveLength(4);
  });
});
