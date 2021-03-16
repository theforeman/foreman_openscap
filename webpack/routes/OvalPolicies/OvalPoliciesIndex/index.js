import React from 'react';
import { useDispatch } from 'react-redux';
import { addToast } from 'foremanReact/redux/actions/toasts';

import OvalPoliciesIndex from './OvalPoliciesIndex';

const WrappedOvalPoliciesIndex = props => {
  const dispatch = useDispatch();

  const showToast = toast => dispatch(addToast(toast));

  return <OvalPoliciesIndex {...props} showToast={showToast} />;
};

export default WrappedOvalPoliciesIndex;
