import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { UpdateImportSettings } from '../../request/resources'

export function useImportSetting(property, opts = {}) {
  const store = useStore()
  const dataset = computed(() => store.getters[GetterNames.GetDataset])

  return computed({
    get() {
      return (
        store.getters[GetterNames.GetDataset].metadata?.import_settings[
          property
        ] ?? opts.defaultValue
      )
    },
    set(value) {
      UpdateImportSettings({
        import_dataset_id: dataset.value.id,
        import_settings: {
          [property]: value
        }
      }).then((_) => {
        store.dispatch(ActionNames.LoadDataset, dataset.value.id)
      })
    }
  })
}
