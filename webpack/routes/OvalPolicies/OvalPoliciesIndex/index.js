import React from 'react';
import { useDispatch } from 'react-redux';
import { showToast } from '../../../helpers/toastsHelper';

import OvalPoliciesIndex from './OvalPoliciesIndex';

const WrappedOvalPoliciesIndex = props => {
  const dispatch = useDispatch();

  return <OvalPoliciesIndex {...props} showToast={showToast(dispatch)} />;
};

export default WrappedOvalPoliciesIndex;
