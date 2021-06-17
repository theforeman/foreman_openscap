import React from 'react';
import { useQuery } from '@apollo/client';
import currentUserQuery from '../../../graphql/queries/currentUser.gql';

import OvalContentsForm from './OvalContentsForm';

const OvalContentsNew = props => {
  const useFetchFn = () => useQuery(currentUserQuery);
  const renameData = data => ({ currentUser: data.currentUser });

  return (
    <OvalContentsForm
      {...props}
      fetchFn={useFetchFn}
      renameData={renameData}
      resultPath="currentUser"
      permissions={['create_oval_content']}
    />
  );
};

export default OvalContentsNew;
