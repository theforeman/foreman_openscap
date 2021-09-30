import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import { Route, Switch, Redirect } from 'react-router-dom';

import Loading from 'foremanReact/components/Loading';
import { STATUS } from 'foremanReact/constants';

import EmptyState from '../EmptyState';
import CvesTab from '../../routes/OvalPolicies/OvalPoliciesShow/CvesTab';
import { hostPageLinkCell } from '../../helpers/tableHelper';
import {
  openscapPath,
  hashRoute,
  route,
  setActiveKey,
} from './OpenscapHostDetailHelper';
import TabLayout from './TabLayout';

const OpenscapHostDetail = ({
  response,
  status,
  location,
  history,
  match,
  router,
}) => {
  if (status === STATUS.PENDING) {
    return <Loading />;
  }

  if (status === STATUS.ERROR) {
    return (
      <EmptyState
        error
        title={__('Error!')}
        body={__('There has been an error when loading host information.')}
      />
    );
  }

  const cvesPath = 'cves';

  return (
    <React.Fragment>
      <Tabs activeKey={setActiveKey(location)} isSecondary>
        <Tab
          key={cvesPath}
          eventKey={cvesPath}
          title={<TabTitleText>{__('CVEs')}</TabTitleText>}
          href={hashRoute(cvesPath)}
        />
      </Tabs>
      <Switch>
        <Route exact path={`/${openscapPath}`}>
          <Redirect to={route(cvesPath)} />
        </Route>
        <Route path={route(cvesPath)}>
          <TabLayout>
            <CvesTab
              id={response.id}
              history={history}
              router={router}
              match={match}
              searchKey="host_id"
              linkCell={hostPageLinkCell}
            />
          </TabLayout>
        </Route>
      </Switch>
    </React.Fragment>
  );
};

OpenscapHostDetail.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
  location: PropTypes.object,
  history: PropTypes.object,
  match: PropTypes.object,
  router: PropTypes.object,
};

OpenscapHostDetail.defaultProps = {
  response: {},
  status: STATUS.PENDING,
  location: {},
  history: {},
  match: {},
  router: {}
}

export default OpenscapHostDetail;
