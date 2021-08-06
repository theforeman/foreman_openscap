import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  ExclamationCircleIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
} from '@patternfly/react-icons';

import {
  AccordionItem,
  AccordionContent,
  AccordionToggle,
  Flex,
  FlexItem,
} from '@patternfly/react-core';

const OvalPoliciesCheck = props => {
  const [isExpanded, setIsExpanded] = useState(false);

  const selectIcon = check => {
    if (check.result === 'pass') {
      return <CheckCircleIcon />;
    }

    if (check.result === 'fail') {
      return <ExclamationCircleIcon />;
    }

    return <ExclamationTriangleIcon />;
  };

  const selectText = check => {
    if (check.result === 'pass') {
      return __('OK');
    }

    if (check.result === 'fail') {
      return check.failMsg;
    }

    return __('This check was skipped');
  };

  return (
    <AccordionItem>
      <AccordionToggle
        onClick={() => setIsExpanded(!isExpanded)}
        isExpanded={isExpanded}
      >
        <Flex>
          <FlexItem>{selectIcon(props.check)}</FlexItem>
          <FlexItem>{props.check.title}</FlexItem>
        </Flex>
      </AccordionToggle>
      <AccordionContent isFixed isHidden={!isExpanded}>
        <p>{selectText(props.check)}</p>
      </AccordionContent>
    </AccordionItem>
  );
};

OvalPoliciesCheck.propTypes = {
  check: PropTypes.object.isRequired,
};

export default OvalPoliciesCheck;
