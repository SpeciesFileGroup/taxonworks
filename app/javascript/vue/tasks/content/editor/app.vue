<template>
  <div id="content_editor">
    <panel-top class="horizontal-center-content"/>
    <div
      class="flex-separate"
      id="panels-content">
      <topic-section class="item item1 column-tiny"/>
      <div class="item item2 column-big">
        <content-editor/>
        <citation-list class="citation-list panel"/>
        <figures-panel/>
      </div>
      <div
        id="recent-list"
        class="slide-panel slide-recent item item3 column-tiny"
        data-panel-position="relative"
        data-panel-open="false"
        data-panel-name="recent_list">
        <div class="slide-panel-header">Recent list</div>
        <div class="slide-panel-content">
          <recent-list
            ajax-url="/contents.json"
            get-items="contents"
            select="SetContentSelected"
            set-items="SetRecentContents"
            title="Contents"/>
          <recent-list
            ajax-url="/tasks/content/editor/recent_topics.json"
            select="SetTopicSelected"
            get-items="topics"
            set-items="SetRecentTopics"
            title="Topics"/>
          <recent-list
            ajax-url="/tasks/content/editor/recent_otus.json"
            select="SetOtuSelected"
            get-items="otus"
            set-items="SetRecentOtus"
            title="OTUs"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import panelTop from './panels/top.vue'
import recentList from './panels/recentlist.vue'
import citationList from './editor/citationList.vue'
import contentEditor from './editor/content.vue'
import figuresPanel from './editor/figuresPanel.vue'
import topicSection from './panels/topicSection.vue'

export default {
  components: {
    panelTop,
    recentList,
    citationList,
    contentEditor,
    figuresPanel,
    topicSection
  }
}

</script>
