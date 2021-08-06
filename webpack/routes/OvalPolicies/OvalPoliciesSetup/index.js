import React from 'react';
import { useLazyQuery } from '@apollo/client';

import {
  Alert,
  Flex,
  FlexItem,
  Button,
  GridItem,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import IndexLayout from '../../../components/IndexLayout';
import OvalPoliciesSetup from './OvalPoliciesSetup';
import ovalPoliciesSetupQuery from '../../../graphql/queries/ovalPoliciesSetup.gql';

const WrappedOvalPoliciesSetup = props => {
  const [
    callFn,
    { data, error, loading },
  ] = useLazyQuery(ovalPoliciesSetupQuery, { fetchPolicy: 'network-only' });

  return (
    <IndexLayout pageTitle={__('Check OVAL Configuration')} multipleGridItems>
      <GridItem>
        <Alert
          variant="info"
          isInline
          title="Check whether the prerequisities for OVAL scanning are met."
        />
      </GridItem>
      <GridItem>
        <Flex>
          <FlexItem>
            <Button
              onClick={callFn}
              isDisabled={loading}
              aria-label="check OVAL setup"
            >
              {__('Check')}
            </Button>
          </FlexItem>
        </Flex>
      </GridItem>
      <OvalPoliciesSetup data={data} error={error} loading={loading} />
    </IndexLayout>
  );
};

export default WrappedOvalPoliciesSetup;
