import React from 'react';
import PropTypes from 'prop-types';

import { ExternalLinkSquareAltIcon } from '@patternfly/react-icons';
import { Button } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { useForemanHostsPageUrl } from 'foremanReact/Root/Context/ForemanContext';

const ViewSelectedHostsLink = ({
  hostIdsParam,
  isAllHostsSelected,
  defaultFailedHostsSearch,
}) => {
  const search = isAllHostsSelected ? defaultFailedHostsSearch : hostIdsParam;
  const url = foremanUrl(`${useForemanHostsPageUrl()}?search=${search}`);
  return (
    <Button
      ouiaId="oscap-rem-wiz-ext-link-to-hosts"
      component="a"
      variant="link"
      icon={<ExternalLinkSquareAltIcon />}
      iconPosition="right"
      target="_blank"
      href={url}
    >
      {__('View selected hosts')}
    </Button>
  );
};

ViewSelectedHostsLink.propTypes = {
  isAllHostsSelected: PropTypes.bool.isRequired,
  defaultFailedHostsSearch: PropTypes.string.isRequired,
  hostIdsParam: PropTypes.string.isRequired,
};

export default ViewSelectedHostsLink;
