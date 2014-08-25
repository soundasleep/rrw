# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Yay, Turbolinks!
$(document).on 'page:change', ->
  $.ajax
    url: "/world/chat.json"
    success: (json, status, xhr) ->
      $(".chat").empty()

      $(json).each (index, chat) ->
        clone = $(".chat-template").clone()
        clone.removeClass("chat-template")
        clone.find(".time").text(moment(chat.created_at).format("HH:mm"))
        clone.find(".time").attr("title", chat.created_at)
        clone.find(".text").text(chat.render_text)
        # clone.text(chat.render_text)
        clone.addClass("is-entering") if chat.is_entering
        clone.addClass("is-leaving") if chat.is_leaving
        $(".chat").append(clone)
        clone.show()
