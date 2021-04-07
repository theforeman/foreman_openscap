import React from 'react';
import { Link } from 'react-router-dom';
import { TableText } from '@patternfly/react-table';

export const linkCell = (path, text) => (
  <TableText>
    <Link to={path}>{text}</Link>
  </TableText>
);
