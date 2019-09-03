<template>
  <div>
    <select>
      <option/>
    </select>
    <button
      type="button"
      class="button normal-input button-default">
      Set
    </button>
    <table>
      <thead>
        <tr>
          <th>Code for matrix</th>
          <th>Code</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data () {
    return {
      dataset: [{
        label: 'Observation total',
        set: [{
          label: 'Observations',
          value: 'observation'
        },
        {
          label: 'Observation depictions',
          value: 'depictions'
        }]
      }]
    }
  }
}
</script>
