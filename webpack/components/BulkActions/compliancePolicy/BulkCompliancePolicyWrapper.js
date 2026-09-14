import React, { useState, useEffect } from 'react';
import BulkCompliancePolicyModalScene from './index';

const BulkCompliancePolicyModals = () => {
  const [assignModalOpen, setAssignModalOpen] = useState(false);
  const [unassignModalOpen, setUnassignModalOpen] = useState(false);

  useEffect(() => {
    const handleOpenAssign = () => setAssignModalOpen(true);
    const handleOpenUnassign = () => setUnassignModalOpen(true);

    window.addEventListener('openscap:openAssignModal', handleOpenAssign);
    window.addEventListener('openscap:openUnassignModal', handleOpenUnassign);

    return () => {
      window.removeEventListener('openscap:openAssignModal', handleOpenAssign);
      window.removeEventListener(
        'openscap:openUnassignModal',
        handleOpenUnassign
      );
    };
  }, []);

  return (
    <>
      <BulkCompliancePolicyModalScene
        isOpen={assignModalOpen}
        closeModal={() => setAssignModalOpen(false)}
        mode="assign"
      />
      <BulkCompliancePolicyModalScene
        isOpen={unassignModalOpen}
        closeModal={() => setUnassignModalOpen(false)}
        mode="unassign"
      />
    </>
  );
};

export default BulkCompliancePolicyModals;
