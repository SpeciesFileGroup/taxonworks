export default ({ role_counts }) => {
  let total = 0
  if (role_counts === undefined) {
    return total;
  }
  // loop through in_project, not_in_project, community
  Object.values(role_counts).forEach(group => {
    total += Object.values(group).reduce((a, b) => a + b, 0);
  });
  return total
}
