import { ActionNames } from '../../store/actions/actions'
import { MutationNames } from '../../store/mutations/mutations'
import { getTagMetadata, batchRemoveKeyword } from '../../request/resources'
import extend from '../../const/extend.js'

export default {
  props: {
    loan: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      maxItemsWarning: 100,
      keywords: []
    }
  },

  async created() {
    this.getMeta()
  },

  methods: {
    batchLoad(klass, keywordId, total) {
      const object = {
        batch_type: this.batchType,
        loan_id: this.loan.id,
        keyword_id: keywordId,
        klass: klass === 'total' ? undefined : klass,
        extend
      }
      if (total > this.maxItemsWarning) {
        if (
          window.confirm(
            `You're trying to create ${total} items. Are you sure want to proceed?`
          )
        ) {
          this.$store.dispatch(ActionNames.CreateBatchLoad, object)
        }
      } else {
        this.$store.dispatch(ActionNames.CreateBatchLoad, object)
      }
    },

    batchLoadForAll(keywordId, totals) {
      Object.entries(totals).forEach(([klass, total]) => {
        if (klass != 'total' && total > 0) {
          this.batchLoad(klass, keywordId, total)
        }
      })
    },

    async getMeta() {
      const metadata = (await getTagMetadata()).body
      this.keywords = metadata[this.metadataList]
    },

    removeKeyword(id, type) {
      this.$store.commit(MutationNames.SetSaving, true)
      batchRemoveKeyword(id, type).then(async () => {
        this.getMeta()
        this.$store.commit(MutationNames.SetSaving, false)
      })
    },

    isOneRow({ totals }) {
      return (
        Object.entries(totals).filter(([k, v]) => k !== 'total' && v > 0)
          .length === 1
      )
    }
  }
}
