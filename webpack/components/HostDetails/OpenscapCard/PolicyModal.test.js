import React from 'react';
import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { useDispatch } from 'react-redux';
import { APIActions } from 'foremanReact/redux/API';
import { updateHost } from 'foremanReact/components/HostDetails/ActionsBar/actions';

import PolicyModal from './PolicyModal';

jest.mock('react-redux', () => ({
  useDispatch: jest.fn(),
}));

jest.mock('foremanReact/redux/API', () => ({
  APIActions: {
    put: jest.fn(params => ({ type: 'API_PUT', params })),
  },
}));

jest.mock('foremanReact/components/HostDetails/ActionsBar/actions', () => ({
  updateHost: jest.fn(hostId => ({ type: 'UPDATE_HOST', hostId })),
}));

jest.mock('foremanReact/common/helpers', () => ({
  foremanUrl: path => path,
}));

jest.mock('foremanReact/common/I18n', () => ({
  translate: string => string,
  sprintf: (string, ...args) =>
    args.reduce((formatted, arg) => formatted.replace('%s', arg), string),
}));

jest.mock('@patternfly/react-templates', () => ({
  TypeaheadSelect: ({
    selectOptions,
    selected,
    onSelect,
    onInputChange,
    filterFunction,
    isDisabled,
  }) => {
    const React = require('react');
    const [filter, setFilter] = React.useState('');
    const filteredOptions = filter
      ? filterFunction(filter, selectOptions)
      : selectOptions;
    return React.createElement(
      React.Fragment,
      null,
      React.createElement(
        'select',
        {
          'aria-label': 'Select policy',
          value: selected,
          disabled: isDisabled,
          onChange: event => onSelect(event, event.target.value),
        },
        React.createElement('option', { value: '' }, 'Select policy'),
        filteredOptions.map(({ value, content }) =>
          React.createElement('option', { key: value, value }, content)
        )
      ),
      React.createElement('input', {
        'aria-label': 'Search policies',
        onChange: event => {
          setFilter(event.target.value);
          onInputChange(event.target.value);
        },
      })
    );
  },
}));

const hostDetails = { id: 42 };
const directPolicy = {
  id: 1,
  name: 'Direct policy',
  hosts: [{ id: 42 }],
  hostgroups: [],
};
const availablePolicy = {
  id: 4,
  name: 'Available policy',
  hosts: [],
  hostgroups: [],
};
const otherPolicy = {
  id: 5,
  name: 'Another policy',
  hosts: [],
  hostgroups: [],
};
const dispatch = jest.fn();
const onModalRefresh = jest.fn();

const renderModal = () =>
  render(
    <PolicyModal
      allPolicies={[directPolicy, availablePolicy, otherPolicy]}
      assignedPolicies={[directPolicy]}
      availablePolicies={[availablePolicy, otherPolicy]}
      canAssignPolicies
      hostDetails={hostDetails}
      hostId={hostDetails.id}
      isModalLoading={false}
      isModalOpen
      onModalClose={jest.fn()}
      onModalRefresh={onModalRefresh}
    />
  );

describe('PolicyModal assignments', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    useDispatch.mockReturnValue(dispatch);
  });

  it('assigns the selected policy and refreshes the host on success', async () => {
    renderModal();

    await userEvent.selectOptions(screen.getByRole('combobox'), '4');
    await userEvent.click(screen.getByRole('button', { name: 'Set' }));

    expect(APIActions.put).toHaveBeenCalledWith(
      expect.objectContaining({
        url: '/api/v2/compliance/hosts/bulk/assign_compliance_policy',
        params: {
          included: { search: 'id = 42' },
          policy_id: availablePolicy.id,
        },
      })
    );

    act(() => APIActions.put.mock.calls[0][0].handleSuccess({}));

    expect(onModalRefresh).toHaveBeenCalled();
    expect(updateHost).toHaveBeenCalledWith(hostDetails.id);
    expect(dispatch).toHaveBeenCalledWith({
      type: 'UPDATE_HOST',
      hostId: hostDetails.id,
    });
  });

  it('refreshes the host after unassigning a direct policy', async () => {
    renderModal();

    await userEvent.click(screen.getByRole('button', { name: 'Unset' }));

    expect(APIActions.put).toHaveBeenCalledWith(
      expect.objectContaining({
        url: '/api/v2/compliance/hosts/bulk/unassign_compliance_policy',
        params: {
          included: { search: 'id = 42' },
          policy_id: directPolicy.id,
        },
      })
    );

    act(() => APIActions.put.mock.calls[0][0].handleSuccess({}));

    expect(onModalRefresh).toHaveBeenCalled();
    expect(updateHost).toHaveBeenCalledWith(hostDetails.id);
  });

  it('clears the selected policy when searching again', async () => {
    renderModal();

    await userEvent.selectOptions(screen.getByRole('combobox'), '4');
    expect(screen.getByRole('button', { name: 'Set' })).toBeEnabled();

    await userEvent.type(
      screen.getByRole('textbox', { name: 'Search policies' }),
      'other'
    );

    expect(screen.getByRole('button', { name: 'Set' })).toBeDisabled();
  });

  it('filters available policies case-insensitively', async () => {
    renderModal();

    await userEvent.type(
      screen.getByRole('textbox', { name: 'Search policies' }),
      'AVAIL'
    );

    expect(
      screen.getByRole('option', { name: 'Available policy' })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('option', { name: 'Another policy' })
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('option', { name: 'Direct policy' })
    ).not.toBeInTheDocument();
  });
});
