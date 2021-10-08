import React from 'react';
import { Link } from 'react-router-dom';
import { TableText } from '@patternfly/react-table';
import { addSearch } from './pageParamsHelper';

export const linkCell = (path, text, search = {}) => (
  <TableText>
    <Link to={addSearch(path, search)}>{text}</Link>
  </TableText>
);

export const hostPageLinkCell = (path, text, search) => (
  <TableText>
    <a href="#" onClick={() => window.tfm.nav.pushUrl(path, search)}>
      {text}
    </a>
  </TableText>
);
