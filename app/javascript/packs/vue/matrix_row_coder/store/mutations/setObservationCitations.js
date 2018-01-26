export default function (state, args) {
  const observation = state.observations.find(o => o.id === args.observationId)
  observation.citations = args.citations.map(transformCitationsForViewmodel)
};

function transformCitationsForViewmodel (citationData) {
  return {
    description: citationData.source.cached,
    author: citationData.source.cached_author_string
  }
}
