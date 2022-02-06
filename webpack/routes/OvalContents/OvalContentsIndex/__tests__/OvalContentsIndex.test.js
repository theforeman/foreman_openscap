import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import OvalContentsIndex from '../';

import {
  withRouter,
  withRedux,
  withMockedProvider,
  tick,
  historyMock,
} from '../../../../testHelper';

import {
  mocks,
  emptyMocks,
  errorMocks,
  viewerMocks,
  unauthorizedMocks,
} from './OvalContentsIndex.fixtures';

const TestComponent = withRedux(
  withRouter(withMockedProvider(OvalContentsIndex))
);

describe('OvalContentsIndex', () => {
  it('should load page', async () => {
    render(<TestComponent history={historyMock} mocks={mocks} location={{}} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
    expect(
      screen.getByText(
        'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('openshift OVAL content')).toBeInTheDocument();
    expect(screen.getByText('openshift.oval.xml.bz2')).toBeInTheDocument();
  });
  it('should show empty state', async () => {
    render(
      <TestComponent history={historyMock} mocks={emptyMocks} location={{}} />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('No OVAL Contents found.')).toBeInTheDocument();
  });
  it('should show errors', async () => {
    render(
      <TestComponent history={historyMock} mocks={errorMocks} location={{}} />
    );
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(
      screen.getByText('Something very bad happened.')
    ).toBeInTheDocument();
    expect(screen.getByText('Error!')).toBeInTheDocument();
  });
  it('should load page for user with permissions', async () => {
    render(
      <TestComponent history={historyMock} mocks={viewerMocks} location={{}} />
    );
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getByText('ansible OVAL content')).toBeInTheDocument();
  });
  it('should not load page for user without permissions', async () => {
    render(
      <TestComponent
        history={historyMock}
        mocks={unauthorizedMocks}
        location={{}}
      />
    );
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.queryByText('ansible OVAL content')).not.toBeInTheDocument();
    expect(
      screen.getByText(
        'You are not authorized to view the page. Request the following permissions from administrator: view_oval_contents.'
      )
    ).toBeInTheDocument();
    expect(screen.getByText('Permission denied')).toBeInTheDocument();
  });
});
