import React from 'react';
import '@testing-library/jest-dom';
import { render, screen, waitFor } from '@testing-library/react';

import { withMockedProvider, tick } from '../../../testHelper';
import ovalContentQuery from '../../../graphql/queries/ovalContent.gql';
import OvalContentsShow from './';

const TestComponent = withMockedProvider(OvalContentsShow);

const matchMock = { params: { id: 4 } };
const name = 'dotnet OVAL content';
const url =
  'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2';
const id = 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC00';

const mocks = [
  {
    request: {
      query: ovalContentQuery,
      variables: { id },
    },
    result: {
      data: {
        ovalContent: {
          id,
          name,
          url,
          originalFilename: '',
        },
      },
    },
  },
];

describe('OVAL Contents show page', () => {
  it('should show OVAL Content', async () => {
    render(<TestComponent match={matchMock} mocks={mocks} />);
    expect(screen.getByText('Loading')).toBeInTheDocument();
    await waitFor(tick);
    expect(screen.queryByText('Loading')).not.toBeInTheDocument();
    expect(screen.getAllByText(name).length === 2).toBeTruthy();
    expect(screen.getByText(url)).toBeInTheDocument();
  });
});
