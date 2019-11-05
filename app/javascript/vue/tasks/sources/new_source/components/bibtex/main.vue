<template>
  <div class="panel content">
    <h2>Bibtex</h2>
    <bibtex-type/>
    <bibtex-title/>
    <bibtex-authors/>
    <bibtex-date/>
    <bibtex-serial/>
    <bibtex-volume/>
    <bibtex-language/>
  </div>
</template>

<script>

import BibtexType from './type'
import BibtexTitle from './title'
import BibtexAuthors from './author'
import BibtexDate from './date'
import BibtexSerial from './serial'
import BibtexVolume from './volume'
import BibtexLanguage from './language'

export default {
  components: {
    BibtexType,
    BibtexTitle,
    BibtexAuthors,
    BibtexDate,
    BibtexSerial,
    BibtexVolume,
    BibtexLanguage
  }
}
</script>