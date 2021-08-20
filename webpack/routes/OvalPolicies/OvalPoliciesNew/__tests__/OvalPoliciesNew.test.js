import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import OvalPoliciesNew from '../';
import { ovalPoliciesPath } from '../../../../helpers/pathsHelper';

import { unpagedMocks as ovalContentMocks } from '../../../OvalContents/OvalContentsIndex/__tests__/OvalContentsIndex.fixtures';

import {
  withMockedProvider,
  wait,
  withRouter,
  withRedux,
} from '../../../../testHelper';

import {
  newPolicyName,
  newPolicyDescription,
  newPolicyCronline,
  newPolicyContentName,
  policySuccessMock,
  policyValidationMock,
  policyPreconditionMock,
  policyInvalidHgMock,
  hostgroupsMock,
  firstHg,
  roleAbsent as roleAbsentCheck,
  hgWithoutProxy as withoutProxyCheck,
} from './OvalPoliciesNew.fixtures';

import * as toasts from '../../../../helpers/toastsHelper';

const TestComponent = withRouter(
  withRedux(withMockedProvider(OvalPoliciesNew))
);

describe('OvalPoliciesNew', () => {
  it('should create new OVAL policy', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);
    const pushMock = jest.fn();

    render(
      <TestComponent
        mocks={ovalContentMocks.concat(policySuccessMock)}
        history={{
          push: pushMock,
        }}
      />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await wait();
    const submitBtn = screen.getByRole('button', { name: 'submit' });
    expect(submitBtn).toBeDisabled();
    userEvent.type(screen.getByLabelText(/name/), newPolicyName);
    await wait();
    expect(submitBtn).toBeDisabled();
    userEvent.type(screen.getByLabelText(/cronLine/), 'foo');
    userEvent.type(screen.getByLabelText(/description/), newPolicyDescription);
    userEvent.selectOptions(
      screen.getByLabelText(/ovalContentId/),
      newPolicyContentName
    );
    await wait();
    expect(screen.getByText('is not a valid cronline')).toBeInTheDocument();
    expect(submitBtn).toBeDisabled();
    userEvent.clear(screen.getByLabelText(/cronLine/));
    userEvent.type(screen.getByLabelText(/cronLine/), newPolicyCronline);
    await wait();
    expect(
      screen.queryByText('is not a valid cronline')
    ).not.toBeInTheDocument();
    expect(submitBtn).not.toBeDisabled();
    userEvent.click(submitBtn);
    await wait(2);
    expect(pushMock).toHaveBeenCalledWith(ovalPoliciesPath);
    expect(showToast).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL Policy succesfully created.',
    });
  });
  it('should not create new policy on validation error', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);
    const pushMock = jest.fn();

    render(
      <TestComponent
        mocks={ovalContentMocks.concat(policyValidationMock)}
        history={{
          push: pushMock,
        }}
      />
    );
    await wait();
    userEvent.type(screen.getByLabelText(/name/), newPolicyName);
    userEvent.type(screen.getByLabelText(/cronLine/), newPolicyCronline);
    userEvent.selectOptions(
      screen.getByLabelText(/ovalContentId/),
      newPolicyContentName
    );
    await wait();
    userEvent.click(screen.getByRole('button', { name: 'submit' }));
    await wait(2);
    expect(pushMock).not.toHaveBeenCalled();
    expect(showToast).not.toHaveBeenCalled();
    expect(screen.getByText('has already been taken')).toBeInTheDocument();
  });
  it('should not create policy on preconditions error', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);
    const pushMock = jest.fn();

    render(
      <TestComponent
        mocks={ovalContentMocks.concat(policyPreconditionMock)}
        history={{
          push: pushMock,
        }}
      />
    );
    await wait();
    userEvent.type(screen.getByLabelText(/name/), newPolicyName);
    userEvent.type(screen.getByLabelText(/cronLine/), newPolicyCronline);
    userEvent.selectOptions(
      screen.getByLabelText(/ovalContentId/),
      newPolicyContentName
    );
    await wait();
    userEvent.click(screen.getByRole('button', { name: 'submit' }));
    await wait(2);
    await wait();
    expect(pushMock).not.toHaveBeenCalled();
    expect(showToast).toHaveBeenCalledWith({
      type: 'error',
      message: roleAbsentCheck.failMsg,
    });
  });
  it('should show hostgroup errros', async () => {
    const showToast = jest.fn();
    jest.spyOn(toasts, 'showToast').mockImplementation(() => showToast);
    const pushMock = jest.fn();

    render(
      <TestComponent
        mocks={ovalContentMocks
          .concat(policyInvalidHgMock)
          .concat(hostgroupsMock)}
        history={{
          push: pushMock,
        }}
      />
    );
    await wait();
    userEvent.type(screen.getByLabelText(/name/), newPolicyName);
    userEvent.type(screen.getByLabelText(/cronLine/), newPolicyCronline);
    userEvent.selectOptions(
      screen.getByLabelText(/ovalContentId/),
      newPolicyContentName
    );
    userEvent.type(screen.getByLabelText(/hostgroup/), 'first');
    await wait(500);
    userEvent.click(screen.getByText(firstHg.name));
    await wait();
    userEvent.click(screen.getByRole('button', { name: 'submit' }));
    await wait(2);
    expect(pushMock).not.toHaveBeenCalled();
    expect(screen.getByText(withoutProxyCheck.failMsg)).toBeInTheDocument();
  });
});
