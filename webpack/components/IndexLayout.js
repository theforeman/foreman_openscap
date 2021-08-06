import React from 'react';
import PropTypes from 'prop-types';
import { Helmet } from 'react-helmet';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';

import './IndexLayout.scss';

const IndexLayout = ({
  pageTitle,
  children,
  contentWidthSpan,
  multipleGridItems,
}) => (
  <React.Fragment>
    <Helmet>
      <title>{pageTitle}</title>
    </Helmet>
    <Grid className="scap-page-grid" hasGutter>
      <GridItem span={12} className="pf-u-pb-lg">
        <TextContent>
          <Text component={TextVariants.h1}>{pageTitle}</Text>
        </TextContent>
      </GridItem>
      {multipleGridItems ? (
        children
      ) : (
        <GridItem span={contentWidthSpan}>{children}</GridItem>
      )}
    </Grid>
  </React.Fragment>
);

IndexLayout.propTypes = {
  pageTitle: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.object]).isRequired,
  contentWidthSpan: PropTypes.number,
  multipleGridItems: PropTypes.bool,
};

IndexLayout.defaultProps = {
  contentWidthSpan: 12,
  multipleGridItems: false,
};

export default IndexLayout;
