import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { MenuItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  openBulkModal,
  useBulkModalOpen,
} from 'foremanReact/common/BulkModalStateHelper';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import BulkChangeOpenscapProxyModal from './BulkActions/changeOpenscapProxy/BulkChangeOpenscapProxyModal';
import { CHANGE_OPENSCAP_MODAL_ID } from '../OpenscapRemediationWizard/constants';

export const ChangeOpenscapProxyMenuItem = ({ selectedCount }) => {
  const openModal = () => openBulkModal(CHANGE_OPENSCAP_MODAL_ID, true);

  return (
    <MenuItem
      itemId="change-openscap-proxy-dropdown-item"
      key="change-openscap-proxy-dropdown-item"
      onClick={openModal}
      isDisabled={selectedCount === 0}
    >
      {__('OpenSCAP Proxy')}
    </MenuItem>
  );
};

ChangeOpenscapProxyMenuItem.propTypes = {
  selectedCount: PropTypes.number,
};

ChangeOpenscapProxyMenuItem.defaultProps = {
  selectedCount: 0,
};

const BulkChangeOpenscapProxyModalScene = () => {
  const {
    selectAllHostsMode = false,
    selectedCount = 0,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext) || {};

  const { isOpen, close: closeModal } = useBulkModalOpen(
    CHANGE_OPENSCAP_MODAL_ID
  );

  return (
    <BulkChangeOpenscapProxyModal
      key="bulk-change-openscap-proxy-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      onSuccess={refreshTableData}
    />
  );
};

export default BulkChangeOpenscapProxyModalScene;
