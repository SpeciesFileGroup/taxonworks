<template>
  <div class="panel content">
    <h2>Bibtex</h2>
    <div class="vue-new-source-task-bibtex">
      <bibtex-type/>
      <bibtex-title/>
      <bibtex-authors/>
      <bibtex-date/>
      <bibtex-serial/>
      <bibtex-volume/>
      <bibtex-language/>
      <bibtex-chapter/>
      <bibtex-book-title/>
      <bibtex-edition/>
      <bibtex-series/>
      <bibtex-source-editor/>
      <bibtex-organization/>
      <bibtex-institution/>
      <bibtex-howpublished/>
      <bibtex-publisher/>
      <bibtex-address/>
      <bibtex-school/>
      <bibtex-copyright/>
      <bibtex-translator/>
      <bibtex-abstract/>
      <bibtex-key/>
      <bibtex-url/>
      <bibtex-verbatim/>
      <bibtex-crosslinks/>
      <bibtex-tw-attributes/>
    </div>
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
import BibtexChapter from './chapter'
import BibtexBookTitle from './booktitle'
import BibtexEdition from './edition'
import BibtexSeries from './series'
import BibtexSourceEditor from './sourceEditor'
import BibtexOrganization from './organization'
import BibtexInstitution from './institution'
import BibtexHowpublished from './howPublished'
import BibtexPublisher from './publisher'
import BibtexAddress from './address'
import BibtexSchool from './School'
import BibtexCopyright from './copyright'
import BibtexTranslator from './translator'
import BibtexAbstract from './abstract'
import BibtexKey from './key'
import BibtexUrl from './url'
import BibtexVerbatim from './verbatimBibtex'
import BibtexCrosslinks from './crosslinks'
import BibtexTwAttributes from './twAttributes'

export default {
  components: {
    BibtexType,
    BibtexTitle,
    BibtexAuthors,
    BibtexDate,
    BibtexSerial,
    BibtexVolume,
    BibtexLanguage,
    BibtexChapter,
    BibtexBookTitle,
    BibtexEdition,
    BibtexSeries,
    BibtexSourceEditor,
    BibtexOrganization,
    BibtexInstitution,
    BibtexHowpublished,
    BibtexPublisher,
    BibtexAddress,
    BibtexSchool,
    BibtexCopyright,
    BibtexTranslator,
    BibtexAbstract,
    BibtexKey,
    BibtexUrl,
    BibtexVerbatim,
    BibtexCrosslinks,
    BibtexTwAttributes
  }
}
</script>

<style lang="scss">
  .vue-new-source-task-bibtex {
    max-height: 700px;
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;

    textarea {
      width: 100%;
      height: 80px;
    }

    > div {
      margin-right: 14px;
    }
  }
</style>