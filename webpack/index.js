import componentRegistry from 'foremanReact/components/componentRegistry';

import RuleSeverity from './components/RuleSeverity';
import OpenscapRemediationWizard from './components/OpenscapRemediationWizard';
import LineChart from './components/LineChart';

const components = [
  { name: 'RuleSeverity', type: RuleSeverity },
  { name: 'OpenscapRemediationWizard', type: OpenscapRemediationWizard },
  { name: 'OpenscapLineChart', type: LineChart },
];

components.forEach(component => {
  componentRegistry.register(component);
});
