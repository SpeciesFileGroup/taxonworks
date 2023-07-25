<template>
    <div class="label-above">
        <label>
            <input
                    type="checkbox"
                    v-model="requireGeographicAreaExists">
            Error if no geographic area with provided name exists (works best with "Only search for the finest geographical name provided")
        </label>
    </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
    computed: {
      requireGeographicAreaExists: {
            get () {
                return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.require_geographic_area_exists
            },
            set (value) {
                UpdateImportSettings({
                    import_dataset_id: this.dataset.id,
                    import_settings: {
                        require_geographic_area_exists: value
                    }
                }).then(response => {
                    this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
                })
            }
        },
        dataset () {
            return this.$store.getters[GetterNames.GetDataset]
        }
    }
}
</script>
