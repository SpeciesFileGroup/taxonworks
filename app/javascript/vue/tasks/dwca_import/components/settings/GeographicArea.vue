<template>
    <div class="field ">
        <label>Geographical Area Data Origin: </label>
        <select v-model="geographicAreaDataOrigin">
            <option
                v-for="data_origin in data_origins"
                :key="data_origin"
                :value="data_origin"
            >
                {{ data_origin.toUpperCase() }}
            </option>
        </select>
    </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'
import DATA_ORIGINS from '../../const/geographicalAreaDataOrigins.js'

export default {
    data () {
        return {
            data_origins: Object.values(DATA_ORIGINS)
        }
    },

    computed: {
        geographicAreaDataOrigin: {
            get () {
                return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.geographic_area_data_origin || DATA_ORIGINS.NONE
            },
            set (value) {
                UpdateImportSettings({
                    import_dataset_id: this.dataset.id,
                    import_settings: {
                        geographic_area_data_origin: value
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