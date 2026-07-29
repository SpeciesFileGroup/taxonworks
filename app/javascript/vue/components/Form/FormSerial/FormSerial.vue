<template>
  <div class="label-above">
    <div class="field">
      <label>Name</label>
      <textarea
        v-model="serial.name"
        class="full_width"
        rows="3"
        required
      />
    </div>

    <div class="field">
      <label>Publisher</label>
      <input
        v-model="serial.publisher"
        class="full_width"
        type="text"
      />
    </div>

    <div class="field">
      <label>Place published</label>
      <input
        v-model="serial.place_published"
        class="full_width"
        type="text"
      />
    </div>

    <SerialPrimaryLanguage v-model="serial.primary_language_id" />

    <SerialTranslatedFrom
      v-model="serial.translated_from_serial_id"
      :exclude-id="serial.id"
    />

    <div class="horizontal-left-content gap-small">
      <div class="field">
        <label>First year of issue</label>
        <input
          v-model="serial.first_year_of_issue"
          type="number"
        />
      </div>

      <div class="field">
        <label>Last year of issue</label>
        <input
          v-model="serial.last_year_of_issue"
          type="number"
        />
      </div>
    </div>

    <div class="field">
      <label>
        <input
          v-model="serial.is_electronic_only"
          type="checkbox"
        />
        Is electronic only
      </label>
    </div>
  </div>
</template>

<script setup>
import SerialPrimaryLanguage from './SerialPrimaryLanguage.vue'
import SerialTranslatedFrom from './SerialTranslatedFrom.vue'

const serial = defineModel({
  type: Object,
  required: true
})
</script>
