export default function(determination) {
  return (determination.biological_collection_object_id != undefined 
      && determination.otu_id != undefined)
}