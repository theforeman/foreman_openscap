import { join, find, map, compact, includes, filter, isString } from 'lodash';

const getResponseErrorMsgs = ({ data } = {}) => {
  if (data) {
    const messages =
      data.displayMessage || data.message || data.errors || data.error?.message;
    return Array.isArray(messages) ? messages : [messages];
  }
  return [];
};

export const errorMsg = data => {
  if (isString(data)) return data;

  return join(getResponseErrorMsgs({ data }), '\n');
};

export const findFixBySnippet = (fixes, snippet) =>
  find(fixes, fix => fix.system === snippet);

export const supportedRemediationSnippets = (
  fixes,
  meth,
  supportedJobSnippets
) => {
  if (meth === 'manual') return map(fixes, f => f.system);
  return compact(
    map(
      filter(fixes, fix => includes(supportedJobSnippets, fix.system)),
      f => f.system
    )
  );
};

export const reviewHostCount = hostIdsParam => hostIdsParam.split(',').length;
