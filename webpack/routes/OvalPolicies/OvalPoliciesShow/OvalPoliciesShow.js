import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Tabs,
  Tab,
  TabTitleText,
} from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';

import CvesTab from './CvesTab';

import { policySchedule, newJobFormPath } from './OvalPoliciesShowHelper';
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
              title={<TabTitleText>Details</TabTitleText>}
            >
              <TextContent className="pf-u-pt-md">
                <Text component={TextVariants.h3}>Period</Text>
                <Text component={TextVariants.p}>{policySchedule(policy)}</Text>
                <Text component={TextVariants.h3}>Description</Text>
                <Text component={TextVariants.p}>{policy.description}</Text>
              </TextContent>
            </Tab>
            <Tab eventKey="cves" title={<TabTitleText>CVEs</TabTitleText>}>
              <CvesTab {...props} />
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
