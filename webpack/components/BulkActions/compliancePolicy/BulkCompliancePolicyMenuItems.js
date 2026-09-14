import React, { useContext } from 'react';
import { MenuItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';

const BulkCompliancePolicyMenuItems = () => {
  const { selectedCount } = useContext(ForemanHostsIndexActionsBarContext);

  const handleAssignClick = () => {
    window.dispatchEvent(new CustomEvent('openscap:openAssignModal'));
  };

  const handleUnassignClick = () => {
    window.dispatchEvent(new CustomEvent('openscap:openUnassignModal'));
  };

  return (
    <>
      <MenuItem
        itemId="assign-compliance-policy-dropdown-item"
        key="assign-compliance-policy-dropdown-item"
        onClick={handleAssignClick}
        isDisabled={selectedCount === 0}
      >
        {__('Assign compliance policy')}
      </MenuItem>
      <MenuItem
        itemId="unassign-compliance-policy-dropdown-item"
        key="unassign-compliance-policy-dropdown-item"
        onClick={handleUnassignClick}
        isDisabled={selectedCount === 0}
      >
        {__('Unassign compliance policy')}
      </MenuItem>
    </>
  );
};

export default BulkCompliancePolicyMenuItems;
