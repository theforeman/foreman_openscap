import { join, find, map, compact, includes, filter } from 'lodash';

const getResponseErrorMsgs = ({ data } = {}) => {
  if (data) {
    const messages =
      data.displayMessage || data.message || data.errors || data.error?.message;
    return Array.isArray(messages) ? messages : [messages];
  }
  return [];
};

export const errorMsg = error => {
  join(getResponseErrorMsgs(error?.response || {}), '\n');
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
