import React from 'react';
import OvalContentsIndex from './OvalContents/OvalContentsIndex';

import { ovalContentsPath } from '../helpers/pathsHelper';

export default [
  {
    path: ovalContentsPath,
    render: props => <OvalContentsIndex {...props} />,
    exact: true,
  },
];
