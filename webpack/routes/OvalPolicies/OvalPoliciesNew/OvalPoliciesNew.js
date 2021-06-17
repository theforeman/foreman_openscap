import React from 'react';
import { Helmet } from 'react-helmet';
import { Grid, GridItem, TextContent, Text, TextVariants,  } from '@patternfly/react-core';
import IndexLayout from '../../../components/IndexLayout';

import NewOvalPolicyWizard from './NewOvalPolicyWizard';

const OvalPoliciesNew = props => {
  return (
    <IndexLayout pageTitle={__('Create OVAL Policy')}>
      <NewOvalPolicyWizard {...props} />
    </IndexLayout>
   )
}

export default OvalPoliciesNew;