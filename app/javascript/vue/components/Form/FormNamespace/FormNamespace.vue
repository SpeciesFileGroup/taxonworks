<template>
  <div class="horizontal-left-content align-start">
    <div>
      <NamespaceInstitution v-model="namespace.institution" />
      <div
        v-help="help.name"
        class="field label-above"
      >
        <label>Name</label>
        <input
          v-model="namespace.name"
          id="namespace_name"
          type="text"
        />
      </div>
      <div
        v-help="help.shortName"
        class="field label-above"
      >
        <label>Short name</label>
        <input
          v-model="namespace.short_name"
          id="namespace_short_name"
          type="text"
        />
      </div>
      <div
        v-help="help.verbatimShortName"
        class="field label-above"
      >
        <label>Verbatim</label>
        <input
          v-model="namespace.verbatim_short_name"
          type="text"
        />
      </div>
      <div
        v-help="help.isVirtual"
        class="field"
      >
        <label>
          <input
            v-model="namespace.is_virtual"
            type="checkbox"
          />
          Is virtual
        </label>
      </div>
      <NamespaceDelimiter
        v-model="namespace.delimiter"
        :short-name="namespace.short_name"
      />
    </div>
  </div>
</template>

<script setup>
import NamespaceInstitution from './NamespaceInstitution.vue'
import NamespaceDelimiter from './NamespaceDelimiter.vue'
import help from './constants/help.js'
import { vHelp } from '@/directives'

const namespace = defineModel({
  type: Object,
  required: true
})
</script>
