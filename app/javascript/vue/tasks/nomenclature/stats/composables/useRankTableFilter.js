import { onBeforeMount, reactive, toRefs } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import qs from 'qs'

const FIELDSETS = ['nomenclatural_stats']
const LIMIT = 1000

function makeInitialParameters() {
  return {
    taxon_name_id: undefined,
    ranks: [],
    rank_data: [],
    combinations: false
  }
}

function flattenRankNames(list) {
  return Object.values(list || {}).flatMap((value) =>
    Array.isArray(value)
      ? value.map((rank) => rank.name)
      : flattenRankNames(value)
  )
}

export default function useRankTableFilter() {
  const state = reactive({
    parameters: makeInitialParameters(),
    taxonName: undefined,
    rankList: {},
    rankTable: {},
    supportedRanks: [],
    isLoading: false,
    urlRequest: ''
  })

  function orderRanks(rankNames, nomenclaturalCode) {
    const reference = [
      ...new Set(
        flattenRankNames(state.rankList[nomenclaturalCode] || state.rankList)
      )
    ]

    return reference.filter((rank) => rankNames.includes(rank))
  }

  function setUrlParameters() {
    const { taxon_name_id, ranks, rank_data, combinations } = state.parameters
    const urlParameters = qs.stringify(
      { taxon_name_id, ranks, rank_data, combinations },
      { arrayFormat: 'brackets' }
    )

    history.pushState(
      null,
      null,
      `${window.location.pathname}?${urlParameters}`
    )
  }

  function makeFilterRequest() {
    const { taxon_name_id, ranks, rank_data, combinations } = state.parameters

    if (!taxon_name_id || !ranks.length) return

    const nomenclaturalCode = state.taxonName?.nomenclatural_code
    const payload = {
      taxon_name_id,
      ranks: orderRanks(ranks, nomenclaturalCode),
      rank_data: rank_data.length
        ? orderRanks(rank_data, nomenclaturalCode)
        : undefined,
      combinations,
      fieldsets: FIELDSETS,
      validity: true,
      limit: LIMIT
    }

    state.isLoading = true

    return TaxonName.rankTable(payload)
      .then((response) => {
        state.rankTable = response.body
        state.urlRequest = response.request.responseURL

        if (response.body.data?.length === LIMIT) {
          TW.workbench.alert.create(
            `Result contains ${LIMIT} rows, it may be truncated.`,
            'notice'
          )
        }

        setUrlParameters()
      })
      .finally(() => {
        state.isLoading = false
      })
  }

  function selectTaxonName(taxonName) {
    state.taxonName = taxonName
    state.parameters = {
      ...makeInitialParameters(),
      taxon_name_id: taxonName.id,
      ranks: [taxonName.rank],
      rank_data: [taxonName.rank],
      combinations: state.parameters.combinations
    }
  }

  function resetFilter() {
    state.parameters = makeInitialParameters()
    state.taxonName = undefined
    state.rankTable = {}
    state.urlRequest = ''

    history.pushState(null, null, window.location.pathname)
  }

  onBeforeMount(async () => {
    const { body: rankList } = await TaxonName.ranks()

    state.rankList = rankList
    state.supportedRanks = [...new Set(flattenRankNames(rankList))]

    const {
      taxon_name_id: taxonNameId,
      ranks,
      rank_data: rankData,
      combinations
    } = qs.parse(location.search, { ignoreQueryPrefix: true })

    if (!/^\d+$/.test(taxonNameId)) return

    const { body: taxonName } = await TaxonName.find(taxonNameId, {
      extend: ['parent']
    })

    if (!state.supportedRanks.includes(taxonName.rank)) return

    state.taxonName = taxonName
    state.parameters = {
      taxon_name_id: taxonName.id,
      ranks: ranks?.length ? ranks : [taxonName.rank],
      rank_data: rankData?.length ? rankData : [taxonName.rank],
      combinations: combinations === 'true'
    }

    makeFilterRequest()
  })

  return {
    ...toRefs(state),
    makeFilterRequest,
    resetFilter,
    selectTaxonName
  }
}
