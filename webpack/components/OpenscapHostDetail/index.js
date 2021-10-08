import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';

import SkeletonLoader from 'foremanReact/components/common/SkeletonLoader';
import { STATUS } from 'foremanReact/constants';

import { hostPageLinkCell } from '../../helpers/tableHelper';
import EmptyState from '../EmptyState';

import { hashRoute, setActiveKey, cvesPath } from './OpenscapHostDetailHelper';

import SecondaryTabs from './SecondaryTabs';

const OpenscapHostDetail = ({ response, status, location, history, match }) => {
  const errorState = (
    <EmptyState
      error
      title={__('Error!')}
      body={__('There has been an error when loading host information.')}
    />
  );

  return (
    <SkeletonLoader count={5} errorNode={errorState} status={status}>
      <Tabs activeKey={setActiveKey(location)} isSecondary>
        <Tab
          key={cvesPath}
          eventKey={cvesPath}
          title={<TabTitleText>{__('CVEs')}</TabTitleText>}
          href={hashRoute(cvesPath)}
        />
      </Tabs>
      <SecondaryTabs
        response={response}
        history={history}
        match={match}
        hostPageLinkCell={hostPageLinkCell}
      />
    </SkeletonLoader>
  );
};

OpenscapHostDetail.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
  location: PropTypes.object,
  history: PropTypes.object,
  match: PropTypes.object,
};

OpenscapHostDetail.defaultProps = {
  response: {},
  status: STATUS.PENDING,
  location: {},
  history: {},
  match: {},
};

export default OpenscapHostDetail;
