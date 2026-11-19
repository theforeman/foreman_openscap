import React from 'react';
import PropTypes from 'prop-types';
import {
  Grid,
  Content,
  ContentVariants,
  Flex,
  FlexItem,
} from '@patternfly/react-core';

import './WizardHeader.scss';

const WizardHeader = ({ title, description }) => (
  <Grid className="oscap-wizard-header">
    {title && (
      <Content>
        <Content ouiaId="wizard-header-text" component={ContentVariants.h2}>
          {title}
        </Content>
      </Content>
    )}
    {description && (
      <Content>
        <Flex flex={{ default: 'inlineFlex' }}>
          <FlexItem>
            <Content>{description}</Content>
          </FlexItem>
        </Flex>
      </Content>
    )}
  </Grid>
);

WizardHeader.propTypes = {
  title: PropTypes.oneOfType([PropTypes.node, PropTypes.string]),
  description: PropTypes.oneOfType([PropTypes.node, PropTypes.string]),
};

WizardHeader.defaultProps = {
  title: undefined,
  description: undefined,
};

export default WizardHeader;
