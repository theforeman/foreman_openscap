/* eslint-disable camelcase */
import React, { useContext, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { join } from 'lodash';
import { Button, Bullseye } from '@patternfly/react-core';
import ExternalLinkSquareAltIcon from '@patternfly/react-icons/dist/esm/icons/external-link-square-alt-icon';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import { API_OPERATIONS, post } from 'foremanReact/redux/API';
import Loading from 'foremanReact/components/Loading';

import OpenscapRemediationWizardContext from '../OpenscapRemediationWizardContext';
import EmptyState from '../../EmptyState';
import { errorMsg, findFixBySnippet } from '../helpers';

import {
  JOB_INVOCATION_PATH,
  JOB_INVOCATION_API_PATH,
  JOB_INVOCATION_API_REQUEST_KEY,
  SNIPPET_SH,
  SNIPPET_ANSIBLE,
} from '../constants';

import {
  selectRemediationResponse,
  selectRemediationError,
  selectRemediationStatus,
} from '../OpenscapRemediationSelectors';

const Finish = ({ onClose }) => {
  const { fixes, snippet, hostIds, isRebootSelected } = useContext(
    OpenscapRemediationWizardContext
  );
  const dispatch = useDispatch();
  const [isDispatched, setIsDispatched] = useState(false);
  const response = useSelector(state => selectRemediationResponse(state));
  const status = useSelector(state => selectRemediationStatus(state));
  const error = useSelector(state => selectRemediationError(state));
  const snippetText = findFixBySnippet(fixes, snippet)?.full_text;

  const remediationJobParams = () => {
    let feature = 'script_run_openscap_remediation';
    const inputs = {};
    switch (snippet) {
      case SNIPPET_ANSIBLE:
        feature = 'ansible_run_openscap_remediation';
        inputs.tasks = snippetText;
        inputs.reboot = isRebootSelected;
        break;
      case SNIPPET_SH:
      default:
        feature = 'script_run_openscap_remediation';
        inputs.command = snippetText;
        inputs.reboot = isRebootSelected;
    }

    return {
      job_invocation: {
        feature,
        inputs,
        search_query: `id ^ (${join(hostIds, ',')})`,
      },
    };
  };

  const runCommand = () => {
    setIsDispatched(true);
    dispatch(
      post({
        type: API_OPERATIONS.POST,
        key: JOB_INVOCATION_API_REQUEST_KEY,
        url: JOB_INVOCATION_API_PATH,
        params: remediationJobParams(),
      })
    );
  };

  useEffect(() => {
    if (!isDispatched) runCommand();
  });

  const linkToJob = (
    <Button
      variant="link"
      icon={<ExternalLinkSquareAltIcon />}
      iconPosition="right"
      target="_blank"
      component="a"
      href={foremanUrl(`${JOB_INVOCATION_PATH}/${response.id}`)}
    >
      {__('Job details')}
    </Button>
  );
  const closeBtn = <Button onClick={onClose}>{__('Close')}</Button>;
  const body =
    status === STATUS.RESOLVED ? (
      <EmptyState
        title={sprintf(
          __(
            'The job has started on %s host(s), you can check the status on the job details page.'
          ),
          hostIds.length
        )}
        body={linkToJob}
        primaryButton={closeBtn}
      />
    ) : (
      <EmptyState
        error={error}
        title={__('Error!')}
        body={errorMsg(error)}
        primaryButton={closeBtn}
      />
    );

  return <Bullseye>{status === STATUS.PENDING ? <Loading /> : body}</Bullseye>;
};

Finish.propTypes = {
  onClose: PropTypes.func.isRequired,
};

export default Finish;
