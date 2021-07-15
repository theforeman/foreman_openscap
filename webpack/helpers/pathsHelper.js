import { decodeId } from './globalIdHelper';
import { foremanUrl } from 'foremanReact/common/helpers';

const experimental = path => `/experimental${path}`;

const showPath = path => `${path}/:id`;

export const modelPath = (basePath, model) => `${basePath}/${decodeId(model)}`;

// react-router uses path-to-regexp, should we use it as well in a future?
// https://github.com/pillarjs/path-to-regexp/tree/v1.7.0#compile-reverse-path-to-regexp
export const resolvePath = (path, params) =>
  Object.entries(params).reduce(
    (memo, [key, value]) => memo.replace(key, value),
    path
  );

export const ovalContentsPath = foremanUrl(experimental('/compliance/oval_contents'));
export const ovalPoliciesPath = foremanUrl(experimental('/compliance/oval_policies'));
export const ovalPoliciesShowPath = `${showPath(ovalPoliciesPath)}/:tab?`;
export const hostsPath = foremanUrl('/hosts');
export const newJobPath = foremanUrl('/job_invocations/new');
export const hostsShowPath = showPath(hostsPath);
