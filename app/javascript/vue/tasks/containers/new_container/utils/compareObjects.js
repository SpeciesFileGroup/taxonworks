export function compareObjects(objA, objB) {
  return objA.objectId === objB.objectId && objA.objectType === objB.objectType
}
