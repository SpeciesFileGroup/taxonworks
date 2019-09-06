export default function (findInGroups, taxon) {
  return (taxon.rank_string ? (findInGroups.indexOf(taxon.rank_string.split('::')[2]) > -1) : false)
}
