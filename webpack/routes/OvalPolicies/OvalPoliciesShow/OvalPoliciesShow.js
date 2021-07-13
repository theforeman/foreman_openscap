import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  Grid,
  GridItem,
  Text,
  TextVariants,
  Tabs,
  Tab,
  TabTitleText,
} from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';
import CvesTab from './CvesTab';
import HostgroupsTab from './HostgroupsTab';
import DetailsTab from './DetailsTab';

import { newJobFormPath } from './OvalPoliciesShowHelper';
import { resolvePath } from '../../../helpers/pathsHelper';

const OvalPoliciesShow = props => {
  const { policy, match, history } = props;
  const activeTab = match.params.tab ? match.params.tab : 'details';

  const handleTabSelect = (event, value) => {
    history.push(
      resolvePath(match.path, { ':id': match.params.id, ':tab?': value })
    );
  };

  return (
    <React.Fragment>
      <Helmet>
        <title>{`${policy.name} | OVAL Policy`}</title>
      </Helmet>
      <Grid className="scap-page-grid">
        <GridItem span={10}>
          <Text component={TextVariants.h1}>{policy.name}</Text>
        </GridItem>
        <GridItem span={2}>
          <Link to={newJobFormPath(policy, match.params.id)}>
            <Button variant="secondary">{__('Scan All Hostgroups')}</Button>
          </Link>
        </GridItem>
        <GridItem span={12}>
          <Tabs mountOnEnter activeKey={activeTab} onSelect={handleTabSelect}>
            <Tab
              eventKey="details"
              title={<TabTitleText>{__('Details')}</TabTitleText>}
            >
              <DetailsTab {...props} />
            </Tab>
            <Tab
              eventKey="cves"
              title={<TabTitleText>{__('CVEs')}</TabTitleText>}
            >
              <CvesTab {...props} />
            </Tab>
            <Tab
              eventKey="hostgroups"
              title={<TabTitleText>{__('Hostgroups')}</TabTitleText>}
            >
              <HostgroupsTab {...props} />
            </Tab>
          </Tabs>
        </GridItem>
      </Grid>
    </React.Fragment>
  );
};

OvalPoliciesShow.propTypes = {
  match: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
  policy: PropTypes.object.isRequired,
};

export default withLoading(OvalPoliciesShow);
