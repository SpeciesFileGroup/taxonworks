<template>
  <div>
    <h2>&nbsp</h2>
    <textare v-model="pasteSequence"/>
    <dropzone-component
      id="dropzone-fasta"
      :vdropzone-success="addSequence"
      url="/sequences"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
    <label>
      <input
        type="checkbox"
        v-model="fileNameSequence">
      File name is a sequence name
    </label>
  </div>
</template>

<script>

import DropzoneComponent from 'components/dropzone'

export default {
  components: {
    DropzoneComponent
  },
  data () {
    return {
      fileNameSequence: false,
      pasteSequence: undefined,
      dropzone: {
        paramName: 'sequence[file]',
        url: '/sequences',
        autoProcessQueue: false,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop FASTA files here',
        acceptedFiles: '.fa, .mpfa, .fna, .fsa, .fas o .fasta'
      }
    }
  },
  methods: {
    addSequence(file, sequence) {
      this.$emit('onImportedFile', sequence)
    }
  }
}
</script>