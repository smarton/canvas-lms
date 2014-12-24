require [
  'jquery'
  'i18n!course_list'
], ($, I18n) ->

  success = (target) ->
    favorited_tooltip = I18n.t('favorited_tooltip', "Click to remove from the courses menu.")
    nonfavorite_tooltip = I18n.t('nonfavorited_tooltip', 'Click to add to the courses menu.')
    notfavoritable_tooltip = I18n.t("This course cannot be added to the courses menu at this time.")

    if target.hasClass 'course-list-favorite-course'
      target.removeClass 'course-list-favorite-course'
      if target.hasClass 'course-list-not-favoritable'
        target.removeAttr('data-favorite-url')# Remove the data so it won't be used later.
        target.off 'click keyclick'
        target.attr('title', notfavoritable_tooltip)
        target.data('ui-tooltip-title', notfavoritable_tooltip)
        target.children('.screenreader-only').text(notfavoritable_tooltip)
        return

      target.attr('title', nonfavorite_tooltip)
      # The tooltip wouldn't update with just changing the title so
      # it's forced to do so here. Same below in the else case.
      target.data('ui-tooltip-title', nonfavorite_tooltip)
      target.children('.screenreader-only').text(nonfavorite_tooltip)

    else
      target.addClass 'course-list-favorite-course'
      target.attr('title', favorited_tooltip)
      target.data('ui-tooltip-title', favorited_tooltip)
      target.children('.screenreader-only').text(favorited_tooltip)
      return

  $('[data-favorite-url]').on 'click keyclick', (event) ->
    event.preventDefault();
    url = $(this).data('favoriteUrl')
    target = $(event.currentTarget)
    if target.hasClass 'course-list-favorite-course'
      $.ajaxJSON url, 'DELETE', {}, success(target), null
    else
      $.ajaxJSON url, 'POST', {}, success(target), null


