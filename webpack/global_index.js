import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import HostKebabItems from './components/HostExtentions/HostKebabItems';
import BulkChangeOpenscapProxyModalScene, {
  ChangeOpenscapProxyMenuItem,
} from './components/HostsIndex/ChangeOpenscapProxyAction';
import BulkCompliancePolicyMenuItems from './components/BulkActions/compliancePolicy/BulkCompliancePolicyMenuItems';
import BulkCompliancePolicyModals from './components/BulkActions/compliancePolicy/BulkCompliancePolicyWrapper';

const HOST_ASSOCIATIONS_WEIGHT = 1212;
const BULK_MODAL_WEIGHT = 100;
const BULK_POLICY_MODAL_WEIGHT = 200;
const OPENSCAP_KEBAB_WEIGHT = 400;

addGlobalFill(
  'host-details-kebab',
  `openscap-kebab-items`,
  <HostKebabItems key="openscap-host-kebab" />,
  OPENSCAP_KEBAB_WEIGHT
);

addGlobalFill(
  '_host-associations',
  'openscap-change-proxy-menu-item',
  <ChangeOpenscapProxyMenuItem key="openscap-change-proxy-menu-item" />,
  HOST_ASSOCIATIONS_WEIGHT
);

addGlobalFill(
  '_all-hosts-modals',
  'BulkChangeOpenscapProxyModal',
  <BulkChangeOpenscapProxyModalScene key="bulk-change-openscap-proxy-modal" />,
  BULK_MODAL_WEIGHT
);

addGlobalFill(
  '_host-associations',
  'compliance-policy-bulk-actions',
  <BulkCompliancePolicyMenuItems key="compliance-policy-menu-items" />,
  BULK_POLICY_MODAL_WEIGHT
);

addGlobalFill(
  '_all-hosts-modals',
  'compliance-policy-modals',
  <BulkCompliancePolicyModals key="compliance-policy-modals" />,
  BULK_POLICY_MODAL_WEIGHT
);
