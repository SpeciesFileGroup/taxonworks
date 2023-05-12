export default function (sqed) {
  return !!(
    sqed.boundary_color &&
    (sqed.boundary_finder || sqed.metadata_map[0] === 'none') &&
    sqed.layout
  )
}
