import findPosition from './findPosition'

export default function (list, rank) {
  return list.slice(findPosition(list, rank) + 1)
}
