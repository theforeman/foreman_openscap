import React from 'react';
import { useDispatch } from 'react-redux';
import { showToast } from '../../../helpers/toastsHelper';

import OvalContentsIndex from './OvalContentsIndex';

const WrappedOvalContentsIndex = props => {
  const dispatch = useDispatch();

  return <OvalContentsIndex {...props} showToast={showToast(dispatch)} />;
};

export default WrappedOvalContentsIndex;
