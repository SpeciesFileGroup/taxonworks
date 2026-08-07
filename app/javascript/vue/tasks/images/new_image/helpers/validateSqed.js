export default function (sqed) {
  return (
    sqed.layout && sqed.boundary_color && sqed.boundary_finder ||
      (sqed.layout == 'stage' && sqed.metadata_map[0] === 'stage') // pattern None
  )
}
