import React from 'react';
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
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import EditableInput from '../../../components/EditableInput';

import { onAttrUpdate, policySchedule } from './OvalPoliciesShowHelper';
import updateOvalPolicyMutation from '../../../graphql/mutations/updateOvalPolicy.gql';

const DetailsTab = props => {
  const { policy, showToast } = props;

  const [callMutation] = useMutation(updateOvalPolicyMutation);

  return (
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
          {policySchedule(policy)}
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
  );
};

DetailsTab.propTypes = {
  policy: PropTypes.object.isRequired,
  showToast: PropTypes.func.isRequired,
};

export default DetailsTab;
