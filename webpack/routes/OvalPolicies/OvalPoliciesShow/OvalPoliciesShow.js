import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';
import CvesTab from './CvesTab';
import HostgroupsTab from './HostgroupsTab';
import DetailsTab from './DetailsTab';

import IndexLayout from '../../../components/IndexLayout';

import ToolbarBtns from './ToolbarBtns';

import { resolvePath } from '../../../helpers/pathsHelper';

const OvalPoliciesShow = props => {
  const { policy, match, history } = props;
  const activeTab = match.params.tab ? match.params.tab : 'details';

  const handleTabSelect = (event, value) => {
    history.push(
      resolvePath(match.path, { ':id': match.params.id, ':tab?': value })
    );
  };

  const toolbarBtns = args => additional => (
    <ToolbarBtns {...args} {...additional} />
  );

  return (
    <IndexLayout
      pageTitle={`${policy.name} | ${__('OVAL Policy')}`}
      toolbarBtns={toolbarBtns({
        id: parseInt(match.params.id, 10),
        policy,
      })}
    >
      <Tabs mountOnEnter activeKey={activeTab} onSelect={handleTabSelect}>
        <Tab
          eventKey="details"
          title={<TabTitleText>{__('Details')}</TabTitleText>}
        >
          <DetailsTab {...props} />
        </Tab>
        <Tab eventKey="cves" title={<TabTitleText>{__('CVEs')}</TabTitleText>}>
          <CvesTab {...props} />
        </Tab>
        <Tab
          eventKey="hostgroups"
          title={<TabTitleText>{__('Hostgroups')}</TabTitleText>}
        >
          <HostgroupsTab {...props} />
        </Tab>
      </Tabs>
    </IndexLayout>
  );
};

OvalPoliciesShow.propTypes = {
  match: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
  policy: PropTypes.object.isRequired,
};

export default withLoading(OvalPoliciesShow);
