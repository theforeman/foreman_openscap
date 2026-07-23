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
  Stack,
  StackItem,
  Skeleton,
} from '@patternfly/react-core';
import { SimpleDropdown } from '@patternfly/react-templates';
import { foremanUrl } from 'foremanReact/common/helpers';
import { APIActions } from 'foremanReact/redux/API';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  selectAPIStatus,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { buildBulkRequestBody } from 'foremanReact/components/HostsIndex/BulkActions/helpers';
import {
  BULK_CHANGE_OPENSCAP_PROXY_KEY,
  OPENSCAP_PROXIES_KEY,
} from '../../../OpenscapRemediationWizard/constants';

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
  onSuccess: onSuccessCallback,
}) => {
  const dispatch = useDispatch();
  const [proxyId, setProxyId] = useState('');
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

  const handleModalClose = () => {
    setProxyId('');
    setIsSubmitting(false);
    closeModal();
  };

  const handleSuccess = () => {
    handleModalClose();
    if (onSuccessCallback) onSuccessCallback();
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
        errorToast: error => error?.response?.data?.error?.message,
        params: requestBody,
      })
    );
  };

  const descriptionText = selectAllHostsMode ? (
    <>
      {__('Assign OpenSCAP Proxy for ')}
      <strong>{__('ALL selected hosts.')}</strong>
      <br />
      {__('This will change previous proxy assignments on the selected hosts.')}
    </>
  ) : (
    <>
      {__('Assign OpenSCAP Proxy for ')}
      <strong>{sprintf(__('%s selected hosts.'), selectedCount)}</strong>
      <br />
      {__('This will change previous proxy assignments on the selected hosts.')}
    </>
  );

  const getProxyLabel = id => {
    const proxy = proxies?.results?.find(
      p => p.id.toString() === id.toString()
    );
    return proxy?.name || id;
  };

  const proxyItems =
    proxies?.results?.map(proxy => ({
      value: proxy.id.toString(),
      content: proxy.name,
      onClick: () => setProxyId(proxy.id.toString()),
    })) || [];

  const modalActions = [
    <Button
      key="confirm"
      ouiaId="bulk-change-openscap-proxy-modal-confirm-button"
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
      ouiaId="bulk-change-openscap-proxy-modal-cancel-button"
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
      title={__('Assign OpenSCAP Proxy')}
      variant="small"
      position="top"
      actions={modalActions}
      id="bulk-change-openscap-proxy-modal"
      key="bulk-change-openscap-proxy-modal"
      ouiaId="bulk-change-openscap-proxy-modal"
    >
      <Stack hasGutter>
        <StackItem>{descriptionText}</StackItem>
        {proxyStatus === STATUS.RESOLVED && proxies?.results?.length > 0 && (
          <StackItem>
            <Grid>
              <GridItem span={8}>
                <Form>
                  <FormGroup label={__('Select OpenSCAP Proxy')}>
                    <SimpleDropdown
                      id="openscap-proxy-select"
                      ouiaId="bulk-change-openscap-proxy-select"
                      toggleContent={
                        proxyId
                          ? getProxyLabel(proxyId)
                          : __('Select OpenSCAP Proxy')
                      }
                      initialItems={proxyItems}
                    />
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
        {proxyStatus === STATUS.PENDING && (
          <Skeleton screenreaderText="Loading contents" />
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
  onSuccess: PropTypes.func,
};

BulkChangeOpenscapProxyModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  organizationId: undefined,
  locationId: undefined,
  onSuccess: undefined,
};

export default BulkChangeOpenscapProxyModal;
