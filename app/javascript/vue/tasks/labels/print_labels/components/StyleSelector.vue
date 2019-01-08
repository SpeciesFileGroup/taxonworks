<template>
  <div>
    <h2>Style</h2>
    <ul class="no_bullets">
      <li v-for="item in list">
        <label>
          <input
            type="radio"
            name="style-selector">
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      list: [{
        label: '4 Dram ETOH (INHS style)',
        value: 'inhs'
      },
      {
        label: '4pt Times New Roman (TAMU style)',
        value: 'tamu'
      },
      {
        label: 'Plant',
        value: 'plant'
      }]
    }
  }
}
</script>
