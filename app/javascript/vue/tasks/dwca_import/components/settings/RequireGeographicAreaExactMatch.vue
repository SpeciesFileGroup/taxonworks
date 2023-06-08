<template>
    <div class="label-above">
        <label>
            <input
                    type="checkbox"
                    v-model="requireGeographicAreaExactMatch">
            Only search for the finest geographical name provided
        </label>
    </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
    computed: {
        requireGeographicAreaExactMatch: {
            get () {
                return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.require_geographic_area_exact_match
            },
            set (value) {
                UpdateImportSettings({
                    import_dataset_id: this.dataset.id,
                    import_settings: {
                        require_geographic_area_exact_match: value
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
