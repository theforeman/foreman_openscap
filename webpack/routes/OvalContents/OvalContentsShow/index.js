import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';

import { translate as __ } from 'foremanReact/common/I18n';

import OvalContentsShow from './OvalContentsShow';
import { encodeId } from '../../../helpers/globalIdHelper';

import ovalContent from '../../../graphql/queries/ovalContent.gql';

const WrappedOvalContentsShow = props => {
  const id = encodeId('ForemanOpenscap::OvalContent', props.match.params.id);

  const useFetchFn = componentProps =>
    useQuery(ovalContent, { variables: { id } });

  const renameData = data => ({ ovalContent: data.ovalContent });

  return (
    <OvalContentsShow
      {...props}
      fetchFn={useFetchFn}
      renameData={renameData}
      resultPath="ovalContent"
      emptyStateTitle={__('No OVAL Content found')}
    />
  );
};

WrappedOvalContentsShow.propTypes = {
  match: PropTypes.object.isRequired,
};

export default WrappedOvalContentsShow;
