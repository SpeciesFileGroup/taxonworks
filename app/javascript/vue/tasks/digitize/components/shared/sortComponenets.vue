<script>

  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations.js'

  import { UpdateUserPreferences } from '../../request/resources.js'

  export default {
    computed: {
      preferences: {
        get() {
          return this.$store.getters[GetterNames.GetPreferences]
        },
        set(value) {
          this.$store.commit(MutationNames.SetPreferences, value)
        }
      }
    },
    data() {
      return {
        componentsOrder: [],
        keyStorage: ''
      }
    },
    watch: {
      preferences: {
        handler(newVal) {
          if(this.preferences.layout[this.keyStorage] && this.componentsOrder.length == this.preferences.layout[this.keyStorage].length)
            this.componentsOrder = this.preferences.layout[this.keyStorage]
        },
        deep: true
      }
    },
    methods: {
      updatePreferences() {
        UpdateUserPreferences(this.preferences.id, { [this.keyStorage]: this.componentsOrder }).then(response => {
          this.preferences.layout = response.body.preferences
          this.componentsOrder = response.body.preferences.layout[this.keyStorage]
        })
      }
    }
  }
</script>