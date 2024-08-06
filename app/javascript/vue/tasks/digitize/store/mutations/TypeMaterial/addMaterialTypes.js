export default (state, typeMaterial) => {
  const { typeSpecimens } = state
  const createdTypeMaterial = typeSpecimens.find(
    (item) => item.uuid === typeMaterial.uuid
  )

  if (createdTypeMaterial) {
    Object.assign(createdTypeMaterial, { ...typeMaterial })
  } else {
    typeSpecimens.push(typeMaterial)
  }
}
