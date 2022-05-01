import { Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }) => {
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')
  const taxonId = urlParams.get('taxon_name_id')

  if (!otuId && !taxonId) return

  const params = {
    otu_id: otuId,
    taxon_name_id: taxonId
  }

  const otuList = (await Otu.where(params)).body
  let otu

  if (otuList.length) {
    otu = otuList[0]
  } else if (taxonId) {
    otu = (await Otu.create({ otu: { taxon_name_id: taxonId } })).body
  }

  commit(MutationNames.SetTaxonDeterminations, [{
    object_tag: otu.object_tag,
    otu_id: otu.id,
    roles_attributes: [],
    uuid: crypto.randomUUID()
  }])
}
