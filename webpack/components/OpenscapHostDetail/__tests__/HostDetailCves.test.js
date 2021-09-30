import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { within } from '@testing-library/dom';
import '@testing-library/jest-dom';

import HostDetail from '../';

import { withMockedProvider, withReactRouter, tick } from '../../../testHelper';

import {
  response,
  status,
  location,
  router,
  match,
  history,
  cvesMock,
} from './HostDetailCves.fixtures';

const testProps = { response, status, location, history, match, router };

const TestComponent = withReactRouter(withMockedProvider(HostDetail));

describe('OpenscapHostDetail', () => {
  it('should show CVEs for host', async () => {
    render(<TestComponent mocks={cvesMock} {...testProps} />);
    await waitFor(tick);
    expect(screen.getByText('CVE-2020-14365')).toBeInTheDocument();

    const table = screen.getByLabelText('Table of CVEs');
    userEvent.click(within(table).getByText('1'));
    expect(router.push).toHaveBeenCalledWith('/hosts?search=cve_id+%3D+267');
  });
});
