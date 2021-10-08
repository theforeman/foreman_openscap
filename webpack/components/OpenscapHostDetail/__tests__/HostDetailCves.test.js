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
  match,
  history,
  cvesMock,
} from './HostDetailCves.fixtures';

const testProps = { response, status, location, history, match };

const TestComponent = withReactRouter(withMockedProvider(HostDetail));

describe('OpenscapHostDetail', () => {
  it('should show CVEs for host', async () => {
    const pushUrl = jest.fn();
    global.tfm = {
      nav: {
        pushUrl,
      },
    };

    render(<TestComponent mocks={cvesMock} {...testProps} />);
    await waitFor(tick);
    expect(screen.getByText('CVE-2020-14365')).toBeInTheDocument();

    const table = screen.getByLabelText('Table of CVEs');
    userEvent.click(within(table).getByText('1'));
    expect(pushUrl).toHaveBeenCalledWith('/hosts', { search: 'cve_id = 267' });
  });
});
