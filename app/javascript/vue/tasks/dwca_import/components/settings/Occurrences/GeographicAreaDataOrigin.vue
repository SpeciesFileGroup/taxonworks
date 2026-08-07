<template>
  <div class="field">
    <label>Require geographical area data origin: </label>
    <select v-model="geographicAreaDataOrigin">
      <option
        v-for="value in DATA_ORIGINS"
        :key="value"
        :value="value"
      >
        {{ value.toUpperCase() }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { useImportSetting } from '../useImportSetting.js'
import DATA_ORIGINS from '../../../const/geographicalAreaDataOrigins.js'

const SETTING_PROPERTY = 'geographic_area_data_origin'

const geographicAreaDataOrigin = useImportSetting(SETTING_PROPERTY)
</script>
