import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { translate as __ } from 'foremanReact/common/I18n';

import IndexLayout from '../../../components/IndexLayout';
import OvalContentsTable from './OvalContentsTable';
import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';
import ovalContentsQuery from '../../../graphql/queries/ovalContents.gql';

const OvalContentsIndex = props => {
  const useFetchFn = componentProps =>
    useQuery(ovalContentsQuery, {
      variables: useParamsToVars(componentProps.history),
    });

  const renameData = data => ({
    ovalContents: data.ovalContents.nodes,
    totalCount: data.ovalContents.totalCount,
  });

  const pagination = useCurrentPagination(props.history);

  return (
    <IndexLayout pageTitle={__('OVAL Contents')}>
      <OvalContentsTable
        {...props}
        fetchFn={useFetchFn}
        renameData={renameData}
        queryName="ovalContents"
        pagination={pagination}
        emptyStateTitle={__('No OVAL Contents found.')}
      />
    </IndexLayout>
  );
};

OvalContentsIndex.propTypes = {
  history: PropTypes.object.isRequired,
};

export default OvalContentsIndex;
