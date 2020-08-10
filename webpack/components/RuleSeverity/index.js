import React from 'react';

import SeverityCritical from './i_severity-critical.svg';
import SeverityHigh from './i_severity-high.svg';
import SeverityMedium from './i_severity-med.svg';
import SeverityLow from './i_severity-low.svg';
import SeverityUnknown from './i_unknown.svg';

import './RuleSeverity.scss';

const RuleSeverity = props => {
  const imgStyles = { className: 'severity-img-scale' };

  const propsMapping = {
    'Low': { alt: 'Low Serverity', src: SeverityLow, ...imgStyles },
    'Medium': { alt: 'Medium Serverity', src: SeverityMedium, ...imgStyles },
    'High': { alt: 'High Serverity', src: SeverityHigh, ...imgStyles },
    'Critical': { alt: 'Critical Serverity', src: SeverityCritical, ...imgStyles },
    'Unknown': { alt: 'Unknown Serverity', src: SeverityUnknown, ...imgStyles },
  };

  let imgProps = propsMapping[props.severity] || propsMapping['Unknown'];
  return <img {...imgProps} />;
}

export default RuleSeverity;
