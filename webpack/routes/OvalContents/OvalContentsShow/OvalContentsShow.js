import React from 'react';
import PropTypes from 'prop-types';
import { Helmet } from 'react-helmet';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';

const OvalContentsShow = ({ ovalContent }) => {
  let contentSource;
  if (ovalContent.url) {
    contentSource = (
      <React.Fragment>
        <Text component={TextVariants.h3}>{__('URL')}</Text>
        <Text component={TextVariants.p}>{ovalContent.url || ''}</Text>
      </React.Fragment>
    );
  } else {
    contentSource = (
      <React.Fragment>
        <Text component={TextVariants.h3}>{__('File')}</Text>
        <Text component={TextVariants.p}>
          {ovalContent.originalFilename || ''}
        </Text>
      </React.Fragment>
    );
  }

  return (
    <React.Fragment>
      <Helmet>
        <title>{`${ovalContent.name} | ${__('OVAL Content')}`}</title>
      </Helmet>
      <Grid className="scap-page-grid">
        <GridItem span={10}>
          <Text component={TextVariants.h1}>{ovalContent.name}</Text>
        </GridItem>
        <GridItem span={2} />
        <GridItem span={12}>
          <TextContent className="pf-u-pt-md">
            <Text component={TextVariants.h3}>{__('Name')}</Text>
            <Text component={TextVariants.p}>{ovalContent.name}</Text>
            {contentSource}
          </TextContent>
        </GridItem>
      </Grid>
    </React.Fragment>
  );
};

OvalContentsShow.propTypes = {
  ovalContent: PropTypes.object.isRequired,
};

export default withLoading(OvalContentsShow);
