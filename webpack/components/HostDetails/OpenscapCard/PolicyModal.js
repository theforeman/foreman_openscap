import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { TypeaheadSelect } from '@patternfly/react-templates';
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
  Modal,
  ModalVariant,
  Spinner,
  Stack,
  StackItem,
} from '@patternfly/react-core';
import { API } from 'foremanReact/redux/API';
import { translate as __, sprintf } from 'foremanReact/common/I18n';

import { sourceForPolicy, toNumber } from './helpers';

const PolicyModal = ({
  allPolicies,
  assignedPolicies,
  availablePolicies,
  canAssignPolicies,
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

  const updatePolicyHosts = async (policy, mode) => {
    setErrorMessage('');
    setSavingPolicyId(toNumber(policy.id));

    try {
      await API.put(`/api/v2/compliance/hosts/bulk/${mode}_compliance_policy`, {
        included: { search: `id = ${hostId}` },
        policy_id: policy.id,
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
      updatePolicyHosts(policy, 'assign');
    }
  };

  const unsetPolicy = policy => {
    updatePolicyHosts(policy, 'unassign');
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
  const policyOptions = availablePolicies.map(policy => ({
    value: String(policy.id),
    content: policy.name,
  }));

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
      title={
        canAssignPolicies
          ? __('Manage compliance policies')
          : __('Compliance policies')
      }
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
                      {canAssignPolicies && source.isDirect && (
                        <DataListAction
                          aria-labelledby={`openscap-policy-${policy.id}`}
                          id={`openscap-policy-${policy.id}-actions`}
                        >
                          <Button
                            ouiaId={`openscap-unset-policy-${policy.id}`}
                            variant="secondary"
                            onClick={() => unsetPolicy(policy)}
                            isLoading={savingPolicyId === toNumber(policy.id)}
                            isDisabled={Boolean(savingPolicyId)}
                          >
                            {__('Unset')}
                          </Button>
                        </DataListAction>
                      )}
                    </DataListItemRow>
                  </DataListItem>
                );
              })}
            </DataList>
          </StackItem>
          {canAssignPolicies && (
            <StackItem>
              <Form>
                <FormGroup
                  label={__('Set direct host policy')}
                  fieldId="policy"
                >
                  <Flex>
                    <FlexItem grow={{ default: 'grow' }}>
                      <fieldset
                        className="openscap-policy-select"
                        disabled={isPolicySelectionDisabled}
                      >
                        <TypeaheadSelect
                          id="policy"
                          selected={selectedPolicyId}
                          selectOptions={policyOptions}
                          filterFunction={(filter, options) =>
                            options.filter(option =>
                              option.content
                                .toLowerCase()
                                .includes(filter.trim().toLowerCase())
                            )
                          }
                          placeholder={policySelectPlaceholder}
                          noOptionsFoundMessage={__('No matching policies')}
                          noOptionsAvailableMessage={policySelectPlaceholder}
                          onSelect={(_event, value) =>
                            setSelectedPolicyId(value)
                          }
                          onInputChange={() => setSelectedPolicyId('')}
                          onClearSelection={() => setSelectedPolicyId('')}
                          isDisabled={isPolicySelectionDisabled}
                          toggleProps={{
                            'aria-label': __('Select policy'),
                            ouiaId: 'openscap-policy-select',
                          }}
                        />
                      </fieldset>
                    </FlexItem>
                    <FlexItem>
                      <Button
                        ouiaId="openscap-set-policy-button"
                        variant="primary"
                        onClick={assignPolicy}
                        isLoading={
                          savingPolicyId === toNumber(selectedPolicyId)
                        }
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
          )}
        </Stack>
      )}
    </Modal>
  );
};

PolicyModal.propTypes = {
  allPolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  assignedPolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  availablePolicies: PropTypes.arrayOf(PropTypes.object).isRequired,
  canAssignPolicies: PropTypes.bool.isRequired,
  hostDetails: PropTypes.object.isRequired,
  hostId: PropTypes.number.isRequired,
  isModalLoading: PropTypes.bool.isRequired,
  isModalOpen: PropTypes.bool.isRequired,
  onModalClose: PropTypes.func.isRequired,
  onModalRefresh: PropTypes.func.isRequired,
};

export default PolicyModal;
