import React, { useContext } from 'react';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useBulkModalOpen } from 'foremanReact/common/BulkModalStateHelper';
import BulkCompliancePolicyModal from './BulkCompliancePolicyModal';
import { ASSIGN_POLICY_MODAL_ID, UNASSIGN_POLICY_MODAL_ID } from './constants';

export const BulkAssignPolicyModalScene = () => {
  const {
    selectAllHostsMode,
    selectedCount,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext) || {};

  const { isOpen, close: closeModal } = useBulkModalOpen(
    ASSIGN_POLICY_MODAL_ID
  );

  return (
    <BulkCompliancePolicyModal
      key="bulk-assign-compliance-policy-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      mode="assign"
      onSuccess={refreshTableData}
    />
  );
};

export const BulkUnassignPolicyModalScene = () => {
  const {
    selectAllHostsMode,
    selectedCount,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext) || {};

  const { isOpen, close: closeModal } = useBulkModalOpen(
    UNASSIGN_POLICY_MODAL_ID
  );

  return (
    <BulkCompliancePolicyModal
      key="bulk-unassign-compliance-policy-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      mode="unassign"
      onSuccess={refreshTableData}
    />
  );
};
