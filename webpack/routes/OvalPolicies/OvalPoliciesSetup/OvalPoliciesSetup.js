import React from 'react';
import PropTypes from 'prop-types';
import { Accordion } from '@patternfly/react-core';
import Loading from 'foremanReact/components/Loading';
import { translate as __ } from 'foremanReact/common/I18n';

import EmptyState from '../../../components/EmptyState';
import OvalPoliciesCheck from './OvalPoliciesCheck';

const OvalPoliciesSetup = props => {
  const { data, loading, error } = props;
  if (loading) {
    return <Loading />;
  }

  if (error) {
    return (
      <EmptyState error={error} title={__('Error!')} body={error.message} />
    );
  }

  if (!data) {
    return null;
  }

  return (
    <Accordion>
      {data.ovalPoliciesSetup.map((item, idx) => (
        <OvalPoliciesCheck key={idx} check={item} />
      ))}
    </Accordion>
  );
};

OvalPoliciesSetup.propTypes = {
  data: PropTypes.object,
  loading: PropTypes.bool.isRequired,
  error: PropTypes.object,
};

OvalPoliciesSetup.defaultProps = {
  data: undefined,
  error: undefined,
};

export default OvalPoliciesSetup;
