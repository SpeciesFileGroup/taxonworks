export default function (rank) {
  return (rank ? rank.split('::')[2].split('Group')[0] : undefined)
}
