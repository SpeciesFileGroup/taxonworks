<template>
  <CustomAttributes
    :key="store.typeMaterial.uuid"
    :object-id="store.typeMaterial.id"
    :object-type="TYPE_MATERIAL"
    :model="TYPE_MATERIAL"
    :pending-attributes="store.typeMaterial.dataAttributes"
    @on-update="setAttributes"
  />
</template>

<script setup>
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'
import { TYPE_MATERIAL } from '@/constants'
import useStore from '../store/store.js'

const store = useStore()

/*
  Attributes are kept on the type material until it is saved, then sent as nested
  attributes by `makeTypeMaterialPayload`. Keying on `uuid` remounts the panel
  whenever another type material is edited, which reloads the rows: `objectId`
  alone can not do it, it stays `undefined` between unsaved records (for example
  after "New type").
*/
function setAttributes(dataAttributes) {
  store.typeMaterial.dataAttributes = dataAttributes
  store.typeMaterial.isUnsaved = true
}
</script>
