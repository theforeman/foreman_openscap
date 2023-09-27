import componentRegistry from 'foremanReact/components/componentRegistry';

import RuleSeverity from './components/RuleSeverity';
import OpenscapRemediationWizard from './components/OpenscapRemediationWizard';

const components = [
  { name: 'RuleSeverity', type: RuleSeverity },
  { name: 'OpenscapRemediationWizard', type: OpenscapRemediationWizard },
];

components.forEach(component => {
  componentRegistry.register(component);
});
