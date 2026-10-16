import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Alert,
  Button,
  DataList,
  DataListAction,
  DataListCell,
  DataListItem,
  DataListItemRow,
  Flex,
  FlexItem,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Modal,
  ModalVariant,
  Spinner,
  Stack,
  StackItem,
} from '@patternfly/react-core';
import { API } from 'foremanReact/redux/API';
import { translate as __, sprintf } from 'foremanReact/common/I18n';

import { policyHostIds, sourceForPolicy, toNumber, uniqueIds } from './helpers';

const PolicyModal = ({
  allPolicies,
  assignedPolicies,
  availablePolicies,
  hostDetails,
  hostId,
  isModalLoading,
  isModalOpen,
  onModalClose,
  onModalRefresh,
}) => {
  const [selectedPolicyId, setSelectedPolicyId] = useState('');
  const [savingPolicyId, setSavingPolicyId] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');

  const updatePolicyHosts = async (policy, hostIds) => {
    setErrorMessage('');
    setSavingPolicyId(toNumber(policy.id));

    try {
      await API.put(`/api/v2/compliance/policies/${policy.id}`, {
        policy: { host_ids: uniqueIds(hostIds) },
      });
      setSelectedPolicyId('');
      onModalRefresh();
    } catch (error) {
      setErrorMessage(
        error?.response?.data?.error?.message ||
          error?.message ||
          __('Unable to update policy assignment.')
      );
    } finally {
      setSavingPolicyId(null);
    }
  };

  const assignPolicy = () => {
    const policy = allPolicies.find(
      currentPolicy => toNumber(currentPolicy.id) === toNumber(selectedPolicyId)
    );

    if (policy) {
      updatePolicyHosts(policy, [...policyHostIds(policy), hostId]);
    }
  };

  const unsetPolicy = policy => {
    updatePolicyHosts(
      policy,
      policyHostIds(policy).filter(id => toNumber(id) !== toNumber(hostId))
    );
  };

  const handleModalClose = () => {
    setSelectedPolicyId('');
    setErrorMessage('');
    onModalClose();
  };

  const hasAvailablePolicies = availablePolicies.length > 0;
  const getPolicySelectPlaceholder = () => {
    if (hasAvailablePolicies) {
      return __('Select policy');
    }

    if (allPolicies.length > 0) {
      return __('All policies assigned');
    }

    return __('No policies available');
  };
  const policySelectPlaceholder = getPolicySelectPlaceholder();

  const isPolicySelectionDisabled =
    !hasAvailablePolicies || Boolean(savingPolicyId);

  const actions = [
    <Button
      key="close"
      ouiaId="openscap-policy-modal-close"
      variant="link"
      onClick={handleModalClose}
      isDisabled={Boolean(savingPolicyId)}
    >
      {__('Close')}
    </Button>,
  ];

  return (
    <Modal
      ouiaId="openscap-policy-modal"
      variant={ModalVariant.medium}
      title={__('Manage compliance policies')}
      isOpen={isModalOpen}
      onClose={handleModalClose}
      actions={actions}
    >
      {errorMessage && (
        <Alert
          ouiaId="openscap-policy-update-error"
          variant="danger"
          title={errorMessage}
          isInline
        />
      )}
      {isModalLoading ? (
        <Spinner />
      ) : (
        <Stack hasGutter>
          <StackItem>
            <DataList aria-label={__('Assigned compliance policies')}>
              {assignedPolicies.length === 0 && (
                <DataListItem aria-labelledby="openscap-no-policy">
                  <DataListItemRow>
                    <DataListCell id="openscap-no-policy">
                      {__('No policies assigned')}
                    </DataListCell>
                  </DataListItemRow>
                </DataListItem>
              )}
              {assignedPolicies.map(policy => {
                const source = sourceForPolicy(policy, hostDetails);
                return (
                  <DataListItem
                    key={policy.id}
                    aria-labelledby={`openscap-policy-${policy.id}`}
                  >
                    <DataListItemRow>
                      <DataListCell id={`openscap-policy-${policy.id}`}>
                        <strong>
                          {policy.name || sprintf(__('Policy %s'), policy.id)}
                        </strong>
                        <br />
                        {sprintf(__('Source: %s'), source.label)}
                      </DataListCell>
                      <DataListAction
                        aria-labelledby={`openscap-policy-${policy.id}`}
                        id={`openscap-policy-${policy.id}-actions`}
                      >
                        {source.isDirect && (
                          <Button
                            ouiaId={`openscap-unset-policy-${policy.id}`}
                            variant="secondary"
                            onClick={() => unsetPolicy(policy)}
                            isLoading={savingPolicyId === toNumber(policy.id)}
                            isDisabled={Boolean(savingPolicyId)}
                          >
                            {__('Unset')}
                          </Button>
                        )}
                      </DataListAction>
                    </DataListItemRow>
                  </DataListItem>
                );
              })}
            </DataList>
          </StackItem>
          <StackItem>
            <Form>
              <FormGroup label={__('Set direct host policy')} fieldId="policy">
                <Flex>
                  <FlexItem grow={{ default: 'grow' }}>
                    <FormSelect
                      ouiaId="openscap-policy-select"
                      id="policy"
                      value={selectedPolicyId}
                      onChange={(_event, value) => setSelectedPolicyId(value)}
                      aria-label={__('Select policy')}
                      isDisabled={isPolicySelectionDisabled}
                    >
                      <FormSelectOption
                        isDisabled
                        key="placeholder"
                        value=""
                        label={policySelectPlaceholder}
                      />
                      {availablePolicies.map(policy => (
                        <FormSelectOption
                          key={policy.id}
                          value={String(policy.id)}
                          label={policy.name}
                        />
                      ))}
                    </FormSelect>
                  </FlexItem>
                  <FlexItem>
                    <Button
                      ouiaId="openscap-set-policy-button"
                      variant="primary"
                      onClick={assignPolicy}
                      isLoading={savingPolicyId === toNumber(selectedPolicyId)}
                      isDisabled={
                        !selectedPolicyId || isPolicySelectionDisabled
                      }
                    >
                      {__('Set')}
                    </Button>
                  </FlexItem>
                </Flex>
              </FormGroup>
            </Form>
          </StackItem>
        </Stack>
      )}
    </Modal>
  );
};

PolicyModal.propTypes = {
  allPolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  assignedPolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  availablePolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  hostDetails: PropTypes.object.isRequired,
  hostId: PropTypes.number.isRequired,
  isModalLoading: PropTypes.bool.isRequired,
  isModalOpen: PropTypes.bool.isRequired,
  onModalClose: PropTypes.func.isRequired,
  onModalRefresh: PropTypes.func.isRequired,
};

export default PolicyModal;
