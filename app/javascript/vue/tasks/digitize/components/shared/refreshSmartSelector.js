import { GetterNames } from '../../store/getters/getters'

export default {
  computed: {
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },
  watch: {
    lastSave () {
      this.$refs.smartSelector.refresh()
    }
  }
}