import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  Grid,
  GridItem,
  Form,
  FormGroup,
  Select,
  Stack,
  StackItem,
  SelectOption,
  SelectList,
  MenuToggle,
} from '@patternfly/react-core';
import { foremanUrl } from 'foremanReact/common/helpers';
import { APIActions } from 'foremanReact/redux/API';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import {
  BULK_CHANGE_OPENSCAP_PROXY_KEY,
  HOSTS_API_PATH,
  HOSTS_API_REQUEST_KEY,
  OPENSCAP_PROXIES_KEY,
} from '../../../OpenscapRemediationWizard/constants';

const buildBulkRequestBody = ({
  fetchBulkParams,
  organizationId,
  locationId,
  ...params
}) => ({
  included: {
    search: fetchBulkParams(),
  },
  ...(organizationId != null ? { organization_id: organizationId } : {}),
  ...(locationId != null ? { location_id: locationId } : {}),
  ...params,
});

const fetchOpenscapProxies = () =>
  APIActions.get({
    key: OPENSCAP_PROXIES_KEY,
    url: foremanUrl(
      '/api/smart_proxies?search=feature%3DOpenscap&per_page=all'
    ),
  });

const BulkChangeOpenscapProxyModal = ({
  isOpen,
  closeModal,
  selectAllHostsMode,
  selectedCount,
  fetchBulkParams,
  organizationId,
  locationId,
}) => {
  const dispatch = useDispatch();
  const [proxyId, setProxyId] = useState('');
  const [proxySelectOpen, setProxySelectOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isOpen) {
      dispatch(fetchOpenscapProxies());
    } else {
      setIsSubmitting(false);
    }
  }, [dispatch, isOpen]);

  const proxies = useSelector(state =>
    selectAPIResponse(state, OPENSCAP_PROXIES_KEY)
  );
  const proxyStatus = useSelector(state =>
    selectAPIStatus(state, OPENSCAP_PROXIES_KEY)
  );

  const getProxyLabel = id => {
    const proxy = proxies?.results?.find(
      p => p.id.toString() === id.toString()
    );
    return proxy?.name || id;
  };

  const handleProxySelect = (_event, selection) => {
    setProxyId(selection);
    setProxySelectOpen(false);
  };

  const handleToggleClick = () => {
    setProxySelectOpen(!proxySelectOpen);
  };

  const handleModalClose = () => {
    setProxyId('');
    setProxySelectOpen(false);
    setIsSubmitting(false);
    closeModal();
  };

  const handleSuccess = () => {
    dispatch(
      APIActions.get({
        key: HOSTS_API_REQUEST_KEY,
        url: foremanUrl(HOSTS_API_PATH),
      })
    );
    handleModalClose();
  };

  const handleError = () => {
    setIsSubmitting(false);
    handleModalClose();
  };

  const handleConfirm = () => {
    const requestBody = buildBulkRequestBody({
      fetchBulkParams,
      organizationId,
      locationId,
      openscap_proxy_id: proxyId,
    });

    setIsSubmitting(true);
    dispatch(
      APIActions.put({
        key: BULK_CHANGE_OPENSCAP_PROXY_KEY,
        url: foremanUrl('/api/v2/hosts/bulk/change_openscap_proxy'),
        handleSuccess,
        successToast: response => response.data.message,
        handleError,
        errorToast: error =>
          error?.response?.data?.error?.message || __('Error'),
        params: requestBody,
      })
    );
  };

  const descriptionText = selectAllHostsMode ? (
    <>
      {__('Assign OpenSCAP capsule for ')}
      <strong>{__('ALL selected hosts')}</strong>
      <br />
      {__(
        '. This will change previous capsule assignments on the selected hosts.'
      )}
    </>
  ) : (
    <>
      {__('Assign OpenSCAP capsule for ')}
      <strong>{sprintf(__('%s selected hosts.'), selectedCount)}</strong>
      <br />
      {__(
        'This will change previous capsule assignments on the selected hosts.'
      )}
    </>
  );

  const modalActions = [
    <Button
      key="confirm"
      ouiaId="bulk-change-openscap-capsule-modal-confirm-button"
      variant="primary"
      onClick={handleConfirm}
      isDisabled={proxyId === '' || isSubmitting}
      isLoading={isSubmitting}
      spinnerAriaLabel={__('Loading')}
    >
      {__('Assign')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-change-openscap-capsule-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
      isDisabled={isSubmitting}
    >
      {__('Cancel')}
    </Button>,
  ];

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Assign OpenSCAP Capsule')}
      width={650}
      position="top"
      actions={modalActions}
      id="bulk-change-openscap-capsule-modal"
      key="bulk-change-openscap-capsule-modal"
      ouiaId="bulk-change-openscap-capsule-modal"
    >
      <Stack hasGutter>
        <StackItem>{descriptionText}</StackItem>
        {proxyStatus === STATUS.RESOLVED && proxies?.results?.length > 0 && (
          <StackItem>
            <Grid>
              <GridItem span={8}>
                <Form>
                  <FormGroup label={__('Select OpenSCAP Capsule')}>
                    <Select
                      id="openscap-proxy-select"
                      isOpen={proxySelectOpen}
                      selected={proxyId}
                      onSelect={handleProxySelect}
                      onOpenChange={isSelectOpen =>
                        setProxySelectOpen(isSelectOpen)
                      }
                      ouiaId="bulk-change-openscap-capsule-select"
                      toggle={toggleRef => (
                        <MenuToggle
                          ref={toggleRef}
                          onClick={handleToggleClick}
                          isExpanded={proxySelectOpen}
                          style={{ width: '100%' }}
                        >
                          {proxyId
                            ? getProxyLabel(proxyId)
                            : __('Select OpenSCAP Proxy')}
                        </MenuToggle>
                      )}
                    >
                      <SelectList>
                        {proxies.results.map(proxy => (
                          <SelectOption
                            key={proxy.id}
                            value={proxy.id.toString()}
                          >
                            {proxy.name}
                          </SelectOption>
                        ))}
                      </SelectList>
                    </Select>
                  </FormGroup>
                </Form>
              </GridItem>
            </Grid>
          </StackItem>
        )}
        {proxyStatus === STATUS.RESOLVED &&
          (!proxies?.results || proxies.results.length === 0) &&
          __(
            'No OpenSCAP Proxies available. Please configure a Smart Proxy with the OpenSCAP feature.'
          )}
      </Stack>
    </Modal>
  );
};

BulkChangeOpenscapProxyModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  fetchBulkParams: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
  selectAllHostsMode: PropTypes.bool.isRequired,
  organizationId: PropTypes.number,
  locationId: PropTypes.number,
};

BulkChangeOpenscapProxyModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  organizationId: undefined,
  locationId: undefined,
};

export default BulkChangeOpenscapProxyModal;
