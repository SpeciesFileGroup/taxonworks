export default function(typeMaterial) {
  return (typeMaterial.protonym_id != undefined 
      && typeMaterial.biological_object_id != undefined 
      && typeMaterial.type_type != undefined )
}