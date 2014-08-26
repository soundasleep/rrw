# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@App =
  Chat:
    update: ->
      return if $(".chat").length == 0 or !$(".chat").is(":visible")

      $.ajax
        url: "/world/chat.json?since=" + new Date().valueOf()
        success: (json, status, xhr) ->
          App.Chat.render(json)

    render: (json) ->
      $(".chat").empty()

      $(json).each (index, chat) ->
        clone = $(".chat-template").clone()
        clone.removeClass("chat-template")
        clone.find(".time").text(moment(chat.created_at).format("HH:mm"))
        clone.find(".time").attr("title", chat.created_at)
        clone.find(".text").text(chat.render_text)
        clone.addClass("is-entering") if chat.is_entering
        clone.addClass("is-leaving") if chat.is_leaving
        clone.addClass("is-death") if chat.is_death
        clone.addClass("is-new-player") if chat.is_new_player
        $(".chat").append(clone)
        clone.show()

$(document).on 'ready', ->
  App.Chat.update()
  window.setInterval(App.Chat.update, 10 * 1000)
  $(".chat").click ->
    App.Chat.update()

# yay turbolinks
$(document).on 'page:change', ->
  App.Chat.update()
