import React from 'react';
import PropTypes from 'prop-types';
import { Route, Switch, Redirect } from 'react-router-dom';
import CvesTab from '../../routes/OvalPolicies/OvalPoliciesShow/CvesTab';

import TabLayout from './TabLayout';
import { openscapPath, route, cvesPath } from './OpenscapHostDetailHelper';

const SecondaryTabs = ({ response, history, match, hostPageLinkCell }) => (
  <Switch>
    <Route exact path={`/${openscapPath}`}>
      <Redirect to={route(cvesPath)} />
    </Route>
    <Route path={route(cvesPath)}>
      <TabLayout>
        <CvesTab
          id={response.id}
          history={history}
          match={match}
          searchKey="host_id"
          linkCell={hostPageLinkCell}
        />
      </TabLayout>
    </Route>
  </Switch>
);

SecondaryTabs.propTypes = {
  response: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
  match: PropTypes.object.isRequired,
  hostPageLinkCell: PropTypes.func.isRequired,
};

export default SecondaryTabs;
