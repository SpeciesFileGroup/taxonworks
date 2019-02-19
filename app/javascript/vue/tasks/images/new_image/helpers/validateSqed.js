export default function(sqed) {
  return (sqed.boundary_color &&
    sqed.boundary_finder &&
    sqed.layout) ? true : false
}