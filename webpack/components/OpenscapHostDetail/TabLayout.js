import React from 'react';
import PropTypes from 'prop-types';
import { Grid, GridItem } from '@patternfly/react-core';

import './TabLayout.scss';

const TabLayout = props => (
  <Grid className="openscap-host-tab-layout">
    <GridItem span={12}>{props.children}</GridItem>
  </Grid>
);

TabLayout.propTypes = {
  children: PropTypes.node.isRequired,
};

export default TabLayout;
