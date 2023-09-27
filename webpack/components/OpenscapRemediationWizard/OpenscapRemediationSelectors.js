import {
  selectAPIError,
  selectAPIResponse,
  selectAPIStatus,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import {
  JOB_INVOCATION_API_REQUEST_KEY,
  REPORT_LOG_REQUEST_KEY,
} from './constants';

export const selectRemediationResponse = state =>
  selectAPIResponse(state, JOB_INVOCATION_API_REQUEST_KEY) || {};

export const selectRemediationStatus = state =>
  selectAPIStatus(state, JOB_INVOCATION_API_REQUEST_KEY) || STATUS.PENDING;

export const selectRemediationError = state =>
  selectAPIError(state, JOB_INVOCATION_API_REQUEST_KEY);

export const selectLogResponse = state =>
  selectAPIResponse(state, REPORT_LOG_REQUEST_KEY) || {};

export const selectLogStatus = state =>
  selectAPIStatus(state, REPORT_LOG_REQUEST_KEY) || STATUS.PENDING;

export const selectLogError = state =>
  selectAPIError(state, REPORT_LOG_REQUEST_KEY);
