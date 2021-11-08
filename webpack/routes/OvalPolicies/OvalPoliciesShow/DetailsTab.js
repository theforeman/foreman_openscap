import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useMutation } from '@apollo/client';

import {
  TextList,
  TextContent,
  TextArea,
  TextListItem,
  TextListVariants,
  TextListItemVariants,
  TextInput,
  Button,
  Split,
  SplitItem,
} from '@patternfly/react-core';

import { PencilAltIcon } from '@patternfly/react-icons';

import { translate as __ } from 'foremanReact/common/I18n';

import EditableInput from '../../../components/EditableInput';
import EditScheduleModal from './EditScheduleModal';

import { onAttrUpdate, policySchedule } from './OvalPoliciesShowHelper';
import updateOvalPolicyMutation from '../../../graphql/mutations/updateOvalPolicy.gql';

const DetailsTab = props => {
  const { policy, showToast } = props;

  const [callMutation] = useMutation(updateOvalPolicyMutation);
  const [scheduleModalOpen, setScheduleModalOpen] = useState(false);

  return (
    <React.Fragment>
      <EditScheduleModal
        isOpen={scheduleModalOpen}
        onClose={() => setScheduleModalOpen(false)}
        policy={policy}
        callMutation={callMutation}
        showToast={showToast}
      />
      <TextContent className="pf-u-pt-md">
        <TextList component={TextListVariants.dl}>
          <TextListItem component={TextListItemVariants.dt}>
            {__('Name')}
          </TextListItem>
          <TextListItem
            aria-label="label text value"
            component={TextListItemVariants.dd}
            className="foreman-spaced-list"
          >
            <EditableInput
              value={policy.name}
              onConfirm={onAttrUpdate('name', policy, callMutation, showToast)}
              component={TextInput}
              attrName="name"
              allowed={policy.meta.canEdit}
            />
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>
            {__('Period')}
          </TextListItem>
          <TextListItem
            aria-label="label text value"
            component={TextListItemVariants.dd}
            className="foreman-spaced-list"
          >
            <Split>
              <SplitItem>{policySchedule(policy)}</SplitItem>
              <SplitItem>
                {policy.meta.canEdit && (
                  <Button
                    className="inline-edit-icon"
                    aria-label="edit schedule"
                    variant="plain"
                    onClick={() => setScheduleModalOpen(true)}
                  >
                    <PencilAltIcon />
                  </Button>
                )}
              </SplitItem>
            </Split>
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>
            {__('Description')}
          </TextListItem>
          <TextListItem
            aria-label="label text value"
            component={TextListItemVariants.dd}
            className="foreman-spaced-list"
          >
            <EditableInput
              value={policy.description}
              onConfirm={onAttrUpdate(
                'description',
                policy,
                callMutation,
                showToast
              )}
              component={TextArea}
              attrName="description"
              allowed={policy.meta.canEdit}
            />
          </TextListItem>
        </TextList>
      </TextContent>
    </React.Fragment>
  );
};

DetailsTab.propTypes = {
  policy: PropTypes.object.isRequired,
  showToast: PropTypes.func.isRequired,
};

export default DetailsTab;
