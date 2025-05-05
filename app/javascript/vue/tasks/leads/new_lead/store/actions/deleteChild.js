export default function(child_id) {
  this.children.splice(child_id, 1)
  this.futures.splice(child_id, 1)
  this.last_saved.children.splice(child_id, 1)
}