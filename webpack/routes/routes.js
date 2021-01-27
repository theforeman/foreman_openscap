import React from 'react';
import OvalContentsIndex from './OvalContents/OvalContentsIndex';
import OvalPoliciesIndex from './OvalPolicies/OvalPoliciesIndex';

import { ovalContentsPath, ovalPoliciesPath } from '../helpers/pathsHelper';

export default [
  {
    path: ovalContentsPath,
    render: props => <OvalContentsIndex {...props} />,
    exact: true,
  },
  {
    path: ovalPoliciesPath,
    render: props => <OvalPoliciesIndex {...props} />,
    exact: true,
  },
];
