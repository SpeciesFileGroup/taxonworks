var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.nomenclature = TW.views.tasks.nomenclature || {}
TW.views.tasks.nomenclature.browse = TW.views.tasks.nomenclature.browse || {}

Object.assign(TW.views.tasks.nomenclature.browse, {

  init: function () {
    var soft_validations = undefined
    function fillSoftValidation() {
      if (soft_validations == undefined) {
        if ($('[data-global-id]').length) {
          soft_validations = {}
          $('[data-filter=".soft_validation_anchor"]').mx_spinner('show')

          let groups = {}
          $('[data-global-id]').each(function () {
            let gid = $(this).attr("data-global-id");

            (groups[gid] || (groups[gid] = [])).push(this)
          })

          for (const gid in groups) {
            $.ajax({
              url: "/soft_validations/validate?global_id=" + gid,
              dataType: "json",
            }).done(function (response) {
              for (const element of groups[gid]) {
                if (response.soft_validations.length) {
                  if (!soft_validations.hasOwnProperty($(element).attr('id'))) {
                    Object.defineProperty(soft_validations, $(element).attr('id'), { value: response.soft_validations })
                  }
                }
                else {
                  $(element).remove()
                }
              }
            })
          }
        }
      }
    }

    var taxonId = document.querySelector("#browse-view").getAttribute("data-taxon-id")
    var taxonType = document.querySelector("[data-taxon-type]") ? document.querySelector("[data-taxon-type]").getAttribute("data-taxon-type") : undefined
    var taxonStatus = document.querySelector('[data-status]') ? document.querySelector('[data-status]').getAttribute('data-status') : undefined

    if(taxonType === 'Invalid' || taxonType === 'Combination' || taxonStatus === 'invalid') {
      document.querySelector('#browse-nomenclature-taxon-name').classList.add('feedback-warning')
    }

    if(taxonType == 'Combination')
      $('.edit-taxon-name').attr('href', '/tasks/nomenclature/new_combination?taxon_name_id=' + taxonId)
    if(!document.querySelector('#browse-collection-object')) {
      TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + "+t", "Edit taxon name", "Browse nomenclature", function () {
        if (/^\d+$/.test(taxonId)) {
          if(taxonType == 'Combination')
            window.open('/tasks/nomenclature/new_combination?taxon_name_id=' + taxonId, '_self')
          else
            window.open('/tasks/nomenclature/new_taxon_name?taxon_name_id=' + taxonId, '_self')
        }
      })
      if (/^\d+$/.test(taxonId)) {
        TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + "+m", "New type specimen", "Browse nomenclature", function () {
          window.open('/tasks/nomenclature/new_taxon_name?taxon_name_id=' + taxonId, '_self')
        })

        TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + "+e", "Comprehensive specimen digitization", "Browse nomenclature", function () {
          window.open('/tasks/accessions/comprehensive?taxon_name_id=' + taxonId, '_self')
        })

        TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + "+o", "Browse OTU", "Browse nomenclature", function () {
          window.open('/tasks/otus/browse?taxon_name_id=' + taxonId, '_self')
        })
      }
    }

    $('.filter .open').on('click', function () {
      $(this).css('transform', 'rotate(' + ($(this).rotationInfo().deg + 180) + 'deg)')
      if ($(this).rotationInfo().deg == 360) {
        $(this).css('transform', 'rotate(1deg)')
      }
    })

    // TODO: move to an external generic utilities helper
    function isActive(tag, className) {
      if ($(tag).hasClass(className)) {
        $(tag).removeClass(className)
        return true
      }
      else {
        $(tag).addClass(className)
        return false
      }
    }

    function checkStates(element) {
      var filters = JSON.parse($(element).attr('data-hidden'))
      if (!filters.length) {
        $(element).show(255)
      }
      else {
        $(element).hide(255)
      }
    }

    function elementFilter(type, hide) {
      $(type).each(function () {
        if (hide) {
          addHiddenData($(this), type)
        }
        else {
          removeHiddenData($(this), type)
        }
        checkStates($(this))
      })
    }

    function retrieveElementFilters(element) {
      var attributes = $(element).attr('data-hidden')
      if (attributes) {
        attributes = JSON.parse(attributes)
      }
      if (Array.isArray(attributes)) {
        return attributes
      }
      else {
        return []
      }
    }

    function getFilterPosition(list, type) {
      return list.findIndex(function (item) {
        return item == type
      })
    }

    function addHiddenData(element, type) {
      var attributes = retrieveElementFilters($(element))

      if (getFilterPosition(attributes, type) < 0) {
        attributes.push(type)
        $(element).attr('data-hidden', JSON.stringify(attributes))
      }
    }

    function removeHiddenData(element, type) {
      var attributes = retrieveElementFilters($(element))
      var position = getFilterPosition(attributes, type)

      if (position > -1) {
        attributes.splice(position, 1)
        $(element).attr('data-hidden', JSON.stringify(attributes))
      }
    }

    if(document.querySelector('#browse-view').getAttribute('loaded') != 'true') {
      $('[data-history-valid-name="true"]').each(function () {
        if (!$(this).has('[data-icon="ok"]').length) {
          $(this).prepend('<span data-icon="ok"></span>')
        }
      })
      $('[data-history-origin]').each(function () {
        var type = $(this).attr("data-history-origin")
        $(this).prepend('<span class="history__origin ' + type + '">' + type + '</span>')
      })
    }    

    $('[data-icon="attention"][data-global-id]').on('click', function () {
      var list = ''
      if (soft_validations && soft_validations.hasOwnProperty($(this).attr('id'))) {

        soft_validations[$(this).attr('id')].forEach(function (item) {
          list += '<li class="list">' + item.message + '</li>'
        })

        $('#browse-view').append(`
          <div class="modal-mask">
            <div class="modal-wrapper">
              <div class="modal-container">
                <div class="modal-header">
                  <div class="modal-close"></div>
                  <h3>
                    Validation
                  </h3>
                </div>\
                <div class="modal-body soft_validation list">
                    <ul>${list}</ul>
                </div>
                <div class="modal-footer">
                </div>
              </div>
            </div>
          </div>
        `)
      }
    })

    $(document).ajaxStop(function () {
      $('[data-filter=".soft_validation_anchor"]').mx_spinner('hide')
    })

    $(document).on('click', '.modal-close', function () {
      $('.modal-mask').remove()
    })

    $.fn.rotationInfo = function () {
      var el = $(this),
        tr = el.css("-webkit-transform") || el.css("-moz-transform") || el.css("-ms-transform") || el.css("-o-transform") || '',
        info = { rad: 0, deg: 0 }
      if (tr = tr.match('matrix\\((.*)\\)')) {
        tr = tr[1].split(',')
        if (typeof tr[0] != 'undefined' && typeof tr[1] != 'undefined') {
          info.rad = Math.atan2(tr[1], tr[0])
          info.deg = parseFloat((info.rad * 180 / Math.PI).toFixed(1))
        }
      }
      return info
    };

    $('#filterBrowse_button').on('click', function () {
      $('[data-filter-slide]').slideToggle(250)
    })

    $('#filterBrowse').on('click', '[data-filter=".soft_validation_anchor"]', function (selector) {
      fillSoftValidation()
    })

    $('#filterBrowse').on('click', '.navigation-item', function (selector) {

      if ($(this).attr('data-filter-reset') === 'reset') {
        fillSoftValidation()
        $('[data-filter], [data-filter-font], [data-filter-row]').each(function (element) {
          if ($(this).hasClass("active")) {
            isActive($(this), 'active')
          }
          $($(this).attr('data-filter-font')).animate({
            fontSize: '100%'
          })
          $($(this).attr('data-filter-row')).removeAttr('data-hidden')
          $($(this).attr('data-filter-row')).show(255)
          $($(this).attr('data-filter-row')).parents('.history__record').show(255)
          $($(this).attr('data-filter')).show(255)
          $($(this).children()).attr('data-icon', 'show')
        })
      }
      else if($(this).attr('data-filter-hide-all')) {
        document.querySelectorAll('[data-filter]').forEach(element => {
          $(element).removeClass('active')
          $($(element).children()).attr('data-icon', 'hide')
          $($(element).attr('data-filter-font')).animate({
            fontSize: '0px'
          })

          elementFilter($(element).attr('data-filter-row'), true)
          $($(element).attr('data-filter')).hide(255)
        })
      }
      else {
        isActive($(this), 'active')
        if ($(this).children().attr('data-icon') == "show") {
          $($(this).children()).attr('data-icon', 'hide')
          $($(this).attr('data-filter-font')).animate({
            fontSize: '0px'
          })

          elementFilter($(this).attr('data-filter-row'), true)
          $($(this).attr('data-filter')).hide(255)
        }
        else {
          $($(this).children()).attr('data-icon', 'show')
          $($(this).attr('data-filter-font')).animate({
            fontSize: '100%'
          })

          elementFilter($(this).attr('data-filter-row'), false)
          $($(this).attr('data-filter')).show(255)
        }
      }
    })
    document.querySelector('#browse-view').setAttribute('loaded', true)
  }
})

$(document).on('turbolinks:load', function () {
  if ($("#browse-view").length) {
    TW.views.tasks.nomenclature.browse.init()
  }
})
