<template>
    <div class="label-above">
        <label>
            <input
                    type="checkbox"
                    v-model="requireGeographicAreaHasShape">
            Require that the matched geographic area has a shape
        </label>
    </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
    computed: {
        requireGeographicAreaHasShape: {
            get () {
                return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.require_geographic_area_has_shape
            },
            set (value) {
                UpdateImportSettings({
                    import_dataset_id: this.dataset.id,
                    import_settings: {
                        require_geographic_area_has_shape: value
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
