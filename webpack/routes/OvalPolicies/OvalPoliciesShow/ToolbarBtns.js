import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { Button, Flex, FlexItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

import { newJobFormPath } from './OvalPoliciesShowHelper';

import { prepareMutation } from './ToolbarBtnsHelper';

const ToolbarBtns = props => {
  const { policy, id, showToast, modalState, updateModalState } = props;

  let syncButton;
  let handleSyncButton;
  if (policy?.ovalContent?.url) {
    handleSyncButton = () => {
      updateModalState({
        title: __('Sync OVAL Content from a remote source'),
        text: __(
          'The following action will update OVAL Content from url. Are you sure you want to proceed?'
        ),
        isOpen: true,
        record: policy.ovalContent,
        prepareMutation: prepareMutation(showToast, modalState.onClose),
        onConfirm: callMutation =>
          callMutation({ variables: { id: policy.ovalContent.id } }),
      });
    };

    syncButton = (
      <Button onClick={handleSyncButton}>{__('Sync OVAL Content')}</Button>
    );
  }

  return (
    <Flex justifyContent={{ default: 'justifyContentFlexEnd' }}>
      <FlexItem>{syncButton}</FlexItem>
      <FlexItem>
        <Link to={newJobFormPath(policy, id)}>
          <Button variant="secondary">{__('Scan All Hostgroups')}</Button>
        </Link>
      </FlexItem>
    </Flex>
  );
};

ToolbarBtns.propTypes = {
  policy: PropTypes.object.isRequired,
  id: PropTypes.number.isRequired,
  showToast: PropTypes.func.isRequired,
  modalState: PropTypes.object.isRequired,
  updateModalState: PropTypes.func.isRequired,
};

export default ToolbarBtns;
