import React from 'react';
import { useSelector } from 'react-redux';
import { DropdownItem } from '@patternfly/react-core';
import { SecurityIcon } from '@patternfly/react-icons';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { translate as __ } from 'foremanReact/common/I18n';
import { HOST_DETAILS_KEY } from 'foremanReact/components/HostDetails/consts';
import { foremanUrl } from 'foremanReact/common/helpers';

const HostKebabItems = () => {
  const { id } = useSelector(state =>
    selectAPIResponse(state, HOST_DETAILS_KEY)
  );

  const compliancePath = foremanUrl(`/compliance/hosts/${id}`);

  return (
    <DropdownItem
      ouiaId="compliance-dropdown-item"
      icon={<SecurityIcon />}
      href={compliancePath}
      target="_blank"
      rel="noreferrer"
    >
      {__('Compliance')}
    </DropdownItem>
  );
};

export default HostKebabItems;
