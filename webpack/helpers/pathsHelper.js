import { decodeId } from './globalIdHelper';

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

export const ovalContentsPath = experimental('/compliance/oval_contents');
export const ovalContentsShowPath = showPath(ovalContentsPath);
export const ovalPoliciesPath = experimental('/compliance/oval_policies');
export const ovalPoliciesShowPath = `${showPath(ovalPoliciesPath)}/:tab?`;
export const hostsPath = '/hosts';
export const newJobPath = '/job_invocations/new';
export const hostsShowPath = showPath(hostsPath);
