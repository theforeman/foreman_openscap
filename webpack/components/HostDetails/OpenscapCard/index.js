import React, { useMemo, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  DescriptionList,
  DescriptionListDescription,
  DescriptionListGroup,
  DescriptionListTerm,
  Flex,
  FlexItem,
  Label,
  Spinner,
} from '@patternfly/react-core';
import { foremanUrl } from 'foremanReact/common/helpers';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';
import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';

import PolicyModal from './PolicyModal';
import {
  collectionResults,
  formatHostgroupTitle,
  statusColor,
  toNumber,
  uniqueIds,
} from './helpers';
import './OpenscapCard.scss';

export { formatHostgroupTitle };

const OpenscapCard = ({ hostDetails }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [reloadToken, setReloadToken] = useState(0);

  const hostId = toNumber(hostDetails.id);
  const reportsSearch = `host_id = ${hostId} and last_for = host`;
  const reportsUrl = `/api/v2/compliance/arf_reports?search=${encodeURIComponent(
    reportsSearch
  )}`;
  const policiesEncUrl = `/api/v2/hosts/${hostId}/policies_enc`;
  const policiesUrl = isModalOpen ? '/api/v2/compliance/policies' : null;

  const { response: reportsResponse, status: reportsStatus } = useAPI(
    'get',
    reportsUrl,
    {
      key: `OPENSCAP_HOST_REPORTS_${hostId}`,
    }
  );

  const { response: policiesEncResponse, status: policiesEncStatus } = useAPI(
    'get',
    policiesEncUrl,
    {
      key: `OPENSCAP_HOST_POLICIES_ENC_${hostId}_${reloadToken}`,
    }
  );

  const { response: policiesResponse, status: policiesStatus } = useAPI(
    'get',
    policiesUrl,
    {
      key: `OPENSCAP_POLICIES_${hostId}_${reloadToken}`,
      params: { per_page: 9999 },
    }
  );

  const reports = collectionResults(reportsResponse);
  const latestReport = reports[0];
  const hostPolicies = collectionResults(policiesEncResponse);
  const allPolicies = collectionResults(policiesResponse);
  const assignedPolicyIds = uniqueIds(hostPolicies.map(({ id }) => id));

  const assignedPolicies = useMemo(
    () =>
      assignedPolicyIds.map(
        id => allPolicies.find(policy => toNumber(policy.id) === id) || { id }
      ),
    [allPolicies, assignedPolicyIds]
  );

  const availablePolicies = allPolicies.filter(
    policy => !assignedPolicyIds.includes(toNumber(policy.id))
  );

  const isLoadingPolicies =
    isModalOpen && (!policiesStatus || policiesStatus === 'PENDING');
  const isLoadingHostPolicies =
    !policiesEncStatus || policiesEncStatus === 'PENDING';
  const hasAssignedPolicies = assignedPolicyIds.length > 0;
  const statusLabel =
    !isLoadingHostPolicies && !hasAssignedPolicies
      ? __('N/A')
      : hostDetails.compliance_status_label || __('Unknown Compliance status');
  const complianceStatus = hasAssignedPolicies
    ? hostDetails.compliance_status
    : undefined;
  const latestReportLink = latestReport?.id
    ? foremanUrl(`/compliance/arf_reports/${latestReport.id}`)
    : undefined;
  const latestReportReportedAt = latestReport?.['reported_at'];

  return (
    <>
      <CardTemplate
        header={__('Compliance')}
        ouiaId="openscap-compliance"
        overrideGridProps={{ xl2: 4, xl: 4, md: 6, lg: 4 }}
      >
        <DescriptionList isHorizontal isCompact>
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Status')}</DescriptionListTerm>
            <DescriptionListDescription>
              <Label color={statusColor(complianceStatus)}>{statusLabel}</Label>
            </DescriptionListDescription>
          </DescriptionListGroup>
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Rule results')}</DescriptionListTerm>
            <DescriptionListDescription>
              {latestReport ? (
                <Flex
                  className="openscap-rule-results"
                  spaceItems={{ default: 'spaceItemsXs' }}
                >
                  <FlexItem>
                    <Label color="green" isCompact>
                      {sprintf(__('%s passed'), latestReport.passed || 0)}
                    </Label>
                  </FlexItem>
                  <FlexItem>
                    <Label color="red" isCompact>
                      {sprintf(__('%s failed'), latestReport.failed || 0)}
                    </Label>
                  </FlexItem>
                  <FlexItem>
                    <Label color="orange" isCompact>
                      {sprintf(__('%s other'), latestReport.othered || 0)}
                    </Label>
                  </FlexItem>
                </Flex>
              ) : (
                __('No report')
              )}
            </DescriptionListDescription>
          </DescriptionListGroup>
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Latest report')}</DescriptionListTerm>
            <DescriptionListDescription>
              <Button
                ouiaId="openscap-latest-report-link"
                variant="link"
                component="a"
                isInline
                isDisabled={!latestReportLink || reportsStatus === 'PENDING'}
                href={latestReportLink}
              >
                <RelativeDateTime
                  date={latestReportReportedAt}
                  defaultValue={__('Never')}
                />
              </Button>
            </DescriptionListDescription>
          </DescriptionListGroup>
          <DescriptionListGroup>
            <DescriptionListTerm>{__('Policies')}</DescriptionListTerm>
            <DescriptionListDescription>
              <Button
                ouiaId="openscap-manage-policies-button"
                variant="link"
                isInline
                onClick={() => setIsModalOpen(true)}
                isDisabled={isLoadingHostPolicies}
              >
                {isLoadingHostPolicies ? (
                  <Spinner size="sm" />
                ) : (
                  sprintf(__('%s assigned'), assignedPolicyIds.length)
                )}
              </Button>
            </DescriptionListDescription>
          </DescriptionListGroup>
        </DescriptionList>
      </CardTemplate>

      <PolicyModal
        allPolicies={allPolicies}
        assignedPolicies={assignedPolicies}
        availablePolicies={availablePolicies}
        hostDetails={hostDetails}
        hostId={hostId}
        isModalLoading={isLoadingPolicies}
        isModalOpen={isModalOpen}
        onModalClose={() => setIsModalOpen(false)}
        onModalRefresh={() => setReloadToken(token => token + 1)}
      />
    </>
  );
};

OpenscapCard.propTypes = {
  hostDetails: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    compliance_status: PropTypes.number,
    compliance_status_label: PropTypes.string,
    hostgroup_id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    hostgroup_title: PropTypes.string,
  }),
};

OpenscapCard.defaultProps = {
  hostDetails: {},
};

export default OpenscapCard;
