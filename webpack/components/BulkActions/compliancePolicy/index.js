import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import BulkCompliancePolicyModal from './BulkCompliancePolicyModal';

const BulkCompliancePolicyModalScene = ({ isOpen, closeModal, mode }) => {
  const {
    selectAllHostsMode,
    selectedCount,
    selectedResults,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext);

  return (
    <BulkCompliancePolicyModal
      key={`bulk-compliance-policy-modal-${mode}`}
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      selectedResults={selectedResults}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      mode={mode}
      onSuccess={refreshTableData}
    />
  );
};

BulkCompliancePolicyModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  mode: PropTypes.oneOf(['assign', 'unassign']).isRequired,
};

export default BulkCompliancePolicyModalScene;
