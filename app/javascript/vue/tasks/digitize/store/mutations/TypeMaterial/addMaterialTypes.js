export default (state, typeMaterial) => {
  const { typeSpecimens } = state
  const createdTypeMaterial = typeSpecimens.find(item =>
    item.internalId === typeMaterial.internalId
  )

  if (createdTypeMaterial) {
    Object.assign(createdTypeMaterial, { ...typeMaterial })
  } else {
    typeSpecimens.push(typeMaterial)
  }
}
