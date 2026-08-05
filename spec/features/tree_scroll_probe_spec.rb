require 'rails_helper'

describe 'tree scroll probe', type: :feature do
  before { sign_in_user_and_select_project }

  specify 'shot', js: true do
    page.driver.browser.manage.window.resize_to(1680, 1000)

    root = @project.send(:create_root_taxon_name)
    family = Protonym.create!(by: @user, project: @project, parent: root, name: 'Cicadidae', rank_class: Ranks.lookup(:iczn, :family))
    letters = ('a'..'z').to_a
    30.times do |i|
      name = 'G' + letters[i % 26] + letters[i / 26] + 'us'
      Protonym.create!(by: @user, project: @project, parent: family, name:, rank_class: Ranks.lookup(:iczn, :genus))
    end

    visit browse_nomenclature_task_path(taxon_name_id: family.id)
    sleep 4

    info = page.evaluate_script(<<~JS)
      (function () {
        const h = document.querySelector('#show_taxon_name_hierarchy')
        const inner = document.querySelector('.panel-taxonomy-tree')
        const card = h.closest('.tw-card')
        const col = card.closest('.nav-column')
        const m = (el) => el ? {c: el.clientHeight, s: el.scrollHeight, scrollable: el.scrollHeight > el.clientHeight} : null
        return JSON.stringify({
          rows: document.querySelectorAll('.taxonomy-tree li').length,
          hierarchy: m(h), inner: m(inner),
          card: card.getBoundingClientRect().height,
          column: col.getBoundingClientRect().height,
          viewport: window.innerHeight
        })
      })()
    JS
    puts "MEASURED: #{info}"
    page.save_screenshot('tmp/claude-1000/-home-josecito-Projects-taxonworks/62d3d7c8-58ed-4de6-b992-d5c2483307e2/scratchpad/tree_scroll.png')
    expect(true).to be(true)
  end
end
