import React from 'react';
import { useDispatch } from 'react-redux';

import { showToast } from '../../../helpers/toastHelper';
import OvalPoliciesNew from './OvalPoliciesNew';

const WrappedOvalPoliciesNew = props => (
  <OvalPoliciesNew {...props} showToast={showToast(useDispatch())} />
);

export default WrappedOvalPoliciesNew;
