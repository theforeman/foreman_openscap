export const policySchedule = policy => {
  switch (policy.period) {
    case 'weekly':
      return `Weekly, on ${policy.weekday}`;
    case 'monthly':
      return `Monthly, day of month: ${policy.dayOfMonth}`;
    case 'custom':
      return `Custom cron: ${policy.cronLine}`;
    default:
      return 'Unknown schedule';
  }
};
