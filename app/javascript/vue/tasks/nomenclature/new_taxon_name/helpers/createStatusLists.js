import { copyObject } from 'helpers/objects'

export const createStatusLists = (list, taxonRank, parentRank) => {
  const { all, common, tree } = copyObject(list)

  const newList = {
    tree,
    all: getStatusListForThisRank(all, taxonRank),
    common: getStatusListForThisRank(common, parentRank)
  }

  setTreeListForThisRank(newList.tree, all, newList.all)

  return newList
}

const getStatusListForThisRank = (list, findStatus) => {
  const newList = []

  for (const key in list) {
    const ranks = list[key].applicable_ranks
    const status = ranks.find(item => item === findStatus)

    if (status) {
      newList.push(list[key])
    }
  }

  return newList
}

const setTreeListForThisRank = (list, ranksList, filteredList) => {
  for (const key in list) {
    const rankExist = filteredList.find(item => item.type === key)

    Object.defineProperty(list[key], 'name', { writable: true, value: ranksList[key].name })
    Object.defineProperty(list[key], 'type', { writable: true, value: ranksList[key].type })
    Object.defineProperty(list[key], 'disabled', { writable: true, value: !rankExist, configurable: true })

    setTreeListForThisRank(list[key], ranksList, filteredList)
  }
}
