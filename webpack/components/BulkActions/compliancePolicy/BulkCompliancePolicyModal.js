import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  TextContent,
  Text,
  Select,
  SelectOption,
  SelectList,
  MenuToggle,
  Spinner,
  EmptyState,
  EmptyStateHeader,
  EmptyStateIcon,
  EmptyStateBody,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { ExclamationCircleIcon, SearchIcon } from '@patternfly/react-icons';
import { STATUS } from 'foremanReact/constants';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  selectAPIStatus,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import {
  buildBulkRequestBody,
  bulkErrorToastParams,
} from 'foremanReact/components/HostsIndex/BulkActions/helpers';
import { fetchPolicies, bulkAssignPolicy, bulkUnassignPolicy } from './actions';
import {
  POLICIES_KEY,
  BULK_ASSIGN_POLICY_KEY,
  BULK_UNASSIGN_POLICY_KEY,
} from './constants';

const BulkCompliancePolicyModal = ({
  isOpen,
  closeModal,
  mode,
  selectAllHostsMode,
  selectedCount,
  fetchBulkParams,
  organizationId,
  locationId,
  onSuccess: onSuccessCallback,
}) => {
  const dispatch = useDispatch();
  const [policyId, setPolicyId] = useState('');
  const [policySelectOpen, setPolicySelectOpen] = useState(false);

  useEffect(() => {
    if (isOpen) {
      dispatch(fetchPolicies());
    }
  }, [dispatch, isOpen]);

  const policies = useSelector(state => selectAPIResponse(state, POLICIES_KEY));
  const policiesStatus = useSelector(state =>
    selectAPIStatus(state, POLICIES_KEY)
  );
  const policiesError = useSelector(
    state => state.API?.[POLICIES_KEY]?.error?.message
  );

  const onToggleClick = () => {
    setPolicySelectOpen(!policySelectOpen);
  };

  const handlePolicySelect = (event, selection) => {
    setPolicyId(selection);
    setPolicySelectOpen(false);
  };

  const getPolicyLabel = id =>
    policies?.results?.find(p => p.id.toString() === id)?.name ||
    __('Select a policy');

  const toggle = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      ouiaId="bulk-compliance-policy-toggle"
      onClick={onToggleClick}
      isExpanded={policySelectOpen}
      style={{ width: '500px' }}
    >
      {policyId ? getPolicyLabel(policyId) : __('Select a policy')}
    </MenuToggle>
  );

  const handleModalClose = () => {
    setPolicyId('');
    setPolicySelectOpen(false);
    closeModal();
  };

  const handleError = error => {
    handleModalClose();
    const key =
      mode === 'assign' ? BULK_ASSIGN_POLICY_KEY : BULK_UNASSIGN_POLICY_KEY;
    dispatch(addToast(bulkErrorToastParams(error, key)));
  };

  const handleSuccess = response => {
    dispatch(
      addToast({
        type: 'success',
        message: response.data.message,
      })
    );
    if (onSuccessCallback) onSuccessCallback();
    handleModalClose();
  };

  const handleConfirm = () => {
    const requestBody = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      policy_id: policyId,
    });

    if (mode === 'assign') {
      dispatch(bulkAssignPolicy(requestBody, handleSuccess, handleError));
    } else {
      dispatch(bulkUnassignPolicy(requestBody, handleSuccess, handleError));
    }
  };

  const isAssignMode = mode === 'assign';
  const title = isAssignMode
    ? __('Assign Compliance Policy')
    : __('Unassign Compliance Policy');
  const confirmButtonText = isAssignMode
    ? __('Assign policy')
    : __('Unassign policy');

  const modalActions = [
    <Button
      key="confirm"
      ouiaId="bulk-compliance-policy-modal-confirm-button"
      variant="primary"
      onClick={handleConfirm}
      isDisabled={policyId === ''}
      isLoading={policiesStatus === STATUS.PENDING}
    >
      {confirmButtonText}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-compliance-policy-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];

  const warningMessage = isAssignMode
    ? __(
        'The selected policy will be assigned to the selected hosts. Some hosts may already be assigned to this policy.'
      )
    : __(
        'The selected policy will be unassigned from the selected hosts. Some hosts may not be assigned to this policy.'
      );

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={title}
      variant="medium"
      position="top"
      actions={modalActions}
      id="bulk-compliance-policy-modal"
      key="bulk-compliance-policy-modal"
      ouiaId="bulk-compliance-policy-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-compliance-policy-count">
          {selectAllHostsMode ? (
            <FormattedMessage
              id="bulk-compliance-policy-all-hosts"
              defaultMessage="{action} will affect {boldCount} selected hosts."
              values={{
                action: isAssignMode ? __('Assigning') : __('Unassigning'),
                boldCount: <strong>{__('All')}</strong>,
              }}
            />
          ) : (
            <FormattedMessage
              id="bulk-compliance-policy-selected-hosts"
              defaultMessage="{action} will affect {boldCount} selected {count, plural, one {host} other {hosts}}."
              values={{
                action: isAssignMode ? __('Assigning') : __('Unassigning'),
                count: selectedCount,
                boldCount: <strong>{selectedCount}</strong>,
              }}
            />
          )}
        </Text>
        <Text ouiaId="bulk-compliance-policy-warning">{warningMessage}</Text>
      </TextContent>

      {policiesStatus === STATUS.PENDING && (
        <Flex
          direction={{ default: 'column' }}
          alignItems={{ default: 'alignItemsCenter' }}
          spaceItems={{ default: 'spaceItemsSm' }}
        >
          <FlexItem>
            <Spinner size="lg" aria-label={__('Loading policies')} />
          </FlexItem>
          <FlexItem>
            <Text ouiaId="loading-policies-text">
              {__('Loading policies...')}
            </Text>
          </FlexItem>
        </Flex>
      )}

      {policiesStatus === STATUS.ERROR && (
        <EmptyState>
          <EmptyStateHeader
            titleText={__('Failed to load policies')}
            icon={<EmptyStateIcon icon={ExclamationCircleIcon} />}
            headingLevel="h4"
          />
          <EmptyStateBody>
            {policiesError || __('An error occurred while fetching policies.')}
          </EmptyStateBody>
        </EmptyState>
      )}

      {policiesStatus === STATUS.RESOLVED && policies?.results?.length === 0 && (
        <EmptyState>
          <EmptyStateHeader
            titleText={__('No policies available')}
            icon={<EmptyStateIcon icon={SearchIcon} />}
            headingLevel="h4"
          />
          <EmptyStateBody>
            {__(
              'There are no compliance policies available in your current organization and location.'
            )}
          </EmptyStateBody>
        </EmptyState>
      )}

      {policiesStatus === STATUS.RESOLVED && policies?.results?.length > 0 && (
        <Select
          id="compliance-policy-select"
          isOpen={policySelectOpen}
          selected={policyId}
          onSelect={handlePolicySelect}
          onOpenChange={isSelectOpen => setPolicySelectOpen(isSelectOpen)}
          toggle={toggle}
          shouldFocusToggleOnSelect
          ouiaId="bulk-compliance-policy-select"
        >
          <SelectList>
            {policies.results.map(policy => (
              <SelectOption key={policy.id} value={policy.id.toString()}>
                {policy.name}
              </SelectOption>
            ))}
          </SelectList>
        </Select>
      )}
    </Modal>
  );
};

BulkCompliancePolicyModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  mode: PropTypes.oneOf(['assign', 'unassign']).isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
  selectAllHostsMode: PropTypes.bool.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
  onSuccess: PropTypes.func,
};

BulkCompliancePolicyModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  organizationId: undefined,
  locationId: undefined,
  onSuccess: undefined,
};

export default BulkCompliancePolicyModal;
