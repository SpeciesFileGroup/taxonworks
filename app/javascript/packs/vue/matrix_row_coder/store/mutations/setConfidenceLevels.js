export default function (state, confidenceLevelPromise) {
  state.confidenceLevels = confidenceLevelPromise.then(confidenceLevels => {
    return confidenceLevels.map(transformConfidenceLevelForViewmodel)
  })
};

function transformConfidenceLevelForViewmodel (confidenceLevelData) {
  return {
    id: confidenceLevelData.id,
    name: confidenceLevelData.name,
    definition: confidenceLevelData.definition,
    color: confidenceLevelData.css_color
  }
}
