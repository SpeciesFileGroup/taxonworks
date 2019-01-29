export default function(identifier) {
  return (identifier.namespace_id != undefined 
      && identifier.identifier != undefined)
}