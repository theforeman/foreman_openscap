import React from 'react';

import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { i18nProviderWrapperFactory } from 'foremanReact/common/i18nProviderWrapperFactory';

import OvalPoliciesShow from '../';
import {
  historyMock,
  ovalPolicyId,
  policyDetailMock,
  policyEditPermissionsMock,
  ovalPolicy,
} from './OvalPoliciesShow.fixtures';
import {
  policyUpdateMock,
  policyUpdateErrorMock,
  policyUpdateValidationMock,
  updatedName,
} from './OvalPoliciesEdit.fixtures';
import { ovalPoliciesShowPath } from '../../../../helpers/pathsHelper';

import {
  withMockedProvider,
  tick,
  withRouter,
  withRedux,
} from '../../../../testHelper';

import * as toasts from '../../../../helpers/toastHelper';

const TestComponent = i18nProviderWrapperFactory(
  new Date('2021-08-28 00:00:00 -1100'),
  'UTC'
)(withRouter(withRedux(withMockedProvider(OvalPoliciesShow))));

describe('OvalPoliciesShow', () => {
  it('should open and close inline edit for name', async () => {
    render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    userEvent.click(screen.getByRole('button', { name: 'edit name' }));
    userEvent.clear(screen.getByLabelText(/name text input/));
    userEvent.type(screen.getByLabelText(/name text input/), 'foo');
    expect(screen.getByLabelText(/name text input/)).toHaveAttribute(
      'value',
      'foo'
    );
    userEvent.click(
      screen.getByRole('button', { name: 'cancel editing name' })
    );
    expect(screen.queryByText('foo')).not.toBeInTheDocument();
  });
  it('should update policy name', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);

    const { container } = render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock.concat(policyUpdateMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    const editBtn = screen.getByRole('button', { name: 'edit name' });
    expect(editBtn).toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'submit name' })
    ).not.toBeInTheDocument();

    userEvent.click(editBtn);
    expect(
      screen.queryByRole('button', { name: 'edit name' })
    ).not.toBeInTheDocument();
    const inputField = screen.getByLabelText(/name text input/);
    const submitBtn = screen.getByRole('button', { name: 'submit name' });
    const cancelBtn = screen.getByRole('button', {
      name: 'cancel editing name',
    });

    userEvent.clear(inputField);
    userEvent.type(inputField, updatedName);
    userEvent.click(submitBtn);
    expect(inputField).toBeDisabled();
    expect(submitBtn).toBeDisabled();
    expect(cancelBtn).toBeDisabled();
    const spinner = container.querySelector('#edit-name-spinner');
    expect(spinner).toBeInTheDocument();
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL policy was successfully updated.',
    });

    expect(inputField).not.toBeInTheDocument();
    expect(editBtn).toBeInTheDocument();
    expect(cancelBtn).not.toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'submit name' })
    ).not.toBeInTheDocument();
    await waitFor(tick);
    expect(screen.getAllByText(updatedName).pop()).toBeInTheDocument();
  });
  it('should show unexpected errors', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);

    render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock.concat(policyUpdateErrorMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    const editBtn = screen.getByRole('button', { name: 'edit name' });
    userEvent.click(editBtn);
    const inputField = screen.getByLabelText(/name text input/);
    userEvent.clear(inputField);
    userEvent.type(inputField, updatedName);
    userEvent.click(screen.getByRole('button', { name: 'submit name' }));
    await waitFor(tick);
    expect(showToast).toHaveBeenCalledWith({
      type: 'error',
      message:
        'There was a following error when updating OVAL policy: This is an unexpected failure.',
    });
    expect(inputField).toBeInTheDocument();
    expect(inputField).not.toBeDisabled();
    expect(
      screen.getByText(`${ovalPolicy.name} | OVAL Policy`)
    ).toBeInTheDocument();
  });
  it('should show validation errors', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);

    const { container } = render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyDetailMock.concat(policyUpdateValidationMock)}
      />
    );
    await waitFor(tick);
    await waitFor(tick);
    const editBtn = screen.getByRole('button', { name: 'edit name' });
    userEvent.click(editBtn);
    const inputField = screen.getByLabelText(/name text input/);
    userEvent.clear(inputField);
    userEvent.type(inputField, updatedName);
    userEvent.click(screen.getByRole('button', { name: 'submit name' }));
    await waitFor(tick);
    expect(inputField).toBeInTheDocument();
    expect(inputField).not.toBeDisabled();
    expect(
      container.querySelector('#edit-name-spinner')
    ).not.toBeInTheDocument();
    expect(
      screen.getByText(`${ovalPolicy.name} | OVAL Policy`)
    ).toBeInTheDocument();
    expect(screen.getByText('has already been taken')).toBeInTheDocument();
  });
  it('should not show edit btns when user is not allowed to edit', async () => {
    render(
      <TestComponent
        history={historyMock}
        match={{
          params: { id: ovalPolicyId, tab: 'details' },
          path: ovalPoliciesShowPath,
        }}
        mocks={policyEditPermissionsMock}
      />
    );
    await waitFor(tick);
    expect(
      screen.queryByRole('button', { name: 'edit name' })
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'edit description' })
    ).not.toBeInTheDocument();
  });
});
