import React from 'react';
import { useDispatch } from 'react-redux';
import { showToast } from '../../../helpers/toastsHelper';

import OvalContentsNew from './OvalContentsNew';

const WrappedOvalContentsNew = props => {
  const dispatch = useDispatch();

  return <OvalContentsNew {...props} showToast={showToast(dispatch)} />;
};

export default WrappedOvalContentsNew;
