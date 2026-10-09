import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import OpenscapCard, { formatHostgroupTitle } from './index';
import { sourceForPolicy } from './helpers';
import { API } from 'foremanReact/redux/API';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';

jest.mock('foremanReact/redux/API', () => ({
  API: {
    put: jest.fn(() => Promise.resolve({})),
  },
}));

jest.mock('foremanReact/common/hooks/API/APIHooks', () => ({
  useAPI: jest.fn(),
}));

jest.mock('foremanReact/common/helpers', () => ({
  foremanUrl: path => path,
}));

jest.mock('foremanReact/common/I18n', () => ({
  translate: string => string,
  sprintf: (string, ...args) =>
    args.reduce((formatted, arg) => formatted.replace('%s', arg), string),
}));

jest.mock(
  'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate',
  () => {
    const React = require('react');
    return ({ header, children }) =>
      React.createElement(
        'section',
        null,
        React.createElement('h2', null, header),
        children
      );
  }
);

jest.mock('foremanReact/components/common/dates/RelativeDateTime', () => {
  const React = require('react');
  return ({ date, defaultValue }) =>
    React.createElement('span', null, date || defaultValue);
});

const hostDetails = {
  id: 42,
  name: 'host.example.com',
  compliance_status: 2,
  compliance_status_label: 'Incompliant',
  hostgroup_id: 7,
  hostgroup_title: 'Parent/Child',
};

const latestReport = {
  id: 99,
  passed: 10,
  failed: 2,
  othered: 1,
  ['reported_at']: '2026-07-07T10:00:00Z',
};

const assignedPolicies = [
  {
    id: 1,
    name: 'Direct policy',
    hosts: [{ id: 42, name: 'host.example.com' }],
    hostgroups: [],
  },
  {
    id: 2,
    name: 'Host group policy',
    hosts: [],
    hostgroups: [{ id: 7, name: 'Child', title: 'Parent/Child' }],
  },
  {
    id: 3,
    name: 'Parent host group policy',
    hosts: [],
    hostgroups: [{ id: 6, name: 'Parent', title: 'Parent' }],
  },
];

const unassignedPolicy = {
  id: 4,
  name: 'Available policy',
  hosts: [{ id: 100, name: 'other.example.com' }],
  hostgroups: [],
};

const apiFixtures = {
  reports: { results: [latestReport] },
  policiesEnc: assignedPolicies.map(({ id }) => ({ id })),
  policies: { results: [...assignedPolicies, unassignedPolicy] },
};

const mockUseAPI = fixtures => {
  useAPI.mockImplementation((_method, url) => {
    if (url?.startsWith('/api/v2/compliance/arf_reports')) {
      return { response: fixtures.reports, status: 'RESOLVED' };
    }

    if (url === '/api/v2/hosts/42/policies_enc') {
      return { response: fixtures.policiesEnc, status: 'RESOLVED' };
    }

    if (url === '/api/v2/compliance/policies') {
      return { response: fixtures.policies, status: 'RESOLVED' };
    }

    return { response: {}, status: 'RESOLVED' };
  });
};

const renderCard = () => render(<OpenscapCard hostDetails={hostDetails} />);

describe('formatHostgroupTitle', () => {
  it('formats hostgroup hierarchy like Foreman hostgroup selectors', () => {
    expect(formatHostgroupTitle('Parent/Child/Leaf')).toBe(
      'Parent > Child > Leaf'
    );
  });
});

describe('sourceForPolicy', () => {
  it('uses the most specific matching parent host group without sorting', () => {
    expect(
      sourceForPolicy(
        {
          hosts: [],
          hostgroups: [
            { id: 5, name: 'Parent', title: 'Parent' },
            { id: 6, name: 'Child', title: 'Parent/Child' },
          ],
        },
        {
          id: 42,
          hostgroup_id: 7,
          hostgroup_title: 'Parent/Child/Leaf',
        }
      ).label
    ).toBe('Parent host group: Parent > Child');
  });
});

describe('OpenscapCard', () => {
  beforeEach(() => {
    API.put.mockClear();
    useAPI.mockReset();
    mockUseAPI(apiFixtures);
  });

  it('renders status, rule results, latest report and policy count', () => {
    renderCard();

    expect(screen.getByRole('heading', { name: 'Compliance' })).toBeVisible();
    expect(screen.getByText('Incompliant')).toBeVisible();
    expect(screen.getByText('10 passed')).toBeVisible();
    expect(screen.getByText('2 failed')).toBeVisible();
    expect(screen.getByText('1 other')).toBeVisible();
    expect(screen.getByText('3 assigned')).toBeVisible();
    expect(
      screen.getByRole('link', { name: latestReport['reported_at'] })
    ).toHaveAttribute('href', '/compliance/arf_reports/99');
    expect(useAPI).toHaveBeenCalledWith(
      'get',
      '/api/v2/compliance/arf_reports?search=host_id%20%3D%2042%20and%20last_for%20%3D%20host',
      {
        key: 'OPENSCAP_HOST_REPORTS_42',
      }
    );
  });

  it('shows N/A when no policy is assigned', () => {
    mockUseAPI({
      ...apiFixtures,
      policiesEnc: [],
    });

    renderCard();

    expect(screen.getByText('N/A')).toBeVisible();
    expect(screen.getByText('0 assigned')).toBeVisible();
  });

  it('lists policy sources and only allows unsetting direct host policies', () => {
    renderCard();

    fireEvent.click(screen.getByRole('button', { name: '3 assigned' }));

    expect(screen.getByText('Direct policy')).toBeVisible();
    expect(screen.getByText('Source: Direct host')).toBeVisible();
    expect(screen.getByText('Host group policy')).toBeVisible();
    expect(
      screen.getByText('Source: Host group: Parent > Child')
    ).toBeVisible();
    expect(screen.getByText('Parent host group policy')).toBeVisible();
    expect(screen.getByText('Source: Parent host group: Parent')).toBeVisible();
    expect(screen.getAllByRole('button', { name: 'Unset' })).toHaveLength(1);
  });

  it('unsets direct host policies without changing other direct hosts', async () => {
    mockUseAPI({
      ...apiFixtures,
      policies: {
        results: [
          {
            ...assignedPolicies[0],
            hosts: [
              { id: 42, name: 'host.example.com' },
              { id: 100, name: 'other.example.com' },
            ],
          },
          assignedPolicies[1],
          assignedPolicies[2],
          unassignedPolicy,
        ],
      },
    });

    renderCard();

    fireEvent.click(screen.getByRole('button', { name: '3 assigned' }));
    fireEvent.click(screen.getByRole('button', { name: 'Unset' }));

    await waitFor(() =>
      expect(API.put).toHaveBeenCalledWith('/api/v2/compliance/policies/1', {
        policy: { host_ids: [100] },
      })
    );
  });

  it('sets a selected policy directly on the host', async () => {
    renderCard();

    fireEvent.click(screen.getByRole('button', { name: '3 assigned' }));
    fireEvent.change(screen.getByLabelText('Select policy'), {
      target: { value: '4' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Set' }));

    await waitFor(() =>
      expect(API.put).toHaveBeenCalledWith('/api/v2/compliance/policies/4', {
        policy: { host_ids: [100, 42] },
      })
    );
  });

  it('disables direct assignment when no policies are available', () => {
    mockUseAPI({
      ...apiFixtures,
      policiesEnc: [],
      policies: { results: [] },
    });

    renderCard();

    fireEvent.click(screen.getByRole('button', { name: '0 assigned' }));

    expect(screen.getByText('No policies assigned')).toBeVisible();
    expect(screen.getByText('No policies available')).toBeVisible();
    expect(screen.getByLabelText('Select policy')).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Set' })).toBeDisabled();
  });

  it('disables direct assignment when every policy already applies', () => {
    mockUseAPI({
      ...apiFixtures,
      policies: { results: assignedPolicies },
    });

    renderCard();

    fireEvent.click(screen.getByRole('button', { name: '3 assigned' }));

    expect(screen.getByText('All policies assigned')).toBeVisible();
    expect(screen.getByLabelText('Select policy')).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Set' })).toBeDisabled();
  });
});
