import React from 'react';

import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import api from 'foremanReact/redux/API/API';

import OvalContentsNew from '../OvalContentsNew';
import { withRouter, withRedux, tick } from '../../../../testHelper';
import { ovalContentsPath } from '../../../../helpers/pathsHelper';

jest.mock('foremanReact/redux/API/API', () => ({ post: jest.fn() }));

const TestComponent = withRouter(withRedux(OvalContentsNew));

describe('OvalContentsNew', () => {
  it('should create with content from URL', async () => {
    const pushMock = jest.fn();
    const toastMock = jest.fn();

    api.post.mockImplementation(() => Promise.resolve());

    render(
      <TestComponent history={{ push: pushMock }} showToast={toastMock} />
    );
    expect(screen.getByText('Name')).toBeInTheDocument();
    expect(screen.getByText('OVAL Content Source')).toBeInTheDocument();
    expect(screen.getByText('URL')).toBeInTheDocument();
    expect(screen.queryByText('File')).not.toBeInTheDocument();
    expect(screen.getByText('Submit')).toBeDisabled();
    userEvent.type(screen.getByLabelText('name'), 'test content');
    await waitFor(tick);
    expect(screen.getByText('Submit')).toBeDisabled();
    userEvent.type(
      screen.getByLabelText(/url/),
      'http://oval-content-source.org/security/data/oval/v2/CentOS7/ansible-2.9.oval.xml.bz2'
    );
    await waitFor(tick);
    expect(screen.getByText('Submit')).not.toBeDisabled();
    userEvent.click(screen.getByText('Submit'));
    await waitFor(tick);
    expect(pushMock).toHaveBeenCalledWith(ovalContentsPath, {
      refreshOvalContents: true,
    });
    expect(toastMock).toHaveBeenCalledWith({
      type: 'success',
      message: 'OVAL Content test content successfully created',
    });
  });
  it('should show resource errors', async () => {
    const pushMock = jest.fn();
    const toastMock = jest.fn();
    api.post.mockImplementation(() => {
      // eslint-disable-next-line no-throw-literal
      throw {
        response: {
          status: 422,
          data: { error: { errors: { name: ['has already been taken'] } } },
        },
      };
    });

    render(
      <TestComponent history={{ push: pushMock }} showToast={toastMock} />
    );
    userEvent.type(screen.getByLabelText('name'), 'test content');
    userEvent.type(
      screen.getByLabelText(/url/),
      'http://oval-content-source.org/security/data/oval/v2/CentOS7/ansible-2.9.oval.xml.bz2'
    );
    await waitFor(tick);
    userEvent.click(screen.getByText('Submit'));
    await waitFor(tick);
    expect(pushMock).not.toHaveBeenCalled();
    expect(screen.getByText('has already been taken')).toBeInTheDocument();
  });
  it('should show error toast on unexpected error', async () => {
    const pushMock = jest.fn();
    const toastMock = jest.fn();

    api.post.mockImplementation(() => {
      // eslint-disable-next-line no-throw-literal
      throw { response: { status: 500 } };
    });

    render(
      <TestComponent history={{ push: pushMock }} showToast={toastMock} />
    );
    userEvent.type(screen.getByLabelText('name'), 'test content');
    userEvent.type(
      screen.getByLabelText(/url/),
      'http://oval-content-source.org/security/data/oval/v2/CentOS7/ansible-2.9.oval.xml.bz2'
    );
    await waitFor(tick);
    userEvent.click(screen.getByText('Submit'));
    await waitFor(tick);
    expect(pushMock).not.toHaveBeenCalled();
    expect(screen.getByText('Submit')).not.toBeDisabled();
    expect(toastMock).toHaveBeenCalledWith({
      type: 'error',
      message: 'Unknown error when submitting data, please try again later.',
    });
  });
});
