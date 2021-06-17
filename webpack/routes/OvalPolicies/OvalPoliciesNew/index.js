import React from 'react';
import { useDispatch } from 'react-redux';

import { showToast } from '../../../helpers/toastsHelper';
import OvalPoliciesNew from './OvalPoliciesNew.js';

const WrappedOvalPoliciesNew = props => {
  const dispatch = useDispatch();

  return (
    <OvalPoliciesNew {...props} showToast={showToast(dispatch)} />
  )
}

export default WrappedOvalPoliciesNew;
