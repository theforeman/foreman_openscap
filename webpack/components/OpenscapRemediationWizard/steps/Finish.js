/* eslint-disable camelcase */
import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { Button, Bullseye } from '@patternfly/react-core';
import { ExternalLinkSquareAltIcon } from '@patternfly/react-icons';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import Loading from 'foremanReact/components/Loading';
import PermissionDenied from 'foremanReact/components/PermissionDenied';

import OpenscapRemediationWizardContext from '../OpenscapRemediationWizardContext';
import EmptyState from '../../EmptyState';
import ViewSelectedHostsLink from '../ViewSelectedHostsLink';
import { errorMsg, findFixBySnippet } from '../helpers';

import {
  JOB_INVOCATION_PATH,
  JOB_INVOCATION_API_PATH,
  JOB_INVOCATION_API_REQUEST_KEY,
  SNIPPET_SH,
  SNIPPET_ANSIBLE,
} from '../constants';

const Finish = ({ onClose }) => {
  const {
    fixes,
    snippet,
    isRebootSelected,
    hostIdsParam,
    isAllHostsSelected,
    defaultFailedHostsSearch,
  } = useContext(OpenscapRemediationWizardContext);

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
        search_query: isAllHostsSelected
          ? defaultFailedHostsSearch
          : hostIdsParam,
      },
    };
  };

  const response = useAPI('post', JOB_INVOCATION_API_PATH, {
    key: JOB_INVOCATION_API_REQUEST_KEY,
    params: remediationJobParams(),
  });
  const {
    response: { response: { status: statusCode, data } = {} },
    status = STATUS.PENDING,
  } = response;

  const linkToJob = (
    <Button
      variant="link"
      icon={<ExternalLinkSquareAltIcon />}
      iconPosition="right"
      target="_blank"
      component="a"
      href={foremanUrl(`${JOB_INVOCATION_PATH}/${response?.response?.id}`)}
    >
      {__('Job details')}
    </Button>
  );
  const closeBtn = <Button onClick={onClose}>{__('Close')}</Button>;
  const errorComponent =
    statusCode === 403 ? (
      <PermissionDenied
        missingPermissions={data?.error?.missing_permissions}
        primaryButton={closeBtn}
      />
    ) : (
      <EmptyState
        error
        title={__('Error!')}
        body={errorMsg(data)}
        primaryButton={closeBtn}
      />
    );
  const body =
    status === STATUS.RESOLVED ? (
      <EmptyState
        title={__(
          'The job has started on selected host(s), you can check the status on the job details page.'
        )}
        body={
          <>
            {linkToJob}
            <ViewSelectedHostsLink
              isAllHostsSelected={isAllHostsSelected}
              hostIdsParam={hostIdsParam}
              defaultFailedHostsSearch={defaultFailedHostsSearch}
            />
          </>
        }
        primaryButton={closeBtn}
      />
    ) : (
      errorComponent
    );

  return <Bullseye>{status === STATUS.PENDING ? <Loading /> : body}</Bullseye>;
};

Finish.propTypes = {
  onClose: PropTypes.func.isRequired,
};

export default Finish;
