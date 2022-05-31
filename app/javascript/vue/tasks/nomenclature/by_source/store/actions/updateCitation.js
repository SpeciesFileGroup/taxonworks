import { Citation } from "routes/endpoints"

export default ({ state }, payload) => {
  const {
    citationId,
    pages,
    is_original
  } = payload

  Citation.update(citationId, { 
    citation: { 
      pages,
      is_original
    } 
  }).then(_ => {
    TW.workbench.alert.create('Citation was successfully updated.', 'notice')
  })
}