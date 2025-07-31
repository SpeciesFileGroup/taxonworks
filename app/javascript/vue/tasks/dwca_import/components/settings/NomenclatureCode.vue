<template>
  <div class="field">
    <label>Nomenclature code: </label>
    <select v-model="nomenclatureCode">
      <option
        v-for="(code, key) in CODES"
        :key="key"
        :value="code"
      >
        {{ code.toUpperCase() }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { useImportSetting } from './useImportSetting.js'
import CODES from '../../const/nomenclatureCodes.js'

const SETTING_PROPERTY = 'nomenclatural_code'

const nomenclatureCode = useImportSetting(SETTING_PROPERTY, {
  defaultValue: CODES.ICZN
})
</script>
