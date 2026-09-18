import React, { useContext } from 'react';
import { MenuItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { openBulkModal } from 'foremanReact/common/BulkModalStateHelper';
import { usePermissions } from 'foremanReact/common/hooks/Permissions/permissionHooks';
import { EDIT_HOSTS } from 'foremanReact/permissions';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';
import {
  ASSIGN_POLICY_MODAL_ID,
  UNASSIGN_POLICY_MODAL_ID,
  ASSIGN_POLICIES,
} from './constants';

const BulkCompliancePolicyMenuItems = () => {
  const { selectedCount } = useContext(ForemanHostsIndexActionsBarContext);

  const hasPermission = usePermissions([ASSIGN_POLICIES, EDIT_HOSTS]);

  const handleAssignClick = () => openBulkModal(ASSIGN_POLICY_MODAL_ID, true);
  const handleUnassignClick = () =>
    openBulkModal(UNASSIGN_POLICY_MODAL_ID, true);

  return (
    <>
      <MenuItem
        itemId="assign-compliance-policy-dropdown-item"
        key="assign-compliance-policy-dropdown-item"
        onClick={handleAssignClick}
        isDisabled={selectedCount === 0 || !hasPermission}
      >
        {__('Assign compliance policy')}
      </MenuItem>
      <MenuItem
        itemId="unassign-compliance-policy-dropdown-item"
        key="unassign-compliance-policy-dropdown-item"
        onClick={handleUnassignClick}
        isDisabled={selectedCount === 0 || !hasPermission}
      >
        {__('Unassign compliance policy')}
      </MenuItem>
    </>
  );
};

export default BulkCompliancePolicyMenuItems;
